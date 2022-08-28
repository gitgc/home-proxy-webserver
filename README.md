home-proxy-webserver
====================

This project contains the software configuration for automatic deployment of [Caddy](https://caddyserver.com/) webserver/reverse-proxy used for sites hosted against my home domain.

Utilizes the [`digitalocean` Caddy plugin](https://github.com/caddy-dns/digitalocean) to allow auto-configuration of LetsEncrypt SSL for the domain name and the [`caddy-security` plugin](https://authp.github.io/) for automatic configuration of SSO/2FA via Google OAuth.

This allows easy and automated deployment of web applications or resources protected by Google Single Sign on. Once running, logged in users can see their accessible services and log out at `https://auth.$CADDY_DOMAIN`.

Requirements
------------
* Docker
* Docker Compose
* Domain name managed in [Digital Ocean DNS](https://docs.digitalocean.com/products/networking/dns/)
* User accounts/email for domain managed in [Google with OAuth API enabled](https://console.cloud.google.com/apis/credentials)

Steps
-----

Before deploying, all the environment variables declared in the `.env` file with values of `CHANGE_ME` must be replaced with valid values:

| Environment Variable   | Description                                                 |
| ---------------------- | ----------------------------------------------------------- |
| `CADDY_SUBDOMAIN`      | The subdomain to use for reverse proxy site                 |
| `CADDY_DOMAIN`         | The domain (must be under control in Digital Ocean DNS)     |
| `CADDY_PROXY_UPSTREAM` | The upstream server for the reverse proxy                   |
| `CADDY_ADMIN`          | The email address of the authentication admin user          |
| `DO_AUTH_TOKEN`        | The Digital Ocean API Key                                   |
| `GOOGLE_CLIENT_ID`     | The Google OAuth client ID                                  |
| `GOOGLE_CLIENT_SECRET` | The Google OAuth client secret                              |
| `JWT_SHARED_KEY`       | A random unique value for the authentication JWT shared key |

Then:

```console
    $ docker-compose up -d
```

This will deploy Caddy with valid SSL LetsEncrypt certificate and Google SSO/2FA access control for the site specified by `CADDY_PROXY_UPSTREAM` at `https://$CADDY_SUBDOMAIN.$CADDY_DOMAIN`. SSL is configured via the Digital Ocean public DNS management API using the provided API key. This project is able to provide valid SSL for both private and public IP ranges, allowing use for internal sites. Access is provided to any valid logged-in user from the specified Google organization.

A healthcheck endpoint of `https://$CADDY_SUBDOMAIN.$CADDY_DOMAIN/caddy-health-check` is provided and used by the example `docker-compose.yml`.

### Volumes
The following volumes are declared in the example compose file:

| Environment Variable   | Description                                               |
| ---------------------- | --------------------------------------------------------- |
| `Caddyfile`            | The [`Caddyfile`](https://caddyserver.com/docs/caddyfile) |
| `/site`                | Optional for hosting static web resources                 |
| `/caddy_data`          | Standard Caddy server volume location                     |
| `/caddy_config`        | Standard Caddy server volume location                     |

### Upstream Server
The upstream server declared by `CADDY_PROXY_UPSTREAM` can be another container in a compose stack, in which case simply take advantage of docker-compose DNS and use the service name as the upstream hostname, e.g. `http://<compose-service-name-here>:<port>`.

If the service you wish to proxy is located outside of Docker, use the appropriate IP or hostname for the upstream. If the upstream is the machine running Docker itself, note the use of the `extra_hosts` configuration in the compose file - the hostname `host.docker.internal` will forward to the Docker host machine.

Finally, if the upstream server is using a self-signed SSL certificate, add the following configuration block to allow Caddy to trust it:

    reverse_proxy {$CADDY_PROXY_UPSTREAM} {
        transport http {
            # This argument skips verification of the self-signed certificate
            tls_insecure_skip_verify
        }
    }
