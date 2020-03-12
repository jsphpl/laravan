# Laravan

**Ansible Playbooks for Laravel - machine provisioning and app deployment**

Laravan is capable of preparing a fresh Ubuntu 16.04 / 18.04 machine for running laravel apps and docker containers by setting up the following components using Ansible:

- Nginx
- PHP 7.2, 7.3 & 7.4
- MariaDB 10
- PostgreSQL 11
- Beanstalkd
- Redis

It also brings some neat, optional stuff:

- Run services in docker containers and expose them via https through a reverse proxy
- Single-command deployment of Laravel applications with rollback capability
- Automatic database backups
- Free TLS certificates via letsencrypt
- Supervisor for reliably running queue workers
- Hosting of static pages and Single Page Applications

This makes Laravan a viable alternative to paid tools like Forge or Envoyer. It can also be used to implement Continuous Integration/Deployment by running the playbooks from your CI server.

## Table of Contents
- [Getting Started](#getting-started)
    - [1. Install Ansible](#1-install-ansible)
    - [2. Prepare Server](#2-prepare-server)
        - [Vagrant (optional)](#vagrant-optional)
    - [3. Install Laravan](#3-install-laravan)
    - [4. Link Machines](#4-link-machines)
    - [5. Configure Applications](#5-configure-applications)
    - [6. Configure Databases](#6-configure-databases)
    - [7. Encrypt vault](#7-encrypt-vault)
    - [8. Set ssh keys for web user](#8-set-ssh-keys-for-web-user)
    - [9. Provision](#9-provision)
    - [10. Deploy](#10-deploy)
- [Credits](#credits)
- [License](#license)

## Getting Started
### 1. Install Ansible
Ansible needs to be installed on your **local machine** from which you're going to provision your servers and deploy your Laravel apps. Install instructions: [http://docs.ansible.com/ansible/latest/intro_installation.html](http://docs.ansible.com/ansible/latest/intro_installation.html)

### 2. Prepare Server
Boot up a fresh Ubuntu 18.04 (virtual) machine. Set up ssh keys for the root user and make sure you can log in from your local machine.

The target machine needs to have `python` (v2) installed in order to be provisioned by Ansible.

#### Vagrant (optional)
A Vagrantfile is provided with laravan, so you can fire up a fresh local vm by just stating `vagrant up` from your laravan directory. You will still need to set up your ssh keys for the root user of the Vagrant box.

### 3. Install Laravan
On your local machine, run the following commands to prepare Laravan:

```bash
git clone https://github.com/jsphpl/laravan
cd laravan
./setup.sh
```

### 4. Link Machines
1. Enter the IP addresses of your hosts to the `hosts` file, each under their respective environment. If you created a vagrant machine using `vagrant up` from the laravan directory, its IP address will be `10.10.0.42`.

### 5. Configure Applications
Open up `group_vars/{env}/apps.yml` and provide the necessary information for your Laravel apps. There is an example under `group_vars/production/apps.yml` to get you started.

**Note:** in `apps.yml`, you will need to specify some "sensitive" variables that should not be entered into your VCS in plain text, eg. `env.APP_KEY`. In the example, the values reference variables in the vault, eg. `{{ vault.app_key }}`. These variables need to be assigned concrete values in the `group_vars/{env}/vault.yml`. Please refer to section *7. "Encrypt vault"* for instructions on how to encrypt your vault files.

- `myapp` (key of the dictionary items) must be replaced with a unique name for the app
- `canonical:` holds the primary domain name under which your app will be available
- `env:` those values will eventually be written into an `.env` file on the server

### 6. Configure Databases
Open up `group_vars/{env}/databases.yml` and configure the databases required for your apps. There is an example under `group_vars/production/databases.yml` to get you started.

### 7. Encrypt vault
In order to prevent your production secrets from ending up as plain text in your git repositories, use the [ansible vault](http://docs.ansible.com/ansible/latest/vault.html).

1. Create a `.vault_pass` file containing a strong password in the project root (eg. `openssl rand -base64 64 > .vault_pass`). This file is gitignored, which you should leave at all cost. Your coworkers who need to be able to provision/deploy as well, will need a copy of the file. *Send it to them by other (encrypted) means, but don't add it to your VCS!*
2. Encrypt your vault: `ansible-vault encrypt group_vars/production/vault.yml`
3. **Never again decrypt the vault!**. Use `ansible-vault view <path>` or `ansible-vault edit <path>` to open the vault file. This reduces the risk of the vault ending up plain text in your version control.

### 8. Set ssh keys for `web` user
In `group_vars/all/users.yml`, make sure to add a valid ssh public key for the `web` user. Either use the `lookup()` syntax to read a local file, or specify a http(s) url for remotely hosted public keys (eg. on github).

### 9. Provision
**Note: When using "letsencrypt" as TLS certificate provider, all domains listed under `canonical` or `redirects` must be mapped to your IP address (resolvable via public DNS) before you can successfully provision your server.**

On your local machine, run the following command, replacing `production` with the environment you want to provision (most likely `development`, `staging` or `production`).

```bash
ansible-playbook provision.yml -e env=production
```

### 10. Deploy
Again, on the local machine, run the following command to fetch your app from the git repository, install composer dependencies and run the migrations. The `app=myapp` variable refers to a key in the `group_vars/{env}/apps.yml` dictionary.

```bash
ansible-playbook deploy.yml -e env=production -e app=myapp
```

*Note: Replace `myapp` with the key that your app is listed under in the `apps` object in `group_vars/{env}/apps.yml`. Replace `production` with the environment you want to deploy to*

In case deployment fails with an error message indicating a lack of access right to the git repository, make sure that a local ssh key is authorized with the git remote of the app. There could also be a problem with with ssh agent-forwarding, which you can troubleshoot using this guide: [https://developer.github.com/v3/guides/using-ssh-agent-forwarding/](https://developer.github.com/v3/guides/using-ssh-agent-forwarding/).


## Credits
Credits to the awesome [Trellis](https://github.com/roots/trellis) project, which heavily inspired me to create Laravan and from which i copied some code and concepts.


## License
This software is released "as it is" without any warranty under the MIT licence. See [LICENSE](LICENSE) for details.
