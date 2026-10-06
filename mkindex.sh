#!/bin/bash

ROOT="${1:-.}"
OUTPUT="${2:-index.html}"

{
    echo '<!DOCTYPE html>'
    echo '<html lang="en">'
    echo '<head>'
    echo '  <meta charset="UTF-8">'
    echo '  <title>File index</title>'
    echo '</head>'
    echo '<body>'
    echo '  <h1>File index</h1>'
    echo '  <ul>'

    find "$ROOT" -type f ! -name "$OUTPUT" -print0 |
    while IFS= read -r -d '' file; do
        # Remove the root prefix
        rel="${file#"$ROOT"/}"

        # URL-encode the filename for use in href
        url=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "$rel")

        printf '    <li><a href="%s">%s</a></li>\n' "$url" "$rel"
    done

    echo '  </ul>'
    echo '</body>'
    echo '</html>'
} > "$OUTPUT"
