
#!/bin/bash

ROOT="$(realpath "${1:-.}")"
OUTPUT="index.html"

generate_gallery() {
    python3 - "$ROOT" "$ROOT/$OUTPUT" <<'PY'
import os, sys, html
from urllib.parse import quote

root, output = sys.argv[1:]
extensions = ('.png', '.jpg', '.jpeg', '.webp', '.gif')

with open(output, 'w', encoding='utf-8') as f:
    f.write("""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Screenshot gallery</title>
<style>
body { font-family: sans-serif; margin: 2rem; }
.gallery { display:flex; flex-wrap:wrap; gap:1rem; }
.item { width:220px; }
.item img { width:220px; height:150px; object-fit:contain;
background:#eee; border:1px solid #ccc; }
.item a { display:block; margin-top:.4rem; overflow-wrap:anywhere; }
</style>
</head>
<body>
<h1>Screenshot gallery</h1>
<div class="gallery">
""")
    for folder, dirs, files in os.walk(root):
        dirs.sort()
        for name in sorted(files):
            if name.lower().endswith(extensions) and name != os.path.basename(output):
                path = os.path.join(folder, name)
                rel = os.path.relpath(path, root).replace(os.sep, '/')
                url = quote(rel, safe='/')
                label = html.escape(rel)
                f.write(
                    f'<div class="item"><a href="{url}">'
                    f'<img src="{url}" loading="lazy" alt="{label}">'
                    f'</a><a href="{url}">{label}</a></div>\n'
                )
    f.write("</div>\n</body>\n</html>\n")
PY
    echo "Gallery updated: $ROOT/$OUTPUT"
}

generate_gallery

inotifywait -m -r -q \
    -e close_write,moved_to,moved_from,create,delete,delete_self \
    --format '%w%f' "$ROOT" |
while IFS= read -r changed; do
    # Ignore changes to the generated index itself
    [[ "$changed" == "$ROOT/$OUTPUT" ]] && continue
    sleep 0.3
    generate_gallery
done

