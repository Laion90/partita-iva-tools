#!/usr/bin/env bash
BASE="https://Laion90.github.io/partita-iva-tools"
TODAY=$(date +%Y-%m-%d)
echo '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' > sitemap.xml
for f in *.html */*.html; do
  [ -f "$f" ] || continue
  URL="$BASE/${f#./}"
  echo "  <url><loc>$URL</loc><lastmod>$TODAY</lastmod><changefreq>monthly</changefreq></url>" >> sitemap.xml
done
echo '</urlset>' >> sitemap.xml
