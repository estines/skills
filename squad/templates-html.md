# Template — interactive HTML report (all modes)

One self-contained, dependency-free, dark-theme HTML file. The orchestrator fills
the `DATA` array (and `<header>` text) and writes it to `reports/<name>.html`. Used
for the Execution Preview, the recovered flow, the crash audit, and the refactor
design — anything worth scanning visually.

Structure: a top **tab/timeline** bar; each entry reveals a **section** with
free-form HTML (tables, trees, Given/When/Then scenarios, code blocks). For the
Execution Preview, include the **decision gate** buttons at the end.

```html
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{TITLE}}</title>
<style>
:root{--bg:#0d1117;--panel:#161b22;--panel2:#1c2330;--line:#2d3643;--ink:#e6edf3;
--dim:#8b949e;--accent:#58a6ff;--green:#3fb950;--amber:#d29922;--red:#f85149;--purple:#bc8cff;
--mono:'SF Mono',ui-monospace,Menlo,Consolas,monospace;}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);
font-family:-apple-system,Segoe UI,Roboto,sans-serif;line-height:1.55}
header{padding:24px 32px;border-bottom:1px solid var(--line)}
h1{margin:0;font-size:20px}.sub{color:var(--dim);font-size:13px;margin-top:6px}
.wrap{max-width:1080px;margin:0 auto;padding:22px 32px 70px}
.tabs{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:18px}
.tab{padding:8px 14px;border:1px solid var(--line);border-radius:8px;background:var(--panel);
cursor:pointer;font-size:13px;color:var(--dim)}
.tab.active{background:var(--panel2);color:var(--ink);border-color:var(--accent)}
.view{display:none}.view.active{display:block}
.card{border:1px solid var(--line);border-radius:10px;background:var(--panel);padding:16px 18px;margin:10px 0}
pre{background:#0a0e14;border:1px solid var(--line);border-radius:8px;padding:12px;
font-family:var(--mono);font-size:12px;color:#c9d1d9;overflow-x:auto}
table{width:100%;border-collapse:collapse;font-size:12.5px;margin:6px 0}
th,td{border:1px solid var(--line);padding:7px 10px;text-align:left}th{background:#0a0e14;color:var(--dim)}
.grn{color:var(--green)}.red{color:var(--red)}.amb{color:var(--amber)}.acc{color:var(--accent)}.dim{color:var(--dim)}
.mono{font-family:var(--mono)}
.gwt{font-family:var(--mono);font-size:12px;line-height:1.7}.gwt b{color:var(--purple);width:54px;display:inline-block}
.btn{padding:11px 20px;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;border:1px solid var(--line);margin-right:8px}
.btn.ok{background:var(--green);color:#06140a}.btn.rev{background:var(--panel2);color:var(--amber)}.btn.no{background:var(--panel2);color:var(--red)}
</style></head><body>
<header><h1>{{TITLE}}</h1><div class="sub">{{SUBTITLE}}</div></header>
<div class="wrap"><div class="tabs" id="tabs"></div><div id="body"></div></div>
<script>
// Orchestrator fills DATA: [{tab:"Intent", html:"<div class='card'>…</div>"}, …]
const DATA = {{DATA_JSON}};
const tabs=document.getElementById('tabs'), body=document.getElementById('body');
DATA.forEach((d,i)=>{const v=document.createElement('div');v.className='view'+(i===0?' active':'');
  v.innerHTML=d.html;v.id='v'+i;body.appendChild(v);
  const t=document.createElement('div');t.className='tab'+(i===0?' active':'');t.textContent=d.tab;
  t.onclick=()=>{document.querySelectorAll('.tab').forEach(x=>x.classList.remove('active'));
    document.querySelectorAll('.view').forEach(x=>x.classList.remove('active'));
    t.classList.add('active');document.getElementById('v'+i).classList.add('active');};
  tabs.appendChild(t);});
</script></body></html>
```

## Fill conventions
- **Execution Preview**: tabs = `Intent`, `Plan & file tree`, `Test scenarios`,
  `Open questions`, `Decision`. The Decision card ends with the three `.btn`
  buttons (Approve / Revise / Reject) — they are illustrative; the real decision is
  taken via `AskUserQuestion` in the chat.
- **Flow / audit / refactor**: tabs = `Flow map`, `File tree`, `Crash audit`,
  `Refactor design` (use only those that apply).
- Test scenarios use the `.gwt` block: `<b>Given</b> … <b>When</b> … <b>Then</b> …`.
- Tag crash rows by tier with `.red` (P0/P1) / `.amb` (P2/reliability).
- Keep it one file, no external assets, no network calls.
