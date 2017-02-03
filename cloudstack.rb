#
# Author:: Hans Rakers (<h.rakers@global.leaseweb.com>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'ohai/mixin/ec2_metadata'
require 'ohai/hints'

module Ohai
  module Mixin
    # Module to find the CloudStack metadata service IP (the virtual router IP)
    module CloudstackMetadata
      include Ohai::Mixin::Ec2Metadata

      def self.find_dhcp_server
        virtual_router = nil
        %w(/var/lib/dhcp /var/lib/dhclient /var/lib/dhcp3).each do |dhcp_dir|
          next unless File.directory? dhcp_dir

          Dir.glob(File.join(dhcp_dir, 'dhclient*eth0*lease*')).each do |file|
            next unless File.size?(file)

            virtual_router = File.open(file).grep(/dhcp-server-identifier/).last
            next unless virtual_router
          end
        end
        virtual_router[/\d+(\.\d+){3}/]
      end

      CLOUDSTACK_METADATA_ADDR = find_dhcp_server unless defined?(CLOUDSTACK_METADATA_ADDR)

      def http_client
        Net::HTTP.start(CLOUDSTACK_METADATA_ADDR).tap { |h| h.read_timeout = 600 }
      end

      def best_api_version
        'latest'
      end
    end
  end
end

Ohai.plugin(:Cloudstack) do
  provides 'cloud', 'cloud_v2', 'cloudstack'
  depends 'cloud'
  depends 'cloud_v2'

  include Ohai::Mixin::CloudstackMetadata

  # Make top-level cloud hashes
  #
  def create_objects
    cloud Mash.new
    cloud[:public_ips] = []
    cloud[:private_ips] = []
  end

  def get_cloudstack_values
    # cloud_v2
    @cloud_attr_obj.add_ipv4_addr(cloudstack['public_ipv4'], :public)
    @cloud_attr_obj.add_ipv4_addr(cloudstack['local_ipv4'], :private)
    @cloud_attr_obj.public_hostname = cloudstack['public_hostname']
    @cloud_attr_obj.local_hostname = cloudstack['local_hostname']
    @cloud_attr_obj.provider = 'cloudstack'

    # cloud
    cloud[:public_ips] << cloudstack['public_ipv4']
    cloud[:private_ips] << cloudstack['local_ipv4']
    cloud[:public_ipv4] = cloudstack['public_ipv4']
    cloud[:public_hostname] = cloudstack['public_hostname']
    cloud[:local_ipv4] = cloudstack['local_ipv4']
    cloud[:local_hostname] = cloudstack['local_hostname']
    cloud[:vm_id] = cloudstack['vm_id']
    cloud[:provider] = 'cloudstack'
  end

  collect_data do
    # Contact CloudStack metadata service & populate cloudStack/cloud/cloud_v2 Mashes
    if hint?('cloudstack')
      Ohai::Log.debug('ohai cloudstack')

      @cloud_attr_obj = CloudAttrs.new

      if can_metadata_connect?(Ohai::Mixin::CloudstackMetadata::CLOUDSTACK_METADATA_ADDR, 80)
        cloudstack Mash.new
        Ohai::Log.debug('connecting to the Cloudstack metadata service')
        fetch_metadata.each { |k, v| cloudstack[k] = v }

        cloudstack['provider'] = 'cloudstack'
        create_objects
        get_cloudstack_values

        cloud_v2 @cloud_attr_obj.cloud_mash
      else
        Ohai::Log.debug('unable to connect to the Cloudstack metadata service')
      end
    else
      Ohai::Log.debug('NOT ohai cloudstack')
    end
  end
end
