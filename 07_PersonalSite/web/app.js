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
const statusProjects = document.querySelector("#status-projects");
const statusMedia = document.querySelector("#status-media");
const siteVersion = document.querySelector("#site-version");
const scrollProgress = document.querySelector("#scroll-progress");

const escapeHtml = (value) => String(value ?? "")
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;")
  .replaceAll("'", "&#039;");

const isImage = (source) => /\.(jpg|jpeg|png|webp)$/i.test(source || "");
const achievementLevels = [
  { key: "national", label: "国赛", tone: "gold" },
  { key: "provincial", label: "省级 / 区域赛", tone: "green" },
  { key: "campus", label: "校级", tone: "blue" },
];

function initSmoothScroll() {
  if (!window.Lenis || window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return null;
  }
  const lenis = new window.Lenis({
    anchors: true,
    lerp: 0.08,
    wheelMultiplier: 0.82,
  });
  function raf(time) {
    lenis.raf(time);
    requestAnimationFrame(raf);
  }
  requestAnimationFrame(raf);
  return lenis;
}

function renderAchievements(items) {
  const groups = achievementLevels
    .map((level) => ({
      ...level,
      items: items.filter((item) => item.level === level.key),
    }))
    .filter((group) => group.items.length > 0);

  achievementsEl.innerHTML = groups.map((group) => `
    <section class="achievement-group achievement-group-${group.tone}" aria-label="${escapeHtml(group.label)}">
      <div class="achievement-group-head">
        <h3>${escapeHtml(group.label)}</h3>
        <span>${group.items.length}</span>
      </div>
      <div class="achievement-list">
        ${group.items.map((item, index) => renderAchievementCard(item, index)).join("")}
      </div>
    </section>
  `).join("");
}

function renderAchievementCard(item, index) {
  const preview = item.previewMedia || item.media;
  const imageFit = item.imageFit === "cover" ? "cover" : "contain";
  const media = isImage(item.source)
    ? `<img class="achievement-image ${imageFit}" src="${preview}" alt="${escapeHtml(item.award)}">`
    : `<div class="doc-source">${escapeHtml(item.previewLabel || item.award || item.source)}</div>`;

  const people = (item.people || []).slice(0, 5).join(" / ");
  const tags = (item.tags || []).map((tag) => `<span>${escapeHtml(tag)}</span>`).join("");

  return `
    <article class="achievement glow-surface reveal">
      <div class="achievement-media">${media}</div>
      <div class="achievement-body">
        <span class="item-index">${String(index + 1).padStart(2, "0")}</span>
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
}

function renderProjects(items) {
  projectsEl.innerHTML = items.map((item, index) => {
    const tags = (item.tags || []).map((tag) => `<span>${escapeHtml(tag)}</span>`).join("");
    const memoryPath = escapeHtml(item.memory);
    const links = (item.links || []).map((link) => `
      <a class="memory-link" href="${escapeHtml(link.href)}">${escapeHtml(link.label)}</a>
    `).join("");
    return `
      <article class="project glow-surface reveal">
        <div class="project-topline">
          <span class="project-number">${String(index + 1).padStart(2, "0")}</span>
          <p class="project-type">${escapeHtml(item.type)} / ${escapeHtml(item.status)}</p>
        </div>
        <h3>${escapeHtml(item.name)}</h3>
        <p>${escapeHtml(item.summary)}</p>
        <div class="tags">${tags}</div>
        <div class="project-actions">
          <button class="memory-link doc-button" type="button" data-path="${memoryPath}">打开知识条目：${memoryPath}</button>
          ${links}
        </div>
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

function wireActiveNavigation() {
  const navLinks = [...document.querySelectorAll(".topbar nav a[href^='#']")];
  const sections = navLinks
    .map((link) => document.querySelector(link.getAttribute("href")))
    .filter(Boolean);
  const observer = new IntersectionObserver((entries) => {
    const visible = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
    if (!visible) {
      return;
    }
    navLinks.forEach((link) => {
      link.classList.toggle("active", link.getAttribute("href") === `#${visible.target.id}`);
    });
  }, { rootMargin: "-24% 0px -58% 0px", threshold: [0.08, 0.2, 0.5] });
  sections.forEach((section) => observer.observe(section));
}

function wireScrollProgress() {
  if (!scrollProgress) {
    return;
  }
  const update = () => {
    const max = document.documentElement.scrollHeight - window.innerHeight;
    const ratio = max > 0 ? window.scrollY / max : 0;
    scrollProgress.style.transform = `scaleX(${Math.min(1, Math.max(0, ratio))})`;
  };
  update();
  window.addEventListener("scroll", update, { passive: true });
  window.addEventListener("resize", update);
}

function wireGlowSurfaces() {
  document.querySelectorAll(".glow-surface").forEach((node) => {
    node.addEventListener("pointermove", (event) => {
      const rect = node.getBoundingClientRect();
      node.style.setProperty("--glow-x", `${event.clientX - rect.left}px`);
      node.style.setProperty("--glow-y", `${event.clientY - rect.top}px`);
    });
  });
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
  statusProjects.textContent = status.projectDirectories;
  statusMedia.textContent = status.rawMediaFiles;
  siteVersion.textContent = `${showcase.site.name} ${showcase.site.version}`;

  renderAchievements(showcase.achievements || []);
  renderProjects(showcase.projects || []);
  initSmoothScroll();
  wireReveal();
  wireActiveNavigation();
  wireScrollProgress();
  wireGlowSurfaces();

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
