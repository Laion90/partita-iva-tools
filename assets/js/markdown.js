/*
  Converte il Markdown presente in tutti gli elementi <div class="markdown">
  usando marked.js e applica le classi Tailwind Typography (prose).
*/
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".markdown").forEach(el => {
    el.innerHTML = marked.parse(el.textContent);
    el.classList.add("prose","prose-zinc","dark:prose-invert","max-w-none");
  });
});
