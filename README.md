# Simple Urbit Automation

Trivially start a DigitalOcean droplet and start an Urbit ship.

Note: This project is intended to simplify initial boot of an Urbit ship. After initial boot the user will need to manage the ship manually as normal. The playbook avoids restarting a running ship, so running multiple times will not cause an issue.

## Prerequisites

- Urbit ship name
- Urbit network key for the ship
- DigitalOcean token

## How it Works

1. `droplet_create.sh` takes the ship name and DigitalOcean token and creates a properly sized and named Droplet with a properly configured `authorized_keys` entry for Ansible to use. It then adds the ship to inventory with the correct variables.
2. `ansible-playbook -i inventory/hosts setup.yml` takes the ship configurations in inventory and sets their status.
