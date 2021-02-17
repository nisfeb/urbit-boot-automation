#!/usr/bin/env bash

#########################
# The command line help #
#########################
show_help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -n, --name      Ship name (without sig ~)"
    echo "   -t, --token     DigitalOcean token"
    echo "   -k, --key       Urbit network key"
    echo
    exit 1
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--name)
    SHIP_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--token)
    DO_TOKEN="$2"
    shift # past argument
    shift # past value
    ;;
    -k|--key)
    URBIT_KEY="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "SHIP NAME  = ${SHIP_NAME}"
echo "DO TOKEN     = ${DO_TOKEN}"
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

create_droplet() {
    # Generate SSH Key
    ssh-keygen -t rsa -b 2048 -f ./keys/$SHIP_NAME -C $SHIP_NAME -q -N ""
    # Add SSH key to your DO account and capture the reponse JSON
    key_response=$(curl -X POST https://api.digitalocean.com/v2/account/keys \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DO_TOKEN" \
        --data-binary @- <<EOF
        {
            "name": "${SHIP_NAME} key",
            "public_key": "$(cat ./keys/$SHIP_NAME.pub)"
        }
EOF
    )
    # Parse JSON reponse from key creation to get the key ID
    key_id=$(echo $key_response | jq -r '.ssh_key.id')
    # Create a Droplet that will accept connections from the provided SSH key ID
    droplet_data=$(curl -X POST https://api.digitalocean.com/v2/droplets \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${DO_TOKEN}" \
        --data-binary @- <<EOF 
        {
            "name": "${SHIP_NAME}",
            "region": "nyc3",
            "size": "s-2vcpu-4gb",
            "image": "ubuntu-20-04-x64",
            "ssh_keys": [${key_id}],
            "backups": false,
            "ipv6": true,
            "user_data": null,
            "private_networking": null,
            "volumes": null,
            "tags": ["urbit"]
        }
EOF
    )
    # Print droplet data for the created droplet
    echo $droplet_data | jq .
    # Store the droplet ID for IP query
    new_droplet_id=$(echo $droplet_data | jq .droplet.id)
    # Wait for the droplet to finish initialization
    echo "Waiting for droplet to complete initialization..."
    sleep 10s
    # Get the details for the newly created droplet
    new_droplet_details=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_TOKEN}" "https://api.digitalocean.com/v2/droplets/${new_droplet_id}") 
    # Parse the IPs of the droplet from the details. This yields internal and external IPs
    new_droplet_ips=$(echo $new_droplet_details | jq .droplet.networks.v4[].ip_address)
    # Extract the external IP from the set that includes the internal IP
    new_droplet_ip=$(echo $new_droplet_ips | awk -F '"' '{print $4}')
    # Write a new line to the Ansible hosts file with the provided data
    echo "${SHIP_NAME} ship_name=${SHIP_NAME} ship-key=${URBIT_KEY} ansible_host=${new_droplet_ip} ansible_port=22 ansible_ssh_user=root ansible_ssh_private_key_file=./keys/${SHIP_NAME}" >> ./inventory/hosts
    echo "Complete"
}

create_droplet
