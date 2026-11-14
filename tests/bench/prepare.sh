#!/bin/sh
# Build isolated workspaces for the benchmark and print one prompt per run.
# Usage: sh tests/bench/prepare.sh [out-dir] [--pad <tokens>]
#   --pad N  lengthen each transcript to ~N tokens by interleaving neutral
#            side conversations (filler.md) between the original turns.
#            Facts and their order are unchanged; STATE.md is unchanged.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
out="" pad=0
while [ $# -gt 0 ]; do
  case "$1" in
    --pad) pad=${2:?missing value for --pad}; shift 2 ;;
    *) out=$1; shift ;;
  esac
done
[ -n "$out" ] || out=$(mktemp -d)
mkdir -p "$out"
out=$(cd "$out" && pwd)

pad_transcript() {
  # pad_transcript <file> <target-tokens>: rewrite file in place.
  awk -v target="$2" -v fill="$here/filler.md" '
    BEGIN {
      nb = 1
      while ((getline l < fill) > 0) {
        if (l == "%%") { nb++; continue }
        blk[nb] = blk[nb] l "\n"
      }
    }
    { line[++n] = $0; len += length($0) + 1; if ($0 ~ /^USER:/) users++ }
    END {
      need = target * 4 - len; gaps = users - 1
      if (need <= 0 || gaps < 1) { for (i = 1; i <= n; i++) print line[i]; exit }
      u = 0; emitted = 0; k = 0
      for (i = 1; i <= n; i++) {
        if (line[i] ~ /^USER:/) {
          u++
          if (u > 1) {
            goal = need * (u - 1) / gaps
            while (emitted < goal) {
              b = blk[(k % nb) + 1]; k++
              gsub(/\{n\}/, 100 + k, b)
              printf "%s\n", b; emitted += length(b) + 1
            }
          }
        }
        print line[i]
      }
    }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

for s in "$here"/s*-*/; do
  s=$(basename "$s")
  for c in without with; do
    w="$out/$s/$c"
    rm -rf "$w"; mkdir -p "$w"
    cp -R "$here/$s/$c/." "$w/"
    cp "$here/$s/questions.md" "$w/"
    [ "$pad" -gt 0 ] && [ -f "$w/transcript.md" ] && pad_transcript "$w/transcript.md" "$pad"
    if [ "$c" = with ]; then
      cat > "$w/AGENTS.md" <<'EOF'
Project memory (mnemonic): STATE.md is the current project state; read it first.
Long-term memory: if STATE.md lacks a fact you need, read memory/INDEX.md and open the matching topic before answering "unknown".
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
