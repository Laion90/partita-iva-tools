#!/usr/bin/env bash
set -e
for f in *.html; do
  [[ "$f" =~ ^(index|404)\.html$ ]] && continue
  # Head: inietta tipografia + CSS + marked
  grep -q 'blog.css' "$f" || \
   sed -i '/tailwindcss.com/a \
<script>tailwind.config={plugins:[window.tailwindTypography]}</script>\n<link rel="stylesheet" href="assets/css/blog.css">\n<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>\n<script src="assets/js/markdown.js" defer></script>' "$f"
  # Wrapper markdown
  grep -q 'class="markdown"' "$f" || {
    sed -i '0,/<section/{n;s/^/<div class="markdown">/;}' "$f"
    sed -i '0,/<\/section>/{s//<\/div>\n<\/section>/;}' "$f"
  }
done
echo "✓ Articoli esistenti uniformati."
