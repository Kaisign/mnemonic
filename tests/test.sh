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
echo x > other.txt; git add other.txt; git commit -qm other
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

# 9. Misc
t "version" "sh '$MN' version | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'"
t "help" "sh '$MN' help | grep -q 'mn init'"
t "unknown command fails" "! sh '$MN' bogus"
t "no vendor names in generated files (adapter filename excepted)" \
  "! grep -rhi 'claude\|anthropic\|openai' AGENTS.md STATE.md memory .mnemonic/README.md | sed 's/CLAUDE\.md//g' | grep -qi 'claude\|anthropic\|openai'"

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
