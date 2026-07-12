# WSL2

In an elevated PowerShell:

```powershell
wsl --install
```

Install Ubuntu, clone this repository inside the Linux filesystem, and run `./.trellis/scripts/bootstrap.sh`. Keep long-running Pi sessions on a Linux host or WSL tmux session; use a self-hosted runner if WSL-specific CI is required.
