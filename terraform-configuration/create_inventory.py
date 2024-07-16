import json

with open('terraform.tfstate', 'r') as f:
    templates = json.load(f)

resources = templates.get('resources')

ips = {}

for res in range(len(resources)):
    try:
        ips[resources[res].get('instances')[0].get('attributes').get('name')] = resources[res].get('instances')[0].get('attributes').get('network_interface')[0].get('nat_ip_address')
    except Exception as e:
        pass

with open('../ansible-configuration/inventory/servers.yaml', 'w') as f:
    f.write(f'all:\n'
            f'  children:\n'
            f'    k8s_master:\n'
            f'      hosts:\n'
            f'        {ips.get("master")}\n'
            f'    k8s_app:\n'
            f'      hosts:\n'
            f'        {ips.get("app")}\n'
            f'    srv:\n'
            f'      hosts:\n'
            f'        {ips.get("srv")}\n')

