# Cloud-1 – Ansible Playbook for a Dockerised WordPress Stack
Cloud-1 is an **idempotent Ansible playbook** that turns a brand-new
Linux host into a production-ready WordPress server in a matter of
minutes.
It installs Docker & Docker Compose, builds custom Nginx / PHP-FPM /
WordPress images, provisions an SSL-enabled virtual host and starts
the complete stack with `docker-compose`.

Typical use-case
• You have a fresh Debian / Ubuntu VPS (or several) with SSH access.
• You want WordPress behind Nginx, secured with TLS, running in
containers, managed by code.
• You run one command and go grab a coffee ☕.

---

## Key Features
* **One-shot provisioning** – from OS to running WordPress
(`ansible-playbook playbook.yml`).
* **Docker Engine & Docker Compose** installed by the `docker_install` role.
* **Custom containers**
  * `wp_Dockerfile` – hardened PHP-FPM + WordPress + CLI.
  * `nginx_Dockerfile` – Nginx with HTTP/2 and TLS.
* **TLS out of the box** – self-signed certificate and key shipped
(`certificate.crt`, `private.key`). You can replace them with Let’s
Encrypt or company certs.
* **Config templating** – Nginx vhost, `wp-config.php`,
`docker-compose.yml` generated from Jinja templates and populated with
your variables.
* **Fully configurable** through `defaults/main.yml` & `vars/main.yml`
(domain, DB creds, admin account, paths…).
* **Idempotent & repeatable** – run again and only drift will be fixed.
* **Multihost capable** – inventory file already provided.

---

## Quick Start

### 1. Requirements on your control machine

| Software      | Minimum version | Why                             |
|---------------|-----------------|---------------------------------|
| Ansible       | 2.12            | Playbook language               |
| Python        | 3.6             | Ansible runtime                 |
| SSH client    | —               | Transport to hosts              |
| Git           | —               | Clone this repo                 |

### 2. Clone the repository
```bash
git clone https://github.com/<your-org>/cloud-1.git
cd cloud-1
```

### 3. Configure your inventory
Edit the `hosts` file:

```ini
[wordpress]
wp01 ansible_host=203.0.113.10  ansible_user=root
```

### 4. (Optional) Override defaults
All tunables live in `roles/wordpress_install/defaults/main.yml`.
Typical things to change:

```yaml
# WordPress
wp_site_title: "ACME Blog"
wp_admin_user: "admin"
wp_admin_password: "S3cureP@ssw0rd"
wp_admin_email: "admin@example.com"
wp_url: "https://blog.example.com"

# Database
db_root_password: "rootpass"
db_name: "wordpress"
db_user: "wp_user"
db_password: "wp_db_pass"

# Nginx / TLS
server_name: "blog.example.com"
tls_certificate_path: "/etc/ssl/certs/certificate.crt"
tls_key_path: "/etc/ssl/private/private.key"
```

Alternatively create a **host- or group-vars file** to keep Git history clean.

### 5. Run the playbook
```bash
ansible-playbook -i hosts playbook.yml
```

After a few minutes browse to `https://blog.example.com` – WordPress
is online 🎉.

---

## Usage Guide & Everyday Operations

Action | Command
-------|---------
Re-apply configuration | `ansible-playbook -i hosts playbook.yml`
SSH into the container host | `ssh root@wp01`
List running containers | `docker ps`
Update WordPress core/plugins/themes | `docker exec -it wordpress wp
core update`

---

## Configuration Details

Role: **docker_install**
• Installs official Docker Engine repository, Docker CLI, containerd
and docker-compose plugin.
• Enables and starts `docker.service`.

Role: **wordpress_install**
Directory | Purpose
----------|---------
`defaults/` | Safe defaults, can be overridden.
`vars/`    | Mandatory variables that shouldn’t drift (e.g. local paths).
`files/`   | Static assets – certificate, CSR, keys, pool configuration.
`templates/` | Jinja2 templates for dynamic
assets.<br>`docker-compose.yml.j2` spins up: `nginx`, `wordpress`,
`db` (MariaDB) & `php-fpm`.<br>`apitoise.rature.fr.conf.j2` becomes
Nginx vhost.<br>`wp-config.php.j2` injects DB creds &
salts.<br>`wp_install.sh.j2` initialises WordPress via CLI.
`tasks/main.yml` | Orchestrates directory creation, image build,
template rendering and `docker compose up -d`.

Important variable catalogue
Variable | Description | Default
---------|-------------|--------
`server_name` | Public FQDN of the site | `apitoise.rature.fr`
`wp_site_title` | Title appearing in WP | `Ansible - WordPress`
`db_name`, `db_user`, `db_password` | MySQL/MariaDB credentials | see file
`tls_certificate_path`, `tls_key_path` | Location of certificate and
key on host | paths inside `/etc/ssl`

---

## Project Structure

```
cloud-1/
├── ansible.cfg            # Ansible defaults (retry, roles_path…)
├── hosts                  # Inventory
├── playbook.yml           # Entry point
└── roles
    ├── docker_install
    │   └── tasks
    │       └── main.yml
    └── wordpress_install
        ├── defaults/
        ├── files/
        ├── tasks/
        ├── templates/
        └── vars/
```

---

## “API” – Variables & Templates
Although no HTTP API ships with the repo, the **variable interface**
is the public surface you are expected to interact with.
Every variable listed in `defaults/main.yml` is documented inline and
should be considered the user API. They feed directly into:

* `docker-compose.yml.j2` – container topology, image tags, volumes, ports.
* `wp-config.php.j2` – salts, DB creds, debugging flags.
* `apitoise.rature.fr.conf.j2` – Nginx server block, HTTP/2, gzip,
cache headers.

Changing a variable and re-running the playbook is sufficient;
containers are recreated as needed.

---

## Contributing

1. Fork the project and create your feature branch (`git checkout -b
feature/my-new-feature`).
2. Commit your changes with clear messages.
3. Ensure `ansible-lint` and `yamllint` pass (`pip install -r
requirements-dev.txt`).
4. Submit a Pull Request.

Please follow the [Ansible
best-practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
for directory layout and module usage.

---

## License
Cloud-1 is released under the **MIT License**.
See the [LICENSE](LICENSE) file for full text.

---

## Acknowledgements
* Ansible Core team
* Docker & WordPress open-source communities
