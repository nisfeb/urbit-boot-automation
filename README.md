# Simple Urbit Automation

Trivially start a DigitalOcean droplet and start an Urbit planet.

WARNING: This script could result in the need for a breach if misused or if you hit an unknown bug. Use carefully.

This project is intended to simplify initial boot of an Urbit planet. After initial boot the user will need to manage the planet manually as normal. The playbook avoids restarting a running planet, so running multiple times should not cause an issue.

## Prerequisite

- Urbit [planet name](https://urbit.live/)
- Urbit [network key](https://bridge.urbit.org/) for the planet
- [DigitalOcean token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)

## How it Works

1. `./droplet_create.sh -n PLANET_NAME -t DIGITAL_OCEAN_TOKEN -k URBIT_NETWORK_KEY` takes the planet name, network key, and DigitalOcean token and creates a properly sized and named Droplet with a properly configured `authorized_keys` entry for Ansible to use. It then adds the planet to inventory with the correct variables. If you want to SSH into the host, you can use the keys that are generated and placed in the `keys` directory. _This script currently starts a default droplet and does not harden the server with additional security settings._
2. `ansible-playbook -i inventory/hosts setup.yml` uses the settings in `inventory/hosts` to boot each planet if it has not yet been booted. If you get an error like `Failed to connect to the host via ssh` wait a moment and run the playbook again. The Droplet may just not be fully initiailized.

## Contributing

WARNING: The `droplet_create.sh` script adds server details to the `inventory/hosts` file. This data should _not_ be pushed into a public repository. Ensure that you remove this information before creating a PR or pushing to a public fork.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
