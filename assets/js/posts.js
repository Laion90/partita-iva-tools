async function loadPosts() {
  const wrap = document.getElementById("cards-container");
  if (!wrap) return;
  const posts = await (await fetch("data/posts.json")).json();
  wrap.innerHTML = "";
  posts.forEach((p, i) => {
    wrap.insertAdjacentHTML("beforeend", `
      <a href="${p.slug}.html" class="group rounded-xl overflow-hidden shadow-lg hover:shadow-xl transition"
         data-aos="fade-up" data-aos-delay="${i*60}">
        <div class="p-6 bg-white dark:bg-zinc-800 h-full flex flex-col">
          <h3 class="text-xl font-semibold mb-4 group-hover:text-indigo-600">${p.title}</h3>
          <p class="text-sm text-zinc-600 dark:text-zinc-400 flex-grow">${p.excerpt}</p>
          <span class="mt-6 text-indigo-600 text-sm font-medium">Leggi →</span>
        </div>
      </a>`);
  });
}
document.addEventListener("DOMContentLoaded", () => { loadPosts(); AOS.init({once:true}); });
