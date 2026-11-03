"""Bonus: builds a simple visual status page (status.html) from logs/health.log."""
import html, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
log = root / "logs" / "health.log"
lines = log.read_text(encoding="utf-8").splitlines() if log.exists() else []
last = lines[-1] if lines else "no data"
up = " UP " in f" {last} "
rows = "".join(
    f"<tr class={'up' if ' UP ' in l else 'down'}><td>{html.escape(l)}</td></tr>" for l in reversed(lines[-30:])
)
page = f"""<!doctype html><meta charset=utf-8><title>Status</title>
<style>body{{font-family:sans-serif;max-width:800px;margin:2rem auto}}
.badge{{display:inline-block;padding:.5rem 1rem;border-radius:8px;color:#fff;background:{'#2e9e4f' if up else '#d33'}}}
td{{padding:4px 8px;font-family:monospace}} .up td{{background:#e8f7ec}} .down td{{background:#fdeaea}}</style>
<h1>Service status <span class=badge>{'OPERATIONAL' if up else 'DOWN'}</span></h1>
<p>Last check: {html.escape(last)}</p><table>{rows}</table>"""
(root / "status.html").write_text(page, encoding="utf-8")
print("status.html generated")
