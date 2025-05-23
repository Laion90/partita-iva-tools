#!/usr/bin/env bash
set -e

##############################################################################
# new_article.sh — crea un articolo Markdown + Amazon placeholders
# Uso: ./scripts/new_article.sh "Titolo articolo" slug-seo
##############################################################################

TITLE="$1"; SLUG="$2"
[[ -z $TITLE || -z $SLUG ]] && { echo "Uso: $0 \"Titolo\" slug"; exit 1; }

[[ -f .amazon-tag ]] || { echo "❌ .amazon-tag mancante"; exit 1; }
AMAZON_TAG=$(cat .amazon-tag)
[[ -z $DEEPSEEK_API_KEY ]] && { echo "❌ DEEPSEEK_API_KEY mancante"; exit 1; }

# ---------------------------------------------------------------------------
# Prompt DeepSeek (restituirà Markdown con {{ASIN|Testo}})
# ---------------------------------------------------------------------------
read -r -d '' PROMPT <<EOT
Scrivi un articolo SEO di 1200 parole in italiano.
Titolo: "$TITLE"
Struttura: introduzione, 3 sezioni H2, conclusione.
In ogni sezione inserisci un prodotto Amazon con mini review.
Scrivi il link come segnaposto {{ASIN|Testo click}}, dove ASIN
è un codice fittizio di 10 lettere/numero.
Usa Markdown (##, ###, liste, tabelle).
EOT

JSON=$(jq -n --arg model deepseek-chat --arg content "$PROMPT" \
            '{model:$model,messages:[{role:"user",content:$content}]}' )

CONTENT=$(curl -s https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" -d "$JSON" \
  | jq -r '.choices[0].message.content')

[[ -z $CONTENT || $CONTENT == "null" ]] && { echo "Errore risposta API"; exit 1; }

# ---------------------------------------------------------------------------
# HEAD HTML
# ---------------------------------------------------------------------------
read -r -d '' HEAD <<H
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="index,follow">
<meta name="amazon-tag" content="$AMAZON_TAG">
<link rel="icon" href="assets/img/favicon.png">
<script src="https://cdn.tailwindcss.com"></script>
<script>tailwind.config={plugins:[window.tailwindTypography]}</script>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/typography@0.5/dist/typography.min.js"></script>
<link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
<script src="https://unpkg.com/aos@2.3.4/dist/aos.js" defer></script>
<script defer data-domain="partita-iva-tools" src="https://plausible.io/js/script.js"></script>
<link rel="stylesheet" href="assets/css/blog.css">
<script src="assets/js/main.js"   defer></script>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="assets/js/markdown.js" defer></script>
H

# ---------------------------------------------------------------------------
# Crea file HTML (Markdown grezzo all’interno della div.markdown)
# ---------------------------------------------------------------------------
cat > "${SLUG}.html" <<EOF
<!DOCTYPE html><html lang="it" class="scroll-smooth">
<head><title>$TITLE</title><meta name="description" content="$TITLE">
$HEAD
</head>
<body class="bg-white dark:bg-zinc-900 dark:text-zinc-100 font-sans">

<header class="bg-white/80 dark:bg-zinc-900/80 backdrop-blur sticky top-0 z-50 shadow-sm">
  <div class="max-w-6xl mx-auto flex items-center justify-between py-3 px-4">
    <a href="index.html" class="text-xl font-bold text-indigo-600">Partita IVA Tools</a>
    <nav class="hidden md:flex gap-6 text-sm">
      <a href="index.html#blog" class="hover:text-indigo-600">Blog</a>
      <a href="index.html#comparatore" class="hover:text-indigo-600">Comparatori</a>
    </nav>
    <button id="themeToggle" class="p-2">🌙</button>
  </div>
</header>

<section class="max-w-7xl mx-auto py-16 px-4" data-aos="fade-up">
  <div class="markdown">
$CONTENT
  </div>
</section>

<footer class="bg-zinc-900 text-zinc-400 text-sm py-10">
  <div class="max-w-6xl mx-auto px-4">
    <p>© 2025 Partita IVA Tools – Tutti i diritti riservati.</p>
    <p>I link presenti sul sito sono link di affiliazione Amazon.</p>
  </div>
</footer>
</body></html>
EOF

# ---------------------------------------------------------------------------
# Aggiorna data/posts.json
# ---------------------------------------------------------------------------
DATE=$(date +%F)
EXCERPT=$(echo "$CONTENT" | head -3 | tr -d '\r' | tr '\n' ' ' | cut -c1-140)
tmp=$(mktemp)
jq --arg t "$TITLE" --arg s "$SLUG" --arg e "$EXCERPT" --arg d "$DATE" '
  . += [{"title":$t,"slug":$s,"excerpt":$e,"date":$d}]' data/posts.json > "$tmp"
jq 'sort_by(.date)|reverse' "$tmp" > data/posts.json && rm "$tmp"

echo "✓ Articolo creato: ${SLUG}.html"
