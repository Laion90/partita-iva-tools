#!/usr/bin/env bash
set -e

# ---------- parametri -------------------------------------------------
TITLE="$1"
SLUG="$2"
[ -z "$TITLE" -o -z "$SLUG" ] && { echo "Uso: $0 \"Titolo\" slug"; exit 1; }
[ -z "$DEEPSEEK_API_KEY" ]     && { echo "❌ DEEPSEEK_API_KEY mancante"; exit 1; }

# ---------- prompt per DeepSeek --------------------------------------
PROMPT=$(cat <<EOT
Scrivi un articolo SEO di 1500 parole in italiano.
Titolo: "$TITLE"
Struttura: introduzione, 3-5 sezioni con H2, conclusione.
Tono professionale e bullet list dove utile.
EOT
)

JSON=$(jq -n --arg model "deepseek-chat" --arg content "$PROMPT" \
       '{model:$model,messages:[{role:"user",content:$content}]}' )

RESPONSE=$(curl -s https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON")

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')
[ -z "$CONTENT" -o "$CONTENT" = "null" ] && { echo "$RESPONSE" | jq .; exit 1; }

# ---------- blocco HEAD uniforme -------------------------------------
HEAD=$(cat <<'H'
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="index,follow">
<link rel="icon" href="assets/img/favicon.png">
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
<script src="https://unpkg.com/aos@2.3.4/dist/aos.js" defer></script>
<script defer data-domain="partita-iva-tools" src="https://plausible.io/js/script.js"></script>
<script src="assets/js/main.js" defer></script>
H
)

# ---------- genera l'HTML --------------------------------------------
cat > "${SLUG}.html" <<EOF_HTML
<!DOCTYPE html>
<html lang="it" class="scroll-smooth">
<head>
  <title>$TITLE</title>
  <meta name="description" content="$TITLE">
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
    <button id="themeToggle" class="p-2 rounded hover:bg-zinc-100 dark:hover:bg-zinc-800">🌙</button>
  </div>
</header>

<section class="max-w-3xl mx-auto py-16 px-4 leading-relaxed space-y-8" data-aos="fade-up">
$CONTENT
</section>

<footer class="bg-zinc-900 text-zinc-400 text-sm py-10 mt-16">
  <div class="max-w-6xl mx-auto px-4">
    <p class="mb-2">© 2025 Partita IVA Tools – Tutti i diritti riservati.</p>
    <p class="mb-2">I link presenti sul sito sono link di affiliazione: potremmo ricevere una commissione se effettui un acquisto o una registrazione.</p>
  </div>
</footer>
</body>
</html>
EOF_HTML

# ---------- card automatica nella home --------------------------------
awk -v slug="$SLUG" -v title="$TITLE" '
  /<!-- Card anchor -->/ && !added {
    print "    <a href=\""slug".html\" class=\"group rounded-xl overflow-hidden shadow-lg hover:shadow-xl transition\" data-aos=\"fade-up\">";
    print "      <div class=\"p-6 bg-white dark:bg-zinc-800 h-full flex flex-col\">";
    print "        <h3 class=\"text-xl font-semibold mb-4 group-hover:text-indigo-600\">"title"</h3>";
    print "        <p class=\"text-sm text-zinc-600 dark:text-zinc-400 flex-grow\">Nuova guida.</p>";
    print "        <span class=\"mt-6 text-indigo-600 text-sm font-medium\">Leggi →</span>";
    print "      </div></a>";
    added=1; next }
  { print }
' index.html > tmp && mv tmp index.html

echo "✓ Articolo creato: ${SLUG}.html e card aggiunta alla home."
