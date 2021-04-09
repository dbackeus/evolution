# Evolution

## Config

`OMNIAUTH_PROXY_URL` - Set to a URL running eg. https://github.com/fs/omniauth-redirect-proxy, ensure your Google Project OAuth client accepts redirects from a URL based on this host.
`GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` - Credentials for your Google Project OAuth web client (used by devise + omniauth for sign in).
`GITHUB_APP_NAME` + `GITHUB_APP_ID` + `GITHUB_APP_PRIVATE_KEY` - Credentials for your Github App (used to integrate Github accounts and give access to repositories for cloning and data importing)

### For production

`DATABASE_URL` - Postgres URL for primary database
`CLICKHOUSE_HOST` + `CLICKHOUSE_PASSWORD` - Host and password for clickhouse server, user is assumed to be `default`

## Clickhouse

# Setup clickhouse on AWS Ubuntu

```
sudo apt-get install apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4
echo "deb https://repo.clickhouse.tech/deb/stable/ main/" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo apt-get install -y clickhouse-server clickhouse-client
```

Reconfigure

In /etc/clickhouse-server/config.xml to enable remote connection:
```
<listen_host>0.0.0.0</listen_host>
```

In users.xml to enable password:
```
# Find <default> user and set a password
```
