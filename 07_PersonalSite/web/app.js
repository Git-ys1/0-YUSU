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
const agentStatusEl = document.querySelector("#agent-status");
const agentMessagesEl = document.querySelector("#agent-messages");
const agentEventsEl = document.querySelector("#agent-events");
const agentForm = document.querySelector("#agent-form");
const agentPrompt = document.querySelector("#agent-prompt");
const agentMode = document.querySelector("#agent-mode");
const agentSend = document.querySelector("#agent-send");
const workspaceStatusEl = document.querySelector("#workspace-status");
const siteViews = [...document.querySelectorAll("[data-view]")];
const viewLinks = [...document.querySelectorAll(".topbar nav [data-view-link]")];
const statusMd = document.querySelector("#status-md");
const siteVersion = document.querySelector("#site-version");

let agentSessionId = "";
let activeAssistantMessage = null;

const escapeHtml = (value) => String(value ?? "")
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;")
  .replaceAll("'", "&#039;");

const isImage = (source) => /\.(jpg|jpeg|png|webp)$/i.test(source || "");

function currentRoute() {
  const target = window.location.hash.slice(1) || "home";
  if (target === "agent" || target === "marginalia") {
    return { view: target, target };
  }
  return { view: "home", target };
}

function syncSiteView(shouldScroll = true) {
  const { view, target } = currentRoute();
  siteViews.forEach((node) => {
    node.hidden = node.dataset.view !== view;
  });
  document.body.dataset.activeView = view;

  const activeNavTarget = view === "home" && target === "search" ? "search" : view;
  viewLinks.forEach((link) => {
    const linkTarget = link.getAttribute("href")?.slice(1) || "";
    const active = linkTarget === activeNavTarget;
    link.classList.toggle("is-active", active);
    if (active) {
      link.setAttribute("aria-current", "page");
    } else {
      link.removeAttribute("aria-current");
    }
  });

  if (!shouldScroll) {
    return;
  }
  if (view === "home" && target !== "home") {
    requestAnimationFrame(() => document.getElementById(target)?.scrollIntoView({ block: "start" }));
  } else {
    window.scrollTo({ top: 0, behavior: "instant" });
  }
}

window.addEventListener("hashchange", () => syncSiteView(true));
syncSiteView(false);

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
  refreshMarginaliaStatus();

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

function appendAgentMessage(role, text) {
  const node = document.createElement("article");
  node.className = `agent-message ${role}`;
  node.innerHTML = `<span>${role === "user" ? "YUSU" : "Agent"}</span><p></p>`;
  node.querySelector("p").textContent = text;
  agentMessagesEl.append(node);
  agentMessagesEl.scrollTop = agentMessagesEl.scrollHeight;
  return node.querySelector("p");
}

function appendAgentEvent(label, detail = "") {
  const node = document.createElement("p");
  node.innerHTML = `<strong>${escapeHtml(label)}</strong>${detail ? ` <span>${escapeHtml(detail)}</span>` : ""}`;
  agentEventsEl.prepend(node);
}

function parseSseFrame(frame) {
  let event = "message";
  const data = [];
  frame.split(/\r?\n/).forEach((line) => {
    if (line.startsWith("event:")) {
      event = line.slice(6).trim();
    } else if (line.startsWith("data:")) {
      data.push(line.slice(5).trimStart());
    }
  });
  return { event, data: data.join("\n") };
}

async function refreshMarginaliaStatus() {
  try {
    const response = await fetch("/api/marginalia/status");
    const status = await response.json();
    if (!status.online) {
      agentStatusEl.textContent = "Marginalia API 未启动";
      workspaceStatusEl.textContent = "Marginalia API 未启动";
      appendAgentEvent("offline", status.error || "127.0.0.1:8000");
      return;
    }
    const summary = `${status.llmProvider || "LLM"} / ${status.llmModel || "model"} / semantic ${status.semanticRecall ? "on" : "off"}`;
    agentStatusEl.textContent = summary;
    workspaceStatusEl.textContent = summary;
    appendAgentEvent("ready", `${status.apiBase} -> ${status.llmModel || "unknown"}`);
  } catch (error) {
    agentStatusEl.textContent = "Marginalia 状态读取失败";
    workspaceStatusEl.textContent = "Marginalia 状态读取失败";
    appendAgentEvent("status error", error.message);
  }
}

async function ensureAgentSession(initialQuestion) {
  if (agentSessionId) {
    return agentSessionId;
  }
  const response = await fetch("/api/agent/session", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ initiatingUserMessage: initialQuestion })
  });
  const data = await response.json();
  if (!response.ok || data.error) {
    throw new Error(data.error || `HTTP ${response.status}`);
  }
  agentSessionId = data.session_id;
  appendAgentEvent("session", agentSessionId);
  return agentSessionId;
}

function handleAgentFrame(frame) {
  const { event, data } = parseSseFrame(frame);
  if (!event || event === "message") {
    return;
  }
  if (event === "answer") {
    if (!activeAssistantMessage) {
      activeAssistantMessage = appendAgentMessage("assistant", "");
    }
    activeAssistantMessage.textContent = data;
    agentMessagesEl.scrollTop = agentMessagesEl.scrollHeight;
    return;
  }
  if (event === "error") {
    appendAgentEvent("error", data);
    if (!activeAssistantMessage) {
      activeAssistantMessage = appendAgentMessage("assistant", "");
    }
    activeAssistantMessage.textContent = data || "Agent 调用失败";
    return;
  }
  if (event === "done") {
    appendAgentEvent("done", data);
    activeAssistantMessage = null;
    return;
  }
  appendAgentEvent(event, data.slice(0, 220));
}

async function askAgent(query) {
  const sessionId = await ensureAgentSession(query);
  appendAgentMessage("user", query);
  activeAssistantMessage = appendAgentMessage("assistant", "思考中...");
  agentSend.disabled = true;

  const response = await fetch("/api/agent/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ sessionId, query, mode: agentMode.value || "deep" })
  });
  if (!response.body) {
    throw new Error("浏览器不支持流式读取");
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  while (true) {
    const { value, done } = await reader.read();
    if (done) {
      break;
    }
    buffer += decoder.decode(value, { stream: true });
    const frames = buffer.split(/\r?\n\r?\n/);
    buffer = frames.pop() || "";
    frames.filter(Boolean).forEach(handleAgentFrame);
  }
  if (buffer.trim()) {
    handleAgentFrame(buffer);
  }
}

agentForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const query = agentPrompt.value.trim();
  if (!query) {
    return;
  }
  agentPrompt.value = "";
  askAgent(query).catch((error) => {
    appendAgentEvent("agent error", error.message);
    if (!activeAssistantMessage) {
      activeAssistantMessage = appendAgentMessage("assistant", "");
    }
    activeAssistantMessage.textContent = error.message;
    activeAssistantMessage = null;
  }).finally(() => {
    agentSend.disabled = false;
  });
});

boot().catch((error) => {
  console.error(error);
  document.body.insertAdjacentHTML("afterbegin", `<div class="empty">站点数据加载失败：${escapeHtml(error.message)}</div>`);
});
