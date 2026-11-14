#!/bin/sh
# Grade benchmark answers and report context size per run.
# Usage: sh tests/bench/grade.sh <out-dir>
# Optional per run: <out-dir>/<scenario>/<condition>/usage.txt with the agent's
# reported token count (single number), shown in the "agent tokens" column.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
out=${1:?usage: grade.sh <out-dir>}

ctx_bytes() {
  # Bytes the run needs as memory context (files offered by the condition).
  find "$1" -type f \( -name 'transcript.md' -o -name 'STATE.md' -o -path '*/memory/*' \) \
    -exec cat {} + 2>/dev/null | wc -c | tr -d ' '
}

grade_one() {
  # grade_one <answers> <expected> -> prints "correct/total" and failed ids to stderr
  ok=0 n=0 failed=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    q=${line%%:*}; spec=${line#*: }
    n=$((n + 1))
    ans=$(grep -i "^$q:" "$1" 2>/dev/null | head -1 | cut -d: -f2-)
    pass=1
    rest=$spec
    while :; do
      p=${rest%% && *}
      printf '%s\n' "$ans" | grep -qiE -- "$p" || { pass=0; break; }
      [ "$p" = "$rest" ] && break
      rest=${rest#* && }
    done
    if [ "$pass" -eq 1 ]; then ok=$((ok + 1)); else failed="$failed $q"; fi
  done < "$2"
  printf '%s/%s|%s\n' "$ok" "$n" "${failed# }"
}

printf '%-15s %-8s %8s %9s %12s  %s\n' scenario memory correct ctx_tok agent_tokens failed
tot_w=0 tot_o=0 tok_w=0 tok_o=0
for s in "$here"/s*-*/; do
  s=$(basename "$s")
  for c in without with; do
    w="$out/$s/$c"
    [ -d "$w" ] || continue
    r=$(grade_one "$w/answers.txt" "$here/$s/expected.txt")
    score=${r%%|*}; failed=${r#*|}
    b=$(ctx_bytes "$w"); t=$((b / 4))
    u=$(cat "$w/usage.txt" 2>/dev/null || echo -)
    printf '%-15s %-8s %8s %9s %12s  %s\n' "$s" "$c" "$score" "~$t" "$u" "${failed:--}"
    if [ "$c" = with ]; then tot_w=$((tot_w + t)); case $u in ''|*[!0-9]*) ;; *) tok_w=$((tok_w + u)) ;; esac
    else tot_o=$((tot_o + t)); case $u in ''|*[!0-9]*) ;; *) tok_o=$((tok_o + u)) ;; esac; fi
  done
done
echo
[ "$tot_o" -gt 0 ] && echo "memory context: without ~$tot_o tok, with ~$tot_w tok ($(( 100 - 100 * tot_w / tot_o ))% less)"
[ "$tok_o" -gt 0 ] && [ "$tok_w" -gt 0 ] && echo "agent tokens:   without $tok_o, with $tok_w ($(( 100 - 100 * tok_w / tok_o ))% less)"
exit 0
