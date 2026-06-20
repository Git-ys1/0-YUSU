const achievementsEl = document.querySelector("#achievement-strip");
const projectsEl = document.querySelector("#project-list");
const searchForm = document.querySelector("#search-form");
const searchInput = document.querySelector("#kb-query");
const searchResultsEl = document.querySelector("#search-results");
const docViewerEl = document.querySelector("#doc-viewer");
const docTitleEl = document.querySelector("#doc-title");
const docPathEl = document.querySelector("#doc-path");
const docContentEl = document.querySelector("#doc-content");
const docCloseEl = document.querySelector("#doc-close");
const statusMd = document.querySelector("#status-md");
const siteVersion = document.querySelector("#site-version");

const escapeHtml = (value) => String(value ?? "")
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;")
  .replaceAll("'", "&#039;");

const isImage = (source) => /\.(jpg|jpeg|png|webp)$/i.test(source || "");

function renderAchievements(items) {
  achievementsEl.innerHTML = items.map((item) => {
    const preview = item.previewMedia || item.media;
    const imageFit = item.imageFit === "cover" ? "cover" : "contain";
    const media = isImage(item.source)
      ? `<img class="achievement-image ${imageFit}" src="${preview}" alt="${escapeHtml(item.award)}">`
      : `<div class="doc-source">${escapeHtml(item.source)}</div>`;

    const people = (item.people || []).slice(0, 5).join(" / ");
    const tags = (item.tags || []).map((tag) => `<span>${escapeHtml(tag)}</span>`).join("");

    return `
      <article class="achievement reveal">
        <div class="achievement-media">${media}</div>
        <div class="achievement-body">
          <h3>${escapeHtml(item.title)}</h3>
          <p class="award">${escapeHtml(item.award)}</p>
          <div class="meta">
            <span>${escapeHtml(item.date)}</span>
            <span>${escapeHtml(item.project)}</span>
            <span>${escapeHtml(people)}</span>
          </div>
          <div class="tags">${tags}</div>
          <a class="source-link" href="${item.media}" target="_blank" rel="noreferrer">打开原件</a>
        </div>
      </article>
    `;
  }).join("");
}

function renderProjects(items) {
  projectsEl.innerHTML = items.map((item) => {
    const tags = (item.tags || []).map((tag) => `<span>${escapeHtml(tag)}</span>`).join("");
    const memoryPath = escapeHtml(item.memory);
    return `
      <article class="project reveal">
        <p class="project-type">${escapeHtml(item.type)} / ${escapeHtml(item.status)}</p>
        <h3>${escapeHtml(item.name)}</h3>
        <p>${escapeHtml(item.summary)}</p>
        <div class="tags">${tags}</div>
        <button class="memory-link doc-button" type="button" data-path="${memoryPath}">打开知识条目：${memoryPath}</button>
      </article>
    `;
  }).join("");
}

function wireReveal() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.16 });

  document.querySelectorAll(".reveal").forEach((node) => observer.observe(node));
}

function renderSearchResults(results, query) {
  if (!query.trim()) {
    searchResultsEl.innerHTML = `<p class="empty">输入项目名、工具名、错误原文或经验关键词。</p>`;
    return;
  }

  if (!results.length) {
    searchResultsEl.innerHTML = `<p class="empty">没有找到匹配项。换一个更短或更具体的关键词试试。</p>`;
    return;
  }

  searchResultsEl.innerHTML = results.map((item) => `
    <article class="result">
      <strong>${escapeHtml(item.title)}</strong>
      <code>${escapeHtml(item.path)}:${escapeHtml(item.line)}</code>
      <p>${escapeHtml(item.snippet)}</p>
      <button class="doc-button" type="button" data-path="${escapeHtml(item.path)}" data-line="${escapeHtml(item.line)}">打开正文</button>
    </article>
  `).join("");
}

async function runSearch(query) {
  searchResultsEl.innerHTML = `<p class="empty">搜索中...</p>`;
  const response = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
  const data = await response.json();
  renderSearchResults(data.results || [], query);
}

async function openDoc(path, line = "") {
  docViewerEl.hidden = false;
  docTitleEl.textContent = "读取中...";
  docPathEl.textContent = path;
  docContentEl.textContent = "";
  const response = await fetch(`/api/doc?path=${encodeURIComponent(path)}`);
  if (!response.ok) {
    docTitleEl.textContent = "无法打开知识条目";
    docContentEl.textContent = `HTTP ${response.status}`;
    return;
  }
  const doc = await response.json();
  docTitleEl.textContent = doc.title;
  docPathEl.textContent = `${doc.path}${line ? `:${line}` : ""}`;
  docContentEl.textContent = doc.content;
  docViewerEl.scrollIntoView({ behavior: "smooth", block: "start" });
}

async function boot() {
  const [showcaseResponse, statusResponse] = await Promise.all([
    fetch("/api/showcase"),
    fetch("/api/status")
  ]);
  const showcase = await showcaseResponse.json();
  const status = await statusResponse.json();

  document.title = `${showcase.site.name} Local Archive`;
  statusMd.textContent = status.markdownFiles;
  siteVersion.textContent = `${showcase.site.name} ${showcase.site.version}`;

  renderAchievements(showcase.achievements || []);
  renderProjects(showcase.projects || []);
  wireReveal();

  renderSearchResults([], "");
}

searchForm.addEventListener("submit", (event) => {
  event.preventDefault();
  runSearch(searchInput.value);
});

document.addEventListener("click", (event) => {
  const button = event.target.closest(".doc-button");
  if (!button) {
    return;
  }
  const path = button.getAttribute("data-path");
  const line = button.getAttribute("data-line") || "";
  if (path) {
    openDoc(path, line).catch((error) => {
      docViewerEl.hidden = false;
      docTitleEl.textContent = "无法打开知识条目";
      docContentEl.textContent = error.message;
    });
  }
});

docCloseEl.addEventListener("click", () => {
  docViewerEl.hidden = true;
});

boot().catch((error) => {
  console.error(error);
  document.body.insertAdjacentHTML("afterbegin", `<div class="empty">站点数据加载失败：${escapeHtml(error.message)}</div>`);
});
