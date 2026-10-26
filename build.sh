#!/usr/bin/env bash
# slides.md を HTML 化し、画像を埋め込んだ単体ファイルとして ~/temp/slides.html に出力する
set -euo pipefail
cd "$(dirname "$0")"
out="$HOME/temp/slides.html"
mkdir -p "$HOME/temp"
npx -y @marp-team/marp-cli@latest slides.md -o slides.html </dev/null >/dev/null 2>&1
python3 - slides.html "$out" <<'PY'
import base64, pathlib, re, sys
src, dst = map(pathlib.Path, sys.argv[1:])
html = src.read_text()
def inline(m):
    q, name = m.group(1), m.group(2)
    p = pathlib.Path(name)
    if not p.is_file():
        return m.group(0)
    data = base64.b64encode(p.read_bytes()).decode()
    return f'{q}data:image/png;base64,{data}{q}'
html = re.sub(r'(&quot;|")([\w.-]+\.png)\1', inline, html)
dst.write_text(html)
PY
rm -f slides.html
echo "built: $out"
