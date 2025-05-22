document.addEventListener("DOMContentLoaded",()=>{
  document.querySelectorAll(".markdown").forEach(el=>{
    el.innerHTML = marked.parse(el.textContent);
    el.className = "article-body";
  });
});
