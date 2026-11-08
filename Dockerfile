FROM    caddy:2.11.9-builder AS builder

RUN     xcaddy build \
            --with github.com/caddy-dns/cloudflare@v0.2.4 \
            --with github.com/greenpau/caddy-security@v1.6.2

FROM    caddy:2.11.9

COPY    --from=builder /usr/bin/caddy /usr/bin/caddy
