# File Share

Apache 2.4 in Docker, serving a folder as a browsable file listing with a custom directory-index theme.

The container listens on port 80. The host port and the shared folder are set at deploy time. With the defaults, the listing is at [http://localhost:38080](http://localhost:38080).

## Deploy

Copy the example env file and set the port and directory:

```bash
cp .env.example .env
```

```dotenv
FILESHARE_PORT=38080
FILESHARE_DIR=/path/to/files
```

Compose reads `.env` from this directory. That file is not committed. Exporting the same names in the shell overrides `.env` for one run.

```bash
docker compose up --build
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `FILESHARE_PORT` | `38080` | Host port mapped to port 80 in the container |
| `FILESHARE_DIR` | `./share` | Host directory mounted read-only at `/srv/share` |

Use an absolute path for `FILESHARE_DIR` when deploying. The listing updates on refresh.

Without Compose:

```bash
docker build -t file-share .
docker run --rm \
  -p "${FILESHARE_PORT:-38080}:80" \
  -v "${FILESHARE_DIR:-$PWD/share}:/srv/share:ro" \
  file-share
```

Apache runs as `www-data`. Files and directories need to be readable by others.

## Prebuilt image

Pushes to `main` build `linux/amd64` and `linux/arm64` images and publish them to GHCR. Pull requests build the image and do not push it.

```text
ghcr.io/wcktklwn/file-share:latest
```

Each `main` push is also tagged with its short commit SHA. A `v1.2.3` tag publishes `1.2.3` and `1.2`.

```bash
docker pull ghcr.io/wcktklwn/file-share:latest
docker run --rm \
  -p "${FILESHARE_PORT:-38080}:80" \
  -v "${FILESHARE_DIR:-$PWD/share}:/srv/share:ro" \
  ghcr.io/wcktklwn/file-share:latest
```

The package is private until its visibility is changed on GitHub. A private package needs `docker login ghcr.io` with a token that has `read:packages`.

## Listing behavior

- Clicking a file downloads it. Folders still open as listings.
- Every directory shows an index, including folders that contain `index.html`.
- Folders are listed first. Column headers change the sort.
- The listing shows the name and size. The last-modified column is omitted.
- Dotfiles, `.DS_Store`, `Thumbs.db`, and editor backups are omitted and are not served.
- Symlinks inside the share are not followed.
- The theme is served from `/_theme/` and is not part of the share.

## Layout

| Path | Purpose |
| --- | --- |
| `Dockerfile` | `httpd:2.4-alpine` image, document root `/srv/share` |
| `.github/workflows/docker-image.yml` | Build and publish the image on GitHub |
| `docker-compose.yml` | Build, `FILESHARE_PORT`, and the `FILESHARE_DIR` mount |
| `.env.example` | Deploy-time variables to copy into `.env` |
| `apache/fileshare.conf` | Directory index, icons, and access rules |
| `theme/` | Stylesheet, icons, favicon, and listing footer |
| `share/` | Sample files, replaced by the Compose volume at run time |

## Theme

`theme/style.css` styles the markup Apache `mod_autoindex` emits. Icons are SVG files in `theme/icons/`, wired up with `AddIcon` in `apache/fileshare.conf`. The footer text is `theme/footer.html`.
