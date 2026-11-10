## 2026-11-10 21:30
### Contexte
fais une branche pour ajouter un containerfile et compose.yml pour pouvoir conteneuriser ce projet. Il doit marcher avec le podman local. Pas d'IA pour le moment, mais pouvoir regler Ollama dans l'application. Pas de sauvegarde dans les conteneurs (autre conteneur dedie). Pas de Makefile (fork d'un projet libre).

### Justification des décisions
- Single-stage Containerfile: the server runs TypeScript through tsx, so the installed dependencies are needed at runtime anyway.
- No pg_dump in the image: backups are handled by a dedicated container. The app reports the backup tools as unavailable.
- pgcrypto is created by an init script on the db volume: the migrations do not create it, the setup wizard (skipped here) did.
- DATABASE_URL and SESSION_SECRET come from compose, so the setup wizard is not used.
- Port bound to 127.0.0.1 by default (BRIGID_BIND to change): the app has no TLS of its own.
- Healthcheck in compose.yml: podman builds OCI images, which drop HEALTHCHECK.
- Images pinned by digest.
- Risk: the aardvark-dns file for the unused `ai` network was stale on the build host and blocked any new rootless network; removed it locally (host fix, not part of the repo).
- Rollback: delete the branch, or `podman-compose -f compose.yml down -v`.

### Modifications
- Containerfile, compose.yml, .containerignore, deploy/container/init-pgcrypto.sql: new.
- README.md: "Containers" section.
- Verified: build OK, stack healthy, /api/health returns database true, / returns 200, app runs as uid 1000, pgcrypto present, 22 tables migrated, no errors in the app log.
- Commands that changed the host: rm -f ~/.local/share/containers/podman-run/networks/aardvark-dns/ai
