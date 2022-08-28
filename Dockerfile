FROM    caddy:2.5.2-builder AS builder

RUN     xcaddy build \
            --with github.com/caddy-dns/digitalocean \
            --with github.com/greenpau/caddy-security

FROM    caddy:2.5.2

COPY    --from=builder /usr/bin/caddy /usr/bin/caddy