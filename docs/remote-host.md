# Remote host operation

The reliable migration unit is the remote terminal, not a Pi session file. Keep the repository, branch, working directory, credentials, and Pi process on the remote Linux host; access it with SSH and tmux.

```bash
ssh your-server
git clone git@github.com:YOUR_ORG/your-repo.git ~/code/your-repo
cd ~/code/your-repo
./.trellis/scripts/bootstrap.sh
tmux new -A -s your-repo
pi
```

From another device:

```bash
ssh your-server
tmux attach -t your-repo
```

To resume a branch pushed from another machine:

```bash
git fetch origin
git switch prd/PRD-042-example
tmux new -A -s your-repo
```

For high-risk automation, run Pi in `ops/docker-compose.pi.yml` with the container-local `pi-agent-home` volume. Do not bind-mount the host `~/.pi/agent`, because it may contain credentials and unrelated sessions.
