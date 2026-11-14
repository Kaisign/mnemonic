#!/bin/sh
# Test suite for mn. Usage: sh tests/test.sh
set -u
MN="$(cd "$(dirname "$0")/.." && pwd)/mn"
pass=0 fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); printf 'FAIL %s\n' "$*"; }
t()   { if eval "$2" >/dev/null 2>&1; then ok; else bad "$1"; fi; }

new_repo() {
  d=$(mktemp -d); cd "$d" || exit 1
  git init -q; git config user.name t; git config user.email t@t
}

# 1. Fresh install
new_repo
sh "$MN" init --chat-lang es >/dev/null
for f in AGENTS.md CLAUDE.md STATE.md memory/INDEX.md .mnemonic/mn .mnemonic/README.md README.md; do
  t "init creates $f" "[ -f $f ]"
done
t "chat_lang applied" "grep -q '^- chat_lang: es' AGENTS.md"
t "CLAUDE.md imports AGENTS" "grep -qx '@AGENTS.md' CLAUDE.md"
t "CLAUDE.md imports STATE" "grep -qx '@STATE.md' CLAUDE.md"
t "protocol has automatic memory lookup" "grep -q 'STATE.md does not have' AGENTS.md"
t "installed mn is executable" "[ -x .mnemonic/mn ]"
git add -A && git commit -qm init
t "check passes on fresh install" "sh .mnemonic/mn check"

# 2. Re-init replaces only the marked block and keeps user files
echo "user STATE" > STATE.md
printf '\nUser rule outside block\n' >> AGENTS.md
sh "$MN" init --tone formal >/dev/null
t "re-init keeps STATE.md" "grep -qx 'user STATE' STATE.md"
t "re-init keeps user content" "grep -q 'User rule outside block' AGENTS.md"
t "re-init updates prefs" "grep -q '^- tone: formal' AGENTS.md"
t "single marked block" "[ \$(grep -c 'mnemonic:begin' AGENTS.md) -eq 1 ]"
t "no duplicate imports" "[ \$(grep -cx '@STATE.md' CLAUDE.md) -eq 1 ]"
t "README section not duplicated" "[ \$(grep -c '.mnemonic/README.md' README.md) -eq 1 ]"

# 3. Merge into existing AGENTS.md, CLAUDE.md and README.md
new_repo
printf '# Project rules\nUse tabs.\n' > AGENTS.md
printf 'Existing instructions\n' > CLAUDE.md
printf '# My project\nIntro.\n' > README.md
sh "$MN" init >/dev/null
t "existing AGENTS.md kept" "grep -q 'Use tabs.' AGENTS.md"
t "block appended" "grep -q 'mnemonic:begin' AGENTS.md"
t "existing CLAUDE.md kept" "grep -q 'Existing instructions' CLAUDE.md"
t "existing README kept" "grep -q '^# My project' README.md"
t "README section appended" "grep -q '.mnemonic/README.md' README.md"

# 4. Invalid options fail without writing
new_repo
t "invalid option rejected" "! sh '$MN' init --commits weird"
t "nothing written on invalid option" "[ ! -f AGENTS.md ]"
t "unknown agent rejected" "! sh '$MN' init --agents other"

# 5. check detects problems
new_repo
sh "$MN" init >/dev/null
git add -A && git commit -qm init
awk '{print} /^## Current/{for(i=0;i<6;i++) print "- item " i}' STATE.md > s && mv s STATE.md
t "cap violation detected" "! sh .mnemonic/mn check"
t "cap violation reported" "sh .mnemonic/mn check | grep -q 'section Current'"
sh "$MN" init >/dev/null; git checkout -q STATE.md
MN_MAX_TOKENS=10 sh .mnemonic/mn check >/dev/null 2>&1; t "token budget enforced" "[ $? -ne 0 ]"
echo x > other.txt; git add other.txt; MN_SKIP=1 git commit -qm other
t "staleness detected" "sh .mnemonic/mn check | grep -q 'not updated in the last 1'"

# 6. Memory commands
new_repo
sh "$MN" init >/dev/null
t "mem add" "sh .mnemonic/mn mem add auth 'login jwt' 'Auth design'"
t "mem add creates file" "[ -f memory/auth.md ]"
t "mem add rejects duplicate" "! sh .mnemonic/mn mem add auth 'x' 'y'"
t "mem add rejects bad name" "! sh .mnemonic/mn mem add 'a b' 'x' 'y'"
t "mem add rejects INDEX" "! sh .mnemonic/mn mem add INDEX 'x' 'y'"
t "mem find hit" "sh .mnemonic/mn mem find JWT | grep -q auth"
t "mem find multi-word" "sh .mnemonic/mn mem find nothing login | grep -q auth"
t "mem find miss" "! sh .mnemonic/mn mem find payments"
t "mem show" "sh .mnemonic/mn mem show auth | grep -q '^# auth'"
git add -A && git commit -qm mem
t "check passes with memory" "sh .mnemonic/mn check"
rm memory/auth.md
t "missing topic file detected" "sh .mnemonic/mn check | grep -q 'index entry without file'"
sh .mnemonic/mn mem add db 'postgres' 'DB' >/dev/null; sed -i '/^- db:/d' memory/INDEX.md
t "unindexed topic detected" "sh .mnemonic/mn check | grep -q 'topic not in index'"

# 7. Preferences persist across re-init
new_repo
sh "$MN" init --chat-lang es --tone formal >/dev/null
sh "$MN" init >/dev/null
t "re-init without flags keeps prefs" "grep -q '^- chat_lang: es' AGENTS.md && grep -q '^- tone: formal' AGENTS.md"
t "config saved" "grep -qx 'chat_lang=es' .mnemonic/config"
t "cache ignored by git" "grep -qx '.mnemonic/cache/' .gitignore"

# 7b. Migration from installs without config
new_repo
sh "$MN" init --chat-lang es >/dev/null; rm .mnemonic/config
sh "$MN" init >/dev/null
t "languages recovered without config" "grep -q '^- chat_lang: es' AGENTS.md"

# 8. Shared memory: two sessions in different repos, one hub
hub=$(mktemp -d)/hub.git; git init -q --bare -b main "$hub"
new_repo; A=$d
sh "$MN" init >/dev/null
t "link creates submonic" "sh .mnemonic/mn sub link infra '$hub#infra' 'servers and domains'"
t "AGENTS lists submonic" "grep -q '^- infra: servers and domains' AGENTS.md"
t "AGENTS has shared section" "grep -q '^## Shared memory' AGENTS.md"
t "hub has index" "git --git-dir='$hub' show HEAD:infra/INDEX.md"
t "hub has README" "git --git-dir='$hub' show HEAD:README.md"
t "duplicate link rejected" "! sh .mnemonic/mn sub link infra '$hub#infra'"
t "sub add" "sh .mnemonic/mn sub add infra web01 'server ip nginx' 'Main VPS'"
t "topic pushed to hub" "git --git-dir='$hub' show HEAD:infra/web01.md | grep -q '^# web01'"
t "hub commits use repo author" "[ \"\$(git --git-dir='$hub' log -1 --format=%an)\" = t ]"

new_repo; B=$d
sh "$MN" init >/dev/null
sh .mnemonic/mn sub link infra "$hub#infra" "servers and domains" >/dev/null
t "other session finds topic" "sh .mnemonic/mn sub find nginx | grep -q 'infra/web01'"
t "other session reads topic" "sh .mnemonic/mn sub show infra/web01 | grep -q 'Main VPS'"
echo "- webroot: /var/www/site" >> "$(sh .mnemonic/mn sub path infra)/web01.md"
t "save edits" "sh .mnemonic/mn sub save infra 'Add webroot'"
t "edit reached hub" "git --git-dir='$hub' show HEAD:infra/web01.md | grep -q webroot"

cd "$A"
t "concurrent add (stale cache) rebases" "sh .mnemonic/mn sub add infra dns 'domain records' 'DNS setup'"
t "both writes in hub" "git --git-dir='$hub' show HEAD:infra/web01.md | grep -q webroot && git --git-dir='$hub' show HEAD:infra/INDEX.md | grep -q '^- dns:'"
t "find miss" "! sh .mnemonic/mn sub find payments"
t "list shows topics" "sh .mnemonic/mn sub list | grep -q '2 topics'"
t "second submonic in same hub" "sh .mnemonic/mn sub link profile '$hub#profile' 'user preferences'"
t "single clone for both" "[ \$(ls .mnemonic/cache | wc -l) -eq 1 ]"
t "unlink" "sh .mnemonic/mn sub unlink profile && ! grep -q '^- profile:' AGENTS.md"
t "unknown submonic rejected" "! sh .mnemonic/mn sub show nope/x"
t "cache not tracked" "git add -A && ! git status --porcelain | grep -q cache"

# 10. Automation: hooks, archive, status (strict mode)
new_repo
sh "$MN" init --enforce strict >/dev/null
t "pre-commit hook installed" "[ -x .mnemonic/hooks/pre-commit ]"
t "git hooks enabled" "[ \"\$(git config core.hooksPath)\" = .mnemonic/hooks ]"
t "agent settings created" "grep -q 'mn hook start' .claude/settings.json && grep -q 'mn hook stop' .claude/settings.json"
git add -A && git commit -qm init
echo code > app.js; git add app.js
t "commit without STATE.md rejected" "! git commit -qm work"
t "MN_SKIP bypasses" "MN_SKIP=1 git commit -qm work"
t "stop hook blocks after unreflected commit" "echo '{}' | sh .mnemonic/mn hook stop | grep -q '\"decision\":\"block\"'"
t "stop hook respects stop_hook_active" "[ -z \"\$(echo '{\"stop_hook_active\": true}' | sh .mnemonic/mn hook stop)\" ]"
echo more >> app.js; sed -i 's/^updated: .*/updated: 2026-01-01/' STATE.md; git add app.js STATE.md
t "commit with STATE.md accepted" "git commit -qm work2"
t "stop hook quiet when state current" "[ -z \"\$(echo '{}' | sh .mnemonic/mn hook stop)\" ]"
awk '{print} /^## Current/{for(i=0;i<6;i++) print "- item " i}' STATE.md > s && mv s STATE.md; echo x >> app.js; git add -A
t "pre-commit runs mn check (caps)" "! git commit -qm caps"
git checkout -q HEAD -- STATE.md app.js
t "session start hook is quiet when clean" "[ -z \"\$(sh .mnemonic/mn hook start)\" ]"
git config --unset core.hooksPath; sh .mnemonic/mn hook start >/dev/null
t "session start re-enables git hooks" "[ \"\$(git config core.hooksPath)\" = .mnemonic/hooks ]"
sh .mnemonic/mn mem add old 'legacy' 'Old notes' >/dev/null; sed -i 's/^updated: .*/updated: 2020-01-01/' memory/old.md
t "stale topic reported" "sh .mnemonic/mn check | grep -q 'topic old not updated since 2020-01-01'"
t "archive" "sh .mnemonic/mn archive old"
t "archived file kept" "[ -f memory/archive/old.md ] && ! grep -q '^- old:' memory/INDEX.md"
t "status summary" "sh .mnemonic/mn status | grep -q 'automation:  git pre-commit on (strict mode), agent session hooks on'"
new_repo
mkdir .claude; echo '{"permissions": {"allow": ["Bash(ls)"]}}' > .claude/settings.json
sh "$MN" init >/dev/null
t "existing agent settings merged" "grep -q 'Bash(ls)' .claude/settings.json && grep -q 'mn hook stop' .claude/settings.json"
t "merge is idempotent" "sh '$MN' init >/dev/null && [ \$(grep -c 'mn hook stop' .claude/settings.json) -eq 1 ]"

# 11. Everything in one repo: in-repo submonics, linked from another repo
origin=$(mktemp -d)/proj.git; git init -q --bare -b main "$origin"
new_repo; P=$d; git remote add origin "$origin"
sh "$MN" init >/dev/null
t "artifacts folder created" "[ -f artifacts/README.md ]"
git add -A && git commit -qm init && git push -q -u origin HEAD:main 2>/dev/null
t "self link" "sh .mnemonic/mn sub link infra self 'servers and domains'"
t "self submonic committed" "git log -1 --format=%s | grep -q 'Create submonic infra' && [ -f shared/infra/INDEX.md ]"
t "self add" "sh .mnemonic/mn sub add infra web01 'server ip nginx' 'Main VPS'"
t "self find" "sh .mnemonic/mn sub find nginx | grep -q 'infra/web01'"
echo "- webroot: /srv/site" >> shared/infra/web01.md
t "self save without STATE.md passes hook" "sh .mnemonic/mn sub save infra 'Add webroot'"
t "no cache for self" "[ ! -d .mnemonic/cache ]"
git push -q origin HEAD:main 2>/dev/null
new_repo
sh "$MN" init >/dev/null
t "other repo links in-repo submonic" "sh .mnemonic/mn sub link infra '$origin#shared/infra' 'servers'"
t "other repo finds topic" "sh .mnemonic/mn sub find webroot nginx | grep -q 'infra/web01'"
t "other repo reads edit" "sh .mnemonic/mn sub show infra/web01 | grep -q webroot"

# 12. Task mode (default), off mode, cache-expiry prompt hook, economy rules
new_repo
sh "$MN" init >/dev/null
t "default enforce is task" "grep -qx 'enforce=task' .mnemonic/config && grep -q '^- state_updates: rewrite STATE.md when a task ends' AGENTS.md"
t "economy rules in protocol" "grep -q '^## Session economy' AGENTS.md"
t "prompt hook installed" "grep -q 'mn hook prompt' .claude/settings.json"
git add -A && git commit -qm init
echo 1 > a.txt; git add a.txt
t "task: 1st work commit allowed" "git commit -qm w1"
echo 2 > a.txt; git add a.txt
t "task: 2nd work commit allowed" "git commit -qm w2"
t "task: stop hook quiet below limit" "[ -z \"\$(echo '{}' | sh .mnemonic/mn hook stop)\" ]"
echo 3 > a.txt; git add a.txt
t "task: 3rd work commit blocked" "! git commit -qm w3"
sed -i 's/^updated: .*/updated: 2026-02-02/' STATE.md; git add STATE.md a.txt
t "task: commit with STATE.md resets" "git commit -qm w3s"
MN_SKIP=1 git commit -q --allow-empty -m e1; MN_SKIP=1 git commit -q --allow-empty -m e2; MN_SKIP=1 git commit -q --allow-empty -m e3
t "task: stop hook blocks at limit" "echo '{}' | sh .mnemonic/mn hook stop | grep -q 'decision'"
t "last-turn recorded" "[ -f .mnemonic/cache/last-turn ]"
big=$(mktemp); head -c 600000 /dev/zero | tr '\0' 'x' > "$big"
echo $(( $(date +%s) - 7200 )) > .mnemonic/cache/last-turn
t "prompt hook warns after idle gap" "echo '{\"transcript_path\": \"'$big'\"}' | sh .mnemonic/mn hook prompt | grep -q 'prompt cache has expired'"
t "prompt hook warns once per gap" "[ -z \"\$(echo '{\"transcript_path\": \"'$big'\"}' | sh .mnemonic/mn hook prompt)\" ]"
small=$(mktemp); echo x > "$small"; echo $(( $(date +%s) - 7200 )) > .mnemonic/cache/last-turn
t "prompt hook quiet for short conversations" "[ -z \"\$(echo '{\"transcript_path\": \"'$small'\"}' | sh .mnemonic/mn hook prompt)\" ]"
date +%s > .mnemonic/cache/last-turn
t "prompt hook quiet when recent" "[ -z \"\$(echo '{\"transcript_path\": \"'$big'\"}' | sh .mnemonic/mn hook prompt)\" ]"
sh "$MN" init --enforce off >/dev/null
for i in 1 2 3 4; do echo $i > b.txt; git add b.txt; git commit -qm "o$i" || break; done
t "off: never blocks" "[ \$(git log --format=%s | grep -c '^o') -eq 4 ]"
t "invalid enforce rejected" "! sh '$MN' init --enforce maybe"
new_repo; mkdir .claude; echo '{"hooks": {"Stop": [{"hooks": [{"type": "command", "command": "sh .mnemonic/mn hook stop"}]}]}}' > .claude/settings.json
sh "$MN" init >/dev/null
t "upgrade adds missing hook events only" "grep -q 'mn hook prompt' .claude/settings.json && [ \$(grep -c 'mn hook stop' .claude/settings.json) -eq 1 ]"

# 13. Start link
new_repo
sh "$MN" init >/dev/null
t "status without remote explains" "sh .mnemonic/mn status | grep -q 'set a git remote'"
git remote add origin https://github.com/acme/widgets.git
t "start link from https remote" "sh .mnemonic/mn status | grep -q 'start?repo=acme/widgets\$'"
git remote set-url origin git@github.com:acme/gadgets.git
t "start link from ssh remote" "sh .mnemonic/mn status | grep -q 'start?repo=acme/gadgets\$'"
git remote set-url origin http://127.0.0.1:9999/git/acme/tools
t "start link from proxied remote" "sh .mnemonic/mn status | grep -q 'start?repo=acme/tools\$'"

# 14. Git author and publish
origin=$(mktemp -d)/pub.git; git init -q --bare -b main "$origin"
new_repo; git remote add origin "$origin"; git config user.name Bot; git config user.email bot@vendor.test
t "author pair required" "! sh '$MN' init --author-name 'Ana'"
t "invalid email rejected" "! sh '$MN' init --author-name Ana --author-email nope"
sh "$MN" init --author-name 'Ana Dev' --author-email ana@example.test >/dev/null
t "author applied to clone" "[ \"\$(git config user.name)\" = 'Ana Dev' ] && [ \"\$(git config user.email)\" = ana@example.test ]"
t "author saved in config" "grep -qx 'author_email=ana@example.test' .mnemonic/config"
t "status shows author" "sh .mnemonic/mn status | grep -q 'git author:  Ana Dev <ana@example.test>'"
t "publish commits and pushes" "sh .mnemonic/mn publish | grep -q 'pushed to origin'"
t "first commit has configured author" "[ \"\$(git --git-dir='$origin' log -1 --format='%an <%ae>' 2>/dev/null || git log -1 --format='%an <%ae>')\" = 'Ana Dev <ana@example.test>' ]"
t "publish idempotent" "sh .mnemonic/mn publish | grep -q 'nothing to commit'"
git config user.name Bot; git config user.email bot@vendor.test
echo x > w.txt; git add w.txt
t "hook rejects foreign author once" "! git commit -qm w"
t "hook restored author" "[ \"\$(git config user.name)\" = 'Ana Dev' ]"
t "retried commit passes with right author" "git commit -qm w && [ \"\$(git log -1 --format=%an)\" = 'Ana Dev' ]"
git config --unset user.name; git config --unset user.email; sh .mnemonic/mn hook start >/dev/null
t "session start re-applies author" "[ \"\$(git config user.email)\" = ana@example.test ]"

# 9. Misc
t "version" "sh '$MN' version | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'"
t "help" "sh '$MN' help | grep -q 'mn init'"
t "unknown command fails" "! sh '$MN' bogus"
t "no vendor names in generated files (adapter filename excepted)" \
  "! grep -rhi 'claude\|anthropic\|openai' AGENTS.md STATE.md memory .mnemonic/README.md | sed 's/CLAUDE\.md//g; s/\.claude\///g' | grep -qi 'claude\|anthropic\|openai'"

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
