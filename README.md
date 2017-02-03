# ohai-cloudstack
Ohai plugin for Cloudstack that populates the `node['cloud']` and `node['cloud_v2']` objects with VM details

It also adds a `node['cloudstack']` object with more Cloudstack specific details about the VM.

## Requirements
### Platforms
- Debian, Ubuntu
- CentOS, Red Hat
- Fedora

### Chef
- Tested with Chef 12.1+


## Usage
Add `cloudstack.rb` to your ohai plugin path, and a empty hint file `cloudstack.json` to your ohai hint path.

You can use the [ohai cookbook](https://supermarket.chef.io/cookbooks/ohai) to simplify this.

## Example ohai data

```json
{
  "cloud_v2": {
    "public_ipv4_addrs": [
      "1.2.3.4"
    ],
    "local_ipv4_addrs": [
      "10.0.0.192"
    ],
    "provider": "cloudstack",
    "public_hostname": "cs-ohai-test.example.com",
    "local_hostname": "cs-ohai-test",
    "public_ipv4": "1.2.3.4",
    "local_ipv4": "10.0.0.192"
  },
  "cloudstack": {
    "service_offering": "L Instance (2 core, 2GB)",
    "availability_zone": "CS00",
    "local_ipv4": "10.0.0.192",
    "local_hostname": "cs-ohai-test",
    "public_ipv4": "1.2.3.4",
    "public_hostname": "cs-ohai-test.example.com",
    "instance_id": "96ea54d8-eb44-46ee-aa3c-e5b911150b33",
    "vm_id": "96ea54d8-eb44-46ee-aa3c-e5b911150b33",
    "public_keys": "ssh-rsa <truncated>",
    "cloud_identifier": "CloudStack-{cfb5e0c3-fe55-40f8-be34-d3cbfabf4d71}",
    "provider": "cloudstack"
  },
  "cloud": {
    "public_ips": [
      "1.2.3.4"
    ],
    "private_ips": [
      "10.0.0.192"
    ],
    "public_ipv4": "1.2.3.4",
    "public_hostname": "cs-ohai-test.example.com",
    "local_ipv4": "10.0.0.192",
    "local_hostname": "cs-ohai-test",
    "vm_id": "96ea54d8-eb44-46ee-aa3c-e5b911150b33",
    "provider": "cloudstack"
  }
}
```

## License & Authors
**Author:** Hans Rakers ([h.rakers@global.leaseweb.com](mailto:h.rakers@global.leaseweb.com))

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
