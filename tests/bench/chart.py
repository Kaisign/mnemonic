#!/usr/bin/env python3
"""Render benchmark charts (SVG) and an HTML report from results.csv.

Usage: python3 tests/bench/chart.py [results.csv] [out-dir]
Standard library only. PDF: node tests/bench/pdf.js (needs playwright),
or open report.html in a browser and print to PDF.
"""
import csv, html, os, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "results", "results.csv")
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.dirname(SRC)
SIZES = ["1k", "5k", "15k"]
SCEN = ["s1-linear", "s2-abstract", "s3-analytical"]
COND = [("without", "Without mnemonic", "s1"), ("with", "With mnemonic", "s2")]

STYLE = """<style>
.bg{fill:#fcfcfb}.t1{fill:#0b0b0b}.t2{fill:#52514e}.grid{stroke:#e4e3df}.axis{stroke:#9b9a94}
.s1{fill:#2a78d6;stroke:#2a78d6}.s2{fill:#eb6834;stroke:#eb6834}.gap{stroke:#fcfcfb}
text{font-family:system-ui,-apple-system,Segoe UI,sans-serif}
@media (prefers-color-scheme:dark){.bg{fill:#1a1a19}.t1{fill:#f0efec}.t2{fill:#c3c2b7}
.grid{stroke:#383835}.axis{stroke:#6b6a64}.s1{fill:#3987e5;stroke:#3987e5}.s2{fill:#d95926;stroke:#d95926}.gap{stroke:#1a1a19}}
</style>"""


def load():
    rows = [r for r in csv.DictReader(open(SRC)) if r["label"] in SIZES]
    for r in rows:
        for k in ("correct", "total", "ctx_tokens", "agent_tokens", "tool_uses"):
            r[k] = int(r[k]) if r[k] else 0
    return rows


def mean(xs):
    return sum(xs) / len(xs) if xs else 0


def fmt(n):
    return f"{n/1000:.1f}K" if n >= 1000 else f"{n:.0f}"


def nice_max(v):
    for step in (1000, 2000, 2500, 5000, 10000, 20000, 25000):
        if v / step <= 6:
            return step * (int(v / step) + 1), step
    return v, v / 5


def frame(w, h, title, sub):
    return [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-label="{html.escape(title)}">',
            STYLE, f'<title>{html.escape(title)}</title>', f'<rect class="bg" width="{w}" height="{h}"/>',
            f'<text class="t1" x="24" y="30" font-size="16" font-weight="600">{html.escape(title)}</text>',
            f'<text class="t2" x="24" y="50" font-size="12">{html.escape(sub)}</text>']


def legend(x, y):
    out = []
    for i, (_, name, cls) in enumerate(COND):
        xx = x + i * 150
        out.append(f'<rect class="{cls}" x="{xx}" y="{y-9}" width="10" height="10" rx="2"/>')
        out.append(f'<text class="t2" x="{xx+16}" y="{y}" font-size="12">{name}</text>')
    return out


def y_axis(x0, x1, top, bottom, vmax, step):
    out = []
    v = 0
    while v <= vmax:
        y = bottom - (bottom - top) * v / vmax
        out.append(f'<line class="grid" x1="{x0}" x2="{x1}" y1="{y:.1f}" y2="{y:.1f}" stroke-width="1"/>')
        out.append(f'<text class="t2" x="{x0-8}" y="{y+4:.1f}" font-size="11" text-anchor="end">{fmt(v)}</text>')
        v += step
    out.append(f'<line class="axis" x1="{x0}" x2="{x1}" y1="{bottom}" y2="{bottom}" stroke-width="1"/>')
    return out


def bar(x, y, w, h, cls):
    # 4px rounded data end, square at the baseline, 2px surface gap via stroke
    r = min(4, h, w / 2)
    if h <= 0:
        return ""
    return (f'<path class="{cls}" stroke-width="0" d="M{x},{y+h} V{y+r} Q{x},{y} {x+r},{y} '
            f'H{x+w-r} Q{x+w},{y} {x+w},{y+r} V{y+h} Z"/>')


def grouped(fname, title, sub, groups, values, ylab):
    """groups: x labels; values[cond][i]."""
    W, H, L, R, T, B = 720, 380, 70, 24, 90, 320
    vmax, step = nice_max(max(max(v) for v in values.values()))
    s = frame(W, H, title, sub) + legend(L, 74) + y_axis(L, W - R, T, B, vmax, step)
    s.append(f'<text class="t2" x="18" y="{(T+B)/2}" font-size="11" transform="rotate(-90 18 {(T+B)/2})" text-anchor="middle">{ylab}</text>')
    gw = (W - R - L) / len(groups)
    bw = min(56, gw / 3)
    for i, g in enumerate(groups):
        cx = L + gw * i + gw / 2
        for j, (key, _, cls) in enumerate(COND):
            v = values[key][i]
            h = (B - T) * v / vmax
            x = cx - bw - 1 + j * (bw + 2)
            s.append(bar(x, B - h, bw, h, cls))
            s.append(f'<text class="t1" x="{x+bw/2:.1f}" y="{B-h-6:.1f}" font-size="11" text-anchor="middle">{fmt(v)}</text>')
        s.append(f'<text class="t2" x="{cx:.1f}" y="{B+18}" font-size="12" text-anchor="middle">{html.escape(g)}</text>')
    s.append("</svg>")
    open(os.path.join(OUT, fname), "w").write("\n".join(s))


def lines(fname, title, sub, xs, xlabels, values, ylab):
    W, H, L, R, T, B = 720, 380, 70, 150, 90, 320
    vmax, step = nice_max(max(max(v) for v in values.values()))
    s = frame(W, H, title, sub) + legend(L, 74) + y_axis(L, W - R, T, B, vmax, step)
    s.append(f'<text class="t2" x="18" y="{(T+B)/2}" font-size="11" transform="rotate(-90 18 {(T+B)/2})" text-anchor="middle">{ylab}</text>')
    xmax = max(xs)
    px = lambda x: L + (W - R - L) * x / xmax
    for x, lab in zip(xs, xlabels):
        s.append(f'<text class="t2" x="{px(x):.1f}" y="{B+18}" font-size="12" text-anchor="middle">{lab}</text>')
    s.append(f'<text class="t2" x="{(L+W-R)/2}" y="{B+40}" font-size="11" text-anchor="middle">previous conversation length (tokens)</text>')
    for key, name, cls in COND:
        pts = [(px(x), B - (B - T) * v / vmax) for x, v in zip(xs, values[key])]
        s.append(f'<polyline class="{cls}" fill="none" stroke-width="2" points="{" ".join(f"{a:.1f},{b:.1f}" for a, b in pts)}"/>')
        for a, b in pts:
            s.append(f'<circle class="{cls} gap" cx="{a:.1f}" cy="{b:.1f}" r="4.5" stroke-width="2" style="fill:currentColor"/>')
            s.append(f'<circle class="{cls}" cx="{a:.1f}" cy="{b:.1f}" r="4"/>')
        a, b = pts[-1]
        s.append(f'<text class="t1" x="{a+10:.1f}" y="{b+4:.1f}" font-size="12">{name.split()[0]} {fmt(values[key][-1])}</text>')
    s.append("</svg>")
    open(os.path.join(OUT, fname), "w").write("\n".join(s))


def main():
    rows = load()
    by = defaultdict(list)
    for r in rows:
        by[(r["label"], r["memory"])].append(r)
    agent = {k: [mean([r["agent_tokens"] for r in by[(s, k)]]) for s in SIZES] for k, _, _ in COND}
    ctx = {k: [mean([r["ctx_tokens"] for r in by[(s, k)]]) for s in SIZES] for k, _, _ in COND}
    xs = [round(v) for v in ctx["without"]]
    save = [100 * (1 - w / o) for w, o in zip(agent["with"], agent["without"])]

    lines("scaling.svg", "Tokens per resumed session vs conversation length",
          "Mean total agent tokens over 3 scenarios (includes ~64K fixed agent overhead)",
          xs, [f"~{fmt(x)}" for x in xs], agent, "agent tokens")
    big = SIZES[-1]
    per = {k: [next(r["agent_tokens"] for r in by[(big, k)] if r["scenario"] == sc) for sc in SCEN] for k, _, _ in COND}
    grouped("scenarios.svg", f"Tokens per scenario at ~{fmt(xs[-1])} conversation",
            "Total agent tokens per run, same questions and grading", ["linear", "abstract", "analytical"], per, "agent tokens")
    grouped("context.svg", "Memory context the agent must read",
            "Mean tokens of transcript (without) vs STATE.md + memory (with)", [f"~{fmt(x)}" for x in xs], ctx, "context tokens")

    ok = sum(r["correct"] for r in rows); tot = sum(r["total"] for r in rows)
    all_rows = list(csv.DictReader(open(SRC)))
    failed = [r for r in all_rows if r["label"] not in SIZES]
    table = "\n".join(
        f"<tr><td>{r['label']}</td><td>{r['scenario']}</td><td>{r['memory']}</td><td>{r['correct']}/{r['total']}</td>"
        f"<td>{int(r['ctx_tokens']):,}</td><td>{int(r['agent_tokens']):,}</td><td>{r['tool_uses']}</td></tr>" for r in all_rows)
    tiles = [(f"{save[-1]:.0f}%", f"fewer agent tokens at ~{fmt(xs[-1])}"),
             (f"{100*(1-ctx['with'][-1]/ctx['without'][-1]):.0f}%", "less memory context to read"),
             (f"{ok}/{tot}", "answers correct (valid runs)"),
             (f"{len(failed)}", "protocol miss (rerun passed)")]
    rep = f"""<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>mnemonic benchmark</title><style>
:root{{--bg:#fcfcfb;--t1:#0b0b0b;--t2:#52514e;--line:#e4e3df}}
@media (prefers-color-scheme:dark){{:root{{--bg:#1a1a19;--t1:#f0efec;--t2:#c3c2b7;--line:#383835}}}}
body{{background:var(--bg);color:var(--t1);font:14px/1.5 system-ui,-apple-system,Segoe UI,sans-serif;max-width:760px;margin:24px auto;padding:0 16px}}
h1{{font-size:22px;margin:0 0 4px}}p,li{{color:var(--t2)}}.tiles{{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin:20px 0}}
.tile{{border:1px solid var(--line);border-radius:8px;padding:12px}}.tile b{{font-size:26px;display:block}}.tile span{{color:var(--t2);font-size:12px}}
img{{max-width:100%;height:auto;margin:12px 0;border:1px solid var(--line);border-radius:8px}}
table{{border-collapse:collapse;width:100%;font-size:12px}}td,th{{border-bottom:1px solid var(--line);padding:4px 6px;text-align:right}}td:nth-child(-n+3),th:nth-child(-n+3){{text-align:left}}
@media print{{img{{break-inside:avoid}}}}</style></head><body>
<h1>mnemonic benchmark</h1><p>Resuming a project from a previous conversation, with and without mnemonic. 3 scenarios (linear, abstract, analytical), 3 conversation lengths, small model subagents, automatic grading.</p>
<div class="tiles">{"".join(f'<div class="tile"><b>{a}</b><span>{b}</span></div>' for a, b in tiles)}</div>
<img src="scaling.svg" alt="Line chart: agent tokens grow with conversation length without mnemonic and stay flat with it">
<p>Savings by conversation length: {", ".join(f"~{fmt(x)}: {v:.0f}%" for x, v in zip(xs, save))}. Without memory the cost grows with the conversation; with mnemonic it stays flat because STATE.md does not grow.</p>
<img src="scenarios.svg" alt="Bar chart: tokens per scenario at the longest length">
<img src="context.svg" alt="Bar chart: memory context tokens per length">
<h2>Method</h2><ul>
<li>Each scenario is a finished conversation where facts are later corrected (renames, changed numbers, reordered steps).</li>
<li>Without: the agent reads the transcript. With: STATE.md and on-demand long-term memory distilled from the same conversation.</li>
<li>Longer lengths interleave neutral side conversations; facts and order unchanged; STATE.md unchanged.</li>
<li>Agent tokens include a fixed ~64K overhead per agent (instructions, tools), identical in both conditions.</li>
<li>One "with" run skipped STATE.md and answered "unknown"; it is listed below and was rerun. In real installs STATE.md is auto-loaded through the adapter import, which removes this failure mode.</li>
<li>The baseline is generous: a real session without memory has no transcript and must re-explore code or ask the user.</li></ul>
<h2>All runs</h2><table><tr><th>length</th><th>scenario</th><th>memory</th><th>correct</th><th>context</th><th>agent tokens</th><th>tools</th></tr>
{table}</table></body></html>"""
    open(os.path.join(OUT, "report.html"), "w").write(rep)
    print("wrote", ", ".join(["scaling.svg", "scenarios.svg", "context.svg", "report.html"]), "in", OUT)
    print("savings:", ", ".join(f"{s}: {v:.0f}%" for s, v in zip(SIZES, save)))


if __name__ == "__main__":
    main()
