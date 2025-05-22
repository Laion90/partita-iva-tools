/* Trasforma il Markdown in HTML e applica la nuova classe article-body */
document.addEventListener("DOMContentLoaded",()=>{
  document.querySelectorAll(".markdown").forEach(el=>{
    el.innerHTML = marked.parse(el.textContent.trim());
    el.className = "article-body";
  });
  AOS.init({once:true});
});
