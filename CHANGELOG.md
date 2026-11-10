## 2026-11-10 22:10
### Contexte
Portainer, stack from a remote git repo, failed: "compose build operation failed: mkdir /.docker: permission denied". Request: publish the image on GitHub, public package, built on every push to main.

### Justification des décisions
- Portainer runs docker compose build inside its own container, where HOME is not writable: building there is fragile. The image is built by GitHub Actions and pulled by Portainer.
- ghcr.io, public package (chosen by the user): Portainer pulls without credentials. The package is created private by GitHub and must be switched to public once in Package settings.
- The workflow only calls .github/build-image.sh, which also runs locally (build only without GHCR_TOKEN).
- compose.yml has no build block any more: with both image and build, a deployment tool could retry a build. The local build is in compose.build.yml.
- Trigger: push to main (chosen by the user); BRIGID_TAG pins a 12-character commit.
- Risk: the workflow was not run on GitHub (it only triggers on main). Checked locally: bash -n, shellcheck, YAML parse, podman-compose config on both files, script build with tags and source label.
- Rollback: revert the merge commit; compose.yml then builds locally again.

### Modifications
- .github/build-image.sh, .github/workflows/image.yml, compose.build.yml: new.
- compose.yml: image ghcr.io/pierrehenrymuller/brigid:${BRIGID_TAG:-latest}, build block removed.
- README.md: Containers section updated.

