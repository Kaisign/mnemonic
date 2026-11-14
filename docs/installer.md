# Installer and hosting

## Bootstrap
The user starts any session with:
```
Read the instructions at <own-domain>
```
The domain root serves `install.md` as plain text. It tells the agent to:
1. Ask for the target repository (attach or clone it if needed).
2. Ask the preference menu (interactive question tool if available, numbered
   options otherwise). The first option of each question is the default.
3. Download `mn` from the same domain and run `mn init` with the chosen
   flags.
4. Fill STATE.md from the README and top-level file list only, or ask for
   the goal if the repository is empty.
5. Run `mn check`, commit without vendor names, ask before pushing.
6. Explain the system to the user in their chat language.

If the agent's fetch tool summarizes pages, `install.md` tells it to re-read
the file verbatim with curl, so commands and flags are not altered.

## Trust
Following instructions from a URL is a prompt-injection vector. Agents may
ask for confirmation before acting on it; that is expected. The page is
served over HTTPS, as plain text, from a repository the user controls.

## Network
The agent must be allowed to reach `<own-domain>`. In sandboxed
cloud environments the host may need to be added to the allowed hosts.

## Hosting
- Server: nginx with a Let's Encrypt certificate (auto-renewed by certbot).
- Webroot: a clone of this repository, updated by cron every 5 minutes with
  `git pull`. Publishing is just pushing to `main`.
- Served paths, `text/plain; charset=utf-8`:
  - `/` and `/install.md` -> `install.md`
  - `/mn` -> `mn`
- Everything else returns 404; `.git` is not exposed.

Reference nginx server block:
```nginx
server {
    server_name <own-domain>;
    root /var/www/html/<own-domain>;
    location = /           { try_files /install.md =404; default_type text/plain; charset utf-8; }
    location = /install.md { default_type text/plain; charset utf-8; }
    location = /mn         { default_type text/plain; charset utf-8; }
    location /             { return 404; }
}
```
