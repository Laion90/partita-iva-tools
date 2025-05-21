/* Dark-mode toggle --------------------------------------------------- */
document.addEventListener("DOMContentLoaded", () => {
  const btn = document.getElementById("themeToggle");
  if (!btn) return;
  const stored = localStorage.getItem("theme");
  if (stored === "dark") document.documentElement.classList.add("dark");
  btn.addEventListener("click", () => {
    document.documentElement.classList.toggle("dark");
    localStorage.setItem("theme",
      document.documentElement.classList.contains("dark") ? "dark" : "light");
  });
});
/* Comparator loader -------------------------------------------------- */
async function loadProducts(dataFile = "data/products.json") {
  const tbody = document.getElementById("products-body");
  if (!tbody) return;
  const products = await (await fetch(dataFile)).json();
  products.forEach(p => {
    tbody.insertAdjacentHTML("beforeend", `
      <tr class="border-b dark:border-zinc-700">
        <td class="py-3">${p.name}</td>
        <td>${p.price}</td>
        <td>${p.commission}</td>
        <td>${p.rating}</td>
        <td><a href="${p.link}"
               class="bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1 rounded"
               target="_blank" rel="nofollow">Provalo</a></td>
      </tr>`);
  });
}
/* Scroll animations (AOS init) -------------------------------------- */
document.addEventListener("DOMContentLoaded", () => {
  if (window.AOS) AOS.init({ once: true });
});
