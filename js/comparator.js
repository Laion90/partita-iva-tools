document.addEventListener("DOMContentLoaded", () => {
  fetch("data/products.json")
    .then(r => r.json())
    .then(products => {
      const tbody = document.getElementById("products-body");
      products.forEach(p => {
        tbody.insertAdjacentHTML("beforeend", `
          <tr>
            <td>${p.name}</td>
            <td>${p.price}</td>
            <td>${p.commission}</td>
            <td>${p.rating}</td>
            <td><a class="btn" href="${p.link}" target="_blank">Provalo</a></td>
          </tr>`);
      });
    });
});
