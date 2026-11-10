## 2026-11-10 22:40
### Contexte
Portainer stack (pasted in the web editor, not pulled from git) failed: "dependency failed to start: container brigid-db-1 is unhealthy". Request: go on with the fix.

### Justification des décisions
- Cause (Portainer API, GET only): the relative bind mount ./deploy/container/init-pgcrypto.sql does not exist on the host when the stack is pasted in the editor, Docker created a directory, and postgres failed with "could not read from input file: Is a directory". The db restarted but the depends_on window was over.
- pgcrypto is not needed: the schema only uses gen_random_uuid(), built in since PostgreSQL 13 (the pgcrypto creation in the setup wizard is a belt-and-braces for older servers). The init script and its mount are removed.
- Alternative kept out: an inline init command in compose.yml. Useless once the extension is not required.
- Checked: stack started locally without the mount, both containers healthy, /api/health database true, 22 tables, gen_random_uuid() works.
- Rollback: revert the merge commit.

### Modifications
- deploy/container/init-pgcrypto.sql: deleted.
- compose.yml: bind mount of the init script removed.

