#!/usr/bin/env bash

#########################
# The command line help #
#########################
show_help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -n, --name      Ship name"
    echo "   -t, --token     DigitalOcean token"
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
    -t|--t)
    DO_TOKEN="$2"
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
    # Add SSH key to your DO account
    key_response="$(curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer $DO_TOKEN' -d '{"name":"${SHIP_NAME} key","public_key":"$(cat /tmp/$SHIP_NAME.pub)"}' 'https://api.digitalocean.com/v2/account/keys')"
    # Parse the SSH key ID from the HTTP reponse to the key creation call above

    # Create a Droplet that will accept connections from the provided SSH key
    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $DO_TOKEN" -d '{"name":"${SHIP_NAME}","region":"nyc3","size":"s-2vcpu-4gb","image":"ubuntu-20-04-x64","ssh_keys":[$KEY_ID],"backups":false,"ipv6":true,"user_data":null,"private_networking":null,"volumes": null,"tags":["urbit"]}' "https://api.digitalocean.com/v2/droplets" 
}
