# Notes App

Notes App is a simple application intended for use as a lightweight base for various demos. It's implemented in the [Sinatra](https://sinatrarb.com/) framework, and faithfully applies Xpirit's branding in the UI.

## Running Notes App

The easiest way to run Notes App is with Docker. 

To run Notes App with Azure SQL Edge (via Docker Compose): 

```
docker-compose up
```

To run Notes App standalone:

```
docker run -it -p 80:80 ghcr.io/xpiritbv/notes-app:latest
```

After starting up with the above command, Notes App will be available at [http://localhost/](http://localhost/).

## Configuration

By default, Notes App will use a local sqlite database file within the container. However, you may override this and use a DBMS of your choice. Notes App will configure the appropriate settings in `database.yml` with your specified values. 

| Environment Variable | Description |
|---|---|
| `DB_ADAPTER` | database.yml: `<environment>.adapter`  |
| `DB_HOST`  | database.yml: `<environment>.host`  | 
| `DB_PORT`  | database.yml: `<environment>.port` |  
| `DB_DATABASE` | database.yml: `<environment>.database` |
| `DB_USERNAME` | database.yml: `<environment>.username`  |
| `DB_PASSWORD` | database.yml: `<environment>.password`  |
| `BIND_ADDRESS` | Defaults to `0.0.0.0`  |
| `BIND_PORT` | Defaults to `80`  |

Alternatively, you may specify a Rails database connection string in `DATABASE_URL`. The existing database yaml configuration will be overridden by this value ([docs](https://guides.rubyonrails.org/v4.1/configuring.html#connection-preference)).

**Note:** Unless `NOTES_ENV` is specified, the default environment is `development`.

## Releasing New Versions

This repository contains a [GitHub Action](https://github.com/XpiritBV/notes-app/blob/master/.github/workflows/publish.yml) which builds and publishes the Notes App container to [GHCR](https://github.com/XpiritBV/notes-app/pkgs/container/notes-app) whenever a new release is tagged.
