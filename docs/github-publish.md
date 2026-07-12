# Publish this template to GitHub

1. Create an empty GitHub repository without README, license, or `.gitignore`.
2. Add the remote and push the initial branch:

```bash
git remote add origin git@github.com:YOUR_ORG/spec-driven-ai-template.git
git branch -M main
git push -u origin main
```

3. Enable branch protection on `main` and require the `verify-ubuntu` and `verify-arch-container` checks.
4. Enable secret scanning and push protection.
5. Add `OPENAI_API_KEY` only if the optional `agent-smoke` workflow is wanted.

After publishing, a new host only needs Git, the OS prerequisites, and SSH access to clone and run the bootstrap script. Replace `YOUR_ORG` in this document and `README.md` before publishing a public template.
