#!/usr/bin/env bash
set -e
for f in *.html; do
  [[ "$f" =~ ^(index|404)\.html$ ]] && continue

  # 1. Inietta le CDN (se mancano)
  grep -q typography.min.js "$f" || \
    sed -i '/<script src="https:\/\/cdn.tailwindcss.com"><\/script>/a \
<script>tailwind.config={plugins:[window.tailwindTypography]}</script>\n<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/typography@0.5/dist/typography.min.js"></script>\n<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>\n<script src="assets/js/markdown.js" defer></script>' "$f"

  # 2. Avvolgi il contenuto in <div class="markdown"> ... </div> se non presente
  if ! grep -q 'class="markdown"' "$f"; then
    # prima sezione
    sed -i '0,/<section/{n;s/^/<div class="markdown">\n/;}' "$f"
    # chiusura sezione
    sed -i '0,/<\/section>/{s//<\/div>\n<\/section>/;}' "$f"
  fi
done
echo "✓ Tutti gli articoli esistenti aggiornati."
