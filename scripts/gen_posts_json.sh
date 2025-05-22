#!/usr/bin/env bash
set -e
OUT=data/posts.json
mkdir -p data
echo "[]" > "$OUT"

for f in *.html; do
  [[ "$f" =~ ^(index|404)\.html$ ]] && continue
  slug="${f%.html}"

  # Estrai il <title> con sed (niente PCRE)
  title=$(sed -n 's:.*<title>\(.*\)</title>.*:\1:p' "$f" | head -1 | tr -d '\r')

  # Primo <p> come excerpt, tolti i tag HTML, max 150 caratteri
  excerpt=$(sed -n 's:.*<p>\(.*\):\1:p' "$f" | head -1 | sed 's/<[^>]*>//g' | cut -c1-150 | tr -d '\r')

  # Usa la data dell’ultimo commit sul file, fallback = oggi
  date=$(git log -1 --format=%cs -- "$f" 2>/dev/null || date +%F)

  # Aggiungi record
  tmp=$(mktemp)
  jq --arg t "$title" --arg s "$slug" --arg e "$excerpt" --arg d "$date" \
     '. += [{"title":$t,"slug":$s,"excerpt":$e,"date":$d}]' "$OUT" > "$tmp"
  mv "$tmp" "$OUT"
done

# Ordina per data discendente
tmp=$(mktemp)
jq 'sort_by(.date) | reverse' "$OUT" > "$tmp"
mv "$tmp" "$OUT"
