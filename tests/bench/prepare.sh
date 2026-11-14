#!/bin/sh
# Build isolated workspaces for the benchmark and print one prompt per run.
# Usage: sh tests/bench/prepare.sh [out-dir]
set -eu
here=$(cd "$(dirname "$0")" && pwd)
out=${1:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)

for s in "$here"/s*-*/; do
  s=$(basename "$s")
  for c in without with; do
    w="$out/$s/$c"
    rm -rf "$w"; mkdir -p "$w"
    cp -R "$here/$s/$c/." "$w/"
    cp "$here/$s/questions.md" "$w/"
    if [ "$c" = with ]; then
      cat > "$w/AGENTS.md" <<'EOF'
Project memory (mnemonic): STATE.md is the current project state; read it first.
Long-term memory: memory/INDEX.md lists topics. Open a topic file only if a question needs it.
Do not read anything else.
EOF
    else
      cat > "$w/AGENTS.md" <<'EOF'
No project memory. The previous session transcript is transcript.md.
EOF
    fi
  done
done

echo "workspaces: $out"
echo
for w in "$out"/s*-*/*/; do
  w=${w%/}
  printf -- '--- %s\n' "${w#"$out"/}"
  cat <<EOF
Resume work on a project in the workspace $w.
Read $w/AGENTS.md first and follow it. Read only files inside that workspace.
Answer every question in $w/questions.md. Write $w/answers.txt with exactly one line per question, format "Q1: <short answer>". No other text in that file.
Then reply with one line only: "files read: <comma-separated file names>".
EOF
  echo
done
