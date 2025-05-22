#!/usr/bin/env bash
set -e
TITLE="$1"; SLUG="$2"
[[ -z $TITLE || -z $SLUG ]] && { echo "Uso: $0 \"Titolo\" slug"; exit 1; }
[[ -z $DEEPSEEK_API_KEY ]]  && { echo "‚ùå DEEPSEEK_API_KEY mancante"; exit 1; }

PROMPT=$(cat <<EOT
Scrivi un articolo SEO di 1500 parole in italiano.
Titolo: "$TITLE"
Struttura: introduzione, 3-5 sezioni con H2, conclusione.
Tono professionale. Formatta strettamente in Markdown (##, ###, liste, tabelle).
EOT
)

JSON=$(jq -n --arg model deepseek-chat --arg content "$PROMPT" \
      '{model:$model,messages:[{role:"user",content:$content}]}' )
CONTENT=$(curl -s https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" -d "$JSON" | jq -r '.choices[0].message.content')

# --------------------- HEAD -------------------------------------------------
HEAD=$(cat <<'H'
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="index,follow">
<link rel="icon" href="assets/img/favicon.png">
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config={plugins:[window.tailwindTypography]}
</script>
<link  href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
<script src="https://unpkg.com/aos@2.3.4/dist/aos.js" defer></script>
<script defer data-domain="partita-iva-tools" src="https://plausible.io/js/script.js"></script>
<link rel="stylesheet" href="assets/css/blog.css">
<script src="assets/js/main.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="assets/js/markdown.js" defer></script>
H
)

# --------------------- HTML -------------------------------------------------
cat > "${SLUG}.html" <<EOF
<!DOCTYPE html><html lang="it" class="scroll-smooth">
<head><title>$TITLE</title><meta name="description" content="$TITLE">$HEAD</head>
<body class="bg-white dark:bg-zinc-900 dark:text-zinc-100 font-sans">
<header class="bg-white/80 dark:bg-zinc-900/80 backdrop-blur sticky top-0 z-50 shadow-sm">
  <div class="max-w-6xl mx-auto flex items-center justify-between py-3 px-4">
    <a href="index.html" class="text-xl font-bold text-indigo-600">Partita IVA Tools</a>
    <nav class="hidden md:flex gap-6 text-sm">
      <a href="index.html#blog" class="hover:text-indigo-600">Blog</a>
      <a href="index.html#comparatore" class="hover:text-indigo-600">Comparatori</a>
    </nav>
    <button id="themeToggle" class="p-2">Ìºô</button>
  </div>
</header>

<section class="max-w-7xl mx-auto py-16 px-4" data-aos="fade-up">
  <div class="markdown">$CONTENT</div>
</section>

<footer class="bg-zinc-900 text-zinc-400 text-sm py-10">
  <div class="max-w-6xl mx-auto px-4">
    <p>¬© 2025 Partita IVA Tools ‚Äì Tutti i diritti riservati.</p>
    <p>I link presenti sul sito sono link di affiliazione.</p>
  </div>
</footer>
</body></html>
EOF
echo "‚úì Articolo creato: ${SLUG}.html"
