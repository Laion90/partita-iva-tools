#!/usr/bin/env bash
set -e

# Parametri
TITLE="$1"
SLUG="$2"

if [[ -z "$TITLE" || -z "$SLUG" ]]; then
  echo "Uso: ./scripts/new_article.sh \"Titolo dell'articolo\" slug"
  exit 1
fi

if [[ -z "$DEEPSEEK_API_KEY" ]]; then
  echo "❌ Variabile d'ambiente DEEPSEEK_API_KEY mancante."
  echo "   export DEEPSEEK_API_KEY=\"…\""
  exit 1
fi

# Prompt pulito (solo ASCII)
PROMPT=$(cat <<EOT
Scrivi un articolo SEO di 1500 parole in italiano.
Titolo: "$TITLE"
Struttura: introduzione, 3-5 sezioni con H2, conclusione.
Tono professionale e bullet list dove utile.
EOT
)

# Costruisci JSON
JSON=$(jq -n \
  --arg model "deepseek-chat" \
  --arg content "$PROMPT" \
  '{model: $model, messages: [{role: "user", content: $content}]}' \
)

# Chiamata API
RESPONSE=$(curl -s https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON"
)

# Estrai contenuto
CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
  echo "❌ Nessun contenuto restituito. Risposta completa:"
  echo "$RESPONSE" | jq .
  exit 1
fi

# Genera HTML
cat > "${SLUG}.html" <<EOF_HTML
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>$TITLE</title>
  <meta name="description" content="$TITLE">
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <a href="index.html">← Home</a>
  <h1>$TITLE</h1>

  $CONTENT
</body>
</html>
EOF_HTML

# Aggiungi link in home se mancante
if ! grep -q "\"${SLUG}.html\"" index.html; then
  awk -v slug="$SLUG" -v title="$TITLE" '
    /<ul>/ && !added { print; print "  <li><a href=\"" slug ".html\">" title "</a></li>"; added=1; next }
    { print }
  ' index.html > tmp && mv tmp index.html
fi

echo "✓ Articolo creato: ${SLUG}.html e link aggiunto alla home."
