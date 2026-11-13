# File Share

Apache 2.4 in Docker, serving a folder as a browsable file listing with a custom directory-index theme.

The container listens on port 80. Compose publishes it at [http://localhost:8080](http://localhost:8080).

## Run

```bash
docker compose up --build
```

Put files in `share/`. The listing updates on refresh. The mount is read-only inside the container.

To serve another directory, change the volume in `docker-compose.yml`:

```yaml
volumes:
  - /path/to/files:/srv/share:ro
```

Without Compose:

```bash
docker build -t file-share .
docker run --rm -p 8080:80 -v "$PWD/share:/srv/share:ro" file-share
```

Apache runs as `www-data`. Files and directories need to be readable by others.

## Listing behavior

- Every directory shows an index, including folders that contain `index.html`.
- Folders are listed first. Column headers change the sort.
- On a narrow screen the date and size columns are hidden.
- Dotfiles, `.DS_Store`, `Thumbs.db`, and editor backups are omitted and are not served.
- Symlinks inside the share are not followed.
- The theme is served from `/_theme/` and is not part of the share.

## Layout

| Path | Purpose |
| --- | --- |
| `Dockerfile` | `httpd:2.4-alpine` image, document root `/srv/share` |
| `docker-compose.yml` | Build, port `8080`, and the `share/` mount |
| `apache/fileshare.conf` | Directory index, icons, and access rules |
| `theme/` | Stylesheet, icons, favicon, and listing footer |
| `share/` | Sample files, replaced by the Compose volume at run time |

## Theme

`theme/style.css` styles the markup Apache `mod_autoindex` emits. Icons are SVG files in `theme/icons/`, wired up with `AddIcon` in `apache/fileshare.conf`. The footer text is `theme/footer.html`.
