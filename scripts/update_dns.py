import os
import requests # type: ignore
import json
import base64

def update_name_com_dns():
    username = os.getenv('NAME_COM_USERNAME')
    token = os.getenv('NAME_COM_TOKEN')
    domain = os.getenv('DOMAIN_NAME', 'brix.social')
    new_ip = os.getenv('NEW_IP')

    if not all([username, token, new_ip]):
        print(f"Missing environment variables. IP: {new_ip}, User: {username}")
        return

    # Basic Auth
    auth_str = f"{username}:{token}"
    auth_base64 = base64.b64encode(auth_str.encode()).decode()
    headers = {
        'Authorization': f'Basic {auth_base64}',
        'Content-Type': 'application/json'
    }

    # 1. Get all records
    url = f"https://api.name.com/v4/domains/{domain}/records"
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Failed to fetch records: {response.text}")
        return

    records = response.json().get('records', [])
    targets = ['', 'dev', 'api', 'www']  # '' is for root domain brix.social

    for target in targets:
        # Find record ID for host
        record = next((r for r in records if r.get('host') == target and r.get('type') == 'A'), None)
        if record:
            record_id = record['id']
            print(f"Updating {target}.{domain} (ID: {record_id}) to {new_ip}...")

            update_url = f"https://api.name.com/v4/domains/{domain}/records/{record_id}"
            data = {
                "host": target,
                "type": "A",
                "answer": new_ip,
                "ttl": 300
            }
            update_res = requests.put(update_url, headers=headers, json=data)
            if update_res.status_code == 200:
                print(f"Successfully updated {target}.")
            else:
                print(f"Failed to update {target}: {update_res.text}")
        else:
            print(f"Record for {target}.{domain} not found.")

if __name__ == "__main__":
    update_name_com_dns()
