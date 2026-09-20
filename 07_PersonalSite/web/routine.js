const uploadForm = document.querySelector("#upload-form");
const fileInput = document.querySelector("#routine-file");
const uploadStatus = document.querySelector("#upload-status");
const summaryButton = document.querySelector("#summary-button");
const summaryBox = document.querySelector("#summary-box");
const seriesButtons = [...document.querySelectorAll("[data-series]")];
const monthPrev = document.querySelector("#month-prev");
const monthNext = document.querySelector("#month-next");
const calendarTitle = document.querySelector("#calendar-title");
const calendarGrid = document.querySelector("#calendar-grid");
const dayDetail = document.querySelector("#day-detail");
const calendarStatus = document.querySelector("#calendar-status");
const milestonesButton = document.querySelector("#milestones-button");
const calendarModeButtons = [...document.querySelectorAll("[data-calendar-mode]")];

let currentPayload = null;
let currentSeries = "daily";
let currentCalendarMode = "month";
let currentMonthIndex = -1;
let selectedDate = null;

const colors = ["#b7ff3c", "#e5be68", "#56ccb5", "#ef6046", "#8bb7ff", "#c99cff"];
const taskPalette = ["#b7ff3c", "#56ccb5", "#e5be68", "#8bb7ff", "#ef6046", "#c99cff", "#f6f2dd"];

const escapeHtml = (value) => String(value ?? "")
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;")
  .replaceAll("'", "&#039;");

const hours = (minutes) => `${(Number(minutes || 0) / 60).toFixed(1)}h`;

const setText = (selector, text) => {
  const node = document.querySelector(selector);
  if (node) {
    node.textContent = text;
  }
};

function taskColor(task) {
  const raw = String(task || "未命名");
  let hash = 0;
  for (const char of raw) {
    hash = (hash * 31 + char.charCodeAt(0)) >>> 0;
  }
  return taskPalette[hash % taskPalette.length];
}

function taskRingStyle(day) {
  const tasks = day.taskMinutes || day.tasks || [];
  if (!tasks.length) {
    return "rgba(255,255,255,0.08)";
  }
  const total = tasks.reduce((sum, item) => sum + Number(item.minutes || 0), 0) || 1;
  let angle = 0;
  const stops = tasks.map((item) => {
    const next = angle + (Number(item.minutes || 0) / total) * 360;
    const stop = `${taskColor(item.task)} ${angle.toFixed(1)}deg ${next.toFixed(1)}deg`;
    angle = next;
    return stop;
  });
  return `conic-gradient(${stops.join(",")})`;
}

function currentMonths() {
  return currentPayload?.stats?.calendar || [];
}

async function loadStats() {
  const response = await fetch("/api/routine/stats", { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`统计读取失败：HTTP ${response.status}`);
  }
  currentPayload = await response.json();
  render(currentPayload);
}

function cellText(value) {
  return String(value ?? "").trim();
}

function parseMinutes(value) {
  const match = cellText(value).match(/-?\d+(?:\.\d+)?/);
  return match ? Math.max(0, Math.round(Number(match[0]))) : 0;
}

function parseCompletion(value) {
  const match = cellText(value).match(/-?\d+(?:\.\d+)?/);
  return match ? Number(match[0]) : null;
}

function parseFocusTime(value) {
  const match = cellText(value).match(/(\d{4}-\d{1,2}-\d{1,2}\s+\d{1,2}:\d{2})\s*(?:至|~|-)\s*(\d{4}-\d{1,2}-\d{1,2}\s+\d{1,2}:\d{2})/);
  if (!match) {
    return null;
  }
  return {
    start: match[1].replace(" ", "T"),
    end: match[2].replace(" ", "T"),
  };
}

async function parseTomatodoFile(file) {
  if (!window.XLSX) {
    throw new Error("SheetJS 未加载");
  }
  const buffer = await file.arrayBuffer();
  const workbook = window.XLSX.read(buffer, { type: "array", cellDates: false });
  const sheet = workbook.Sheets[workbook.SheetNames[0]];
  const rows = window.XLSX.utils.sheet_to_json(sheet, { header: 1, raw: false, defval: "" });
  const headerIndex = rows.findIndex((row) => row.includes("专注时间") && row.includes("待办名称"));
  if (headerIndex === -1) {
    throw new Error("没有找到番茄 ToDo 表头");
  }
  const header = rows[headerIndex].map(cellText);
  const indexOf = (name) => header.indexOf(name);
  const timeCol = indexOf("专注时间");
  const taskCol = indexOf("待办名称");
  const minutesCol = indexOf("专注时长(分钟)");
  const noteCol = indexOf("心得");
  const statusCol = indexOf("状态");
  const completionCol = indexOf("完成度");

  return rows.slice(headerIndex + 1).map((row) => {
    const time = parseFocusTime(row[timeCol]);
    const task = cellText(row[taskCol]);
    if (!time || !task) {
      return null;
    }
    return {
      start: time.start,
      end: time.end,
      task,
      minutes: parseMinutes(row[minutesCol]),
      note: cellText(row[noteCol]),
      status: cellText(row[statusCol]),
      completion: parseCompletion(row[completionCol]),
    };
  }).filter(Boolean);
}

function render(payload) {
  const { stats, store } = payload;
  const kpis = stats.kpis || {};
  setText("#kpi-hours", Number(kpis.totalHours || 0).toFixed(1));
  setText("#kpi-records", `${stats.records?.included || 0}/${stats.records?.total || 0}`);
  setText("#kpi-days", kpis.activeDays || 0);
  setText("#kpi-streak", kpis.currentStreakDays || 0);
  setText("#store-path", store?.updatedAt ? `更新：${store.updatedAt}` : "本地数据尚未建立");

  renderCalendar(stats.calendar || [], store || {});
  renderSeries(stats[currentSeries] || []);
  renderHours(stats.hours || []);
  renderTasks(stats.tasks || []);
  renderNotes(stats.notes || []);
  renderRecords(stats.recent || []);
}

function heatLevel(minutes, max) {
  if (!minutes) return 0;
  const ratio = minutes / Math.max(1, max);
  if (ratio > 0.78) return 4;
  if (ratio > 0.50) return 3;
  if (ratio > 0.24) return 2;
  return 1;
}

function milestoneTypeName(type) {
  return ({
    start: "开始",
    finish: "完成",
    chapter: "章节",
    exercise: "做题",
    accuracy: "正确率",
    practice: "练习",
    review: "复盘",
    warning: "提醒",
    note: "备注",
    other: "节点",
  })[type] || "节点";
}

function renderCalendar(months, store) {
  if (!calendarGrid) return;
  if (!months.length) {
    calendarTitle.textContent = "等待导入";
    calendarGrid.innerHTML = `<p class="empty">上传番茄 ToDo 导出表后，这里会显示按月展开的学习日历。</p>`;
    dayDetail.innerHTML = `<p class="empty">选择某一天后，这里显示当天记录和备注节点。</p>`;
    calendarStatus.textContent = "等待导入番茄 ToDo 表格。";
    return;
  }

  calendarModeButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.calendarMode === currentCalendarMode);
  });
  if (currentMonthIndex < 0 || currentMonthIndex >= months.length) {
    currentMonthIndex = months.length - 1;
  }
  const month = months[currentMonthIndex];
  calendarTitle.textContent = currentCalendarMode === "year" ? `${month.month.slice(0, 4)}年` : month.label;
  monthPrev.disabled = currentMonthIndex <= 0;
  monthNext.disabled = currentMonthIndex >= months.length - 1;
  calendarStatus.textContent = store.milestonesGeneratedBy === "deepseek"
    ? `DeepSeek 已标注：${store.milestonesGeneratedAt || "刚刚"}`
    : "当前先用备注关键词做临时标记；点击 AI 标注可让 DeepSeek 重新判断关键节点。";

  const selectedInMonth = month.days.some((day) => day.date === selectedDate);
  if (!selectedDate || !selectedInMonth) {
    const active = [...month.days].reverse().find((day) => day.minutes || day.milestones.length || day.records.length);
    selectedDate = active?.date || month.days[0]?.date || null;
  }

  if (currentCalendarMode === "year") {
    renderYearCalendar(months, store);
  } else if (currentCalendarMode === "day") {
    renderDayCalendar(months, store);
  } else {
    renderMonthCalendar(month, months, store);
  }
}

function renderMonthCalendar(month, months, store) {
  const max = Math.max(...month.days.map((day) => day.minutes || 0), 1);
  calendarGrid.innerHTML = month.days.map((day, index) => {
    const style = [
      `--task-ring:${taskRingStyle(day)}`,
      index === 0 ? `grid-column-start:${month.weekdayStart}` : "",
    ].filter(Boolean).join(";");
    const topTask = day.tasks[0]?.task || "";
    const markers = day.milestones.slice(0, 3).map((item) => `
      <span class="milestone-chip ${item.pinned ? "is-pinned" : ""}" data-type="${escapeHtml(item.type)}">${escapeHtml(item.label)}</span>
    `).join("");
    const classNames = [
      "calendar-day",
      day.date === selectedDate ? "is-selected" : "",
      day.milestones.length ? "has-milestone" : "",
      day.notes.length ? "has-note" : "",
      day.records.length ? "has-records" : "",
    ].filter(Boolean).join(" ");
    return `
      <button class="${classNames}" data-date="${escapeHtml(day.date)}" data-level="${heatLevel(day.minutes, max)}" style="${style}">
        <span class="task-ring"></span>
        <span class="day-number">${day.day}</span>
        <strong>${day.minutes ? hours(day.minutes) : ""}</strong>
        <em>${escapeHtml(topTask)}</em>
        <span class="milestone-stack">${markers}</span>
      </button>
    `;
  }).join("");

  calendarGrid.querySelectorAll("[data-date]").forEach((button) => {
    button.addEventListener("click", () => {
      selectedDate = button.dataset.date;
      renderCalendar(months, store);
    });
  });
  renderDayDetail(month.days.find((day) => day.date === selectedDate));
}

function renderYearCalendar(months, store) {
  const year = months[currentMonthIndex]?.month.slice(0, 4);
  const yearMonths = months.filter((month) => month.month.startsWith(year));
  calendarGrid.innerHTML = `
    <div class="year-calendar">
      ${yearMonths.map((month) => {
        const total = month.days.reduce((sum, day) => sum + day.minutes, 0);
        const pins = month.days.flatMap((day) => day.milestones.map((item) => ({ ...item, date: day.date }))).slice(0, 5);
        const activeDays = month.days.filter((day) => day.minutes > 0).length;
        return `
          <button class="year-month-card" data-month="${escapeHtml(month.month)}">
            <span>${escapeHtml(month.label)}</span>
            <strong>${hours(total)}</strong>
            <em>${activeDays} 天有记录</em>
            <div class="year-pin-list">
              ${pins.map((pin) => `<i data-type="${escapeHtml(pin.type)}">${escapeHtml(pin.date.slice(5))} ${escapeHtml(pin.label)}</i>`).join("")}
            </div>
          </button>
        `;
      }).join("")}
    </div>
  `;
  calendarGrid.querySelectorAll("[data-month]").forEach((button) => {
    button.addEventListener("click", () => {
      const index = months.findIndex((month) => month.month === button.dataset.month);
      if (index >= 0) currentMonthIndex = index;
      currentCalendarMode = "month";
      selectedDate = null;
      renderCalendar(months, store);
    });
  });
  const month = months[currentMonthIndex];
  renderDayDetail(month.days.find((day) => day.date === selectedDate));
}

function renderDayCalendar(months, store) {
  const month = months[currentMonthIndex];
  const day = month.days.find((item) => item.date === selectedDate) || month.days.find((item) => item.records.length) || month.days[0];
  selectedDate = day?.date || selectedDate;
  calendarGrid.innerHTML = `
    <section class="single-day-board">
      <div class="single-day-date" style="--task-ring:${taskRingStyle(day || {})}">
        <span class="task-ring"></span>
        <strong>${escapeHtml(day?.date || "")}</strong>
        <em>${day?.minutes ? hours(day.minutes) : "0h"}</em>
      </div>
      <div class="single-day-pins">
        ${(day?.milestones || []).map((item) => `
          <article class="floating-pin" data-type="${escapeHtml(item.type)}">
            <span>${escapeHtml(milestoneTypeName(item.type))}</span>
            <strong>${escapeHtml(item.label)}</strong>
            <p>${escapeHtml(item.detail)}</p>
          </article>
        `).join("") || `<p class="empty">这一天还没有 AI 图钉。</p>`}
      </div>
    </section>
  `;
  renderDayDetail(day);
}

function renderDayDetail(day) {
  if (!day) {
    dayDetail.innerHTML = `<p class="empty">选择某一天后，这里显示当天记录和备注节点。</p>`;
    return;
  }
  const milestones = day.milestones.length
    ? day.milestones.map((item) => `
      <article class="day-milestone" data-type="${escapeHtml(item.type)}">
        <span>${escapeHtml(milestoneTypeName(item.type))}</span>
        <strong>${escapeHtml(item.label)}</strong>
        <p>${escapeHtml(item.detail)}</p>
        ${item.metric && Object.keys(item.metric).length
          ? `<div class="milestone-metrics">${Object.entries(item.metric).map(([key, value]) => `<b>${escapeHtml(key)}: ${escapeHtml(value)}</b>`).join("")}</div>`
          : ""}
      </article>
    `).join("")
    : `<p class="empty">这一天还没有关键节点标注。</p>`;
  const records = day.records.length
    ? day.records.map((item) => `
      <article class="day-record ${item.includeInStats ? "" : "is-muted"}">
        <strong>${escapeHtml(String(item.start || "").replace("T", " "))}</strong>
        <span>${escapeHtml(item.task || "")}</span>
        <span>${hours(item.minutes)}</span>
        <em>${escapeHtml(item.status || "")}</em>
        ${item.note ? `<p>${escapeHtml(item.note)}</p>` : ""}
      </article>
    `).join("")
    : `<p class="empty">这一天没有导入记录。</p>`;
  dayDetail.innerHTML = `
    <div class="day-detail-head">
      <span>${escapeHtml(day.date)}</span>
      <strong>${day.minutes ? hours(day.minutes) : "0h"}</strong>
    </div>
    <div class="day-detail-section">
      <h3>关键节点</h3>
      ${milestones}
    </div>
    <div class="day-detail-section">
      <h3>当天记录</h3>
      ${records}
    </div>
  `;
}

function valueLabel(item) {
  return item.date || item.week || item.month || item.hour || "";
}

function renderSeries(items) {
  const root = document.querySelector("#series-chart");
  if (!items.length) {
    root.innerHTML = `<p class="empty">暂无时间序列。</p>`;
    return;
  }
  const max = Math.max(...items.map((item) => item.minutes || 0), 1);
  root.innerHTML = items.map((item) => `
    <div class="bar-row">
      <span>${escapeHtml(valueLabel(item))}</span>
      <div class="bar-track"><div class="bar-fill" style="width:${Math.max(3, (item.minutes || 0) / max * 100)}%"></div></div>
      <strong>${hours(item.minutes)}</strong>
    </div>
  `).join("");
}

function renderHours(items) {
  const root = document.querySelector("#hour-chart");
  const meaningful = items.filter((item) => item.minutes > 0);
  if (!meaningful.length) {
    root.innerHTML = `<p class="empty">暂无专注时段。</p>`;
    return;
  }
  const max = Math.max(...items.map((item) => item.minutes || 0), 1);
  root.innerHTML = items.map((item) => `
    <div class="hour-row">
      <span>${escapeHtml(item.hour)}</span>
      <div class="bar-track"><div class="bar-fill" style="width:${item.minutes ? Math.max(3, item.minutes / max * 100) : 0}%"></div></div>
      <strong>${item.minutes ? hours(item.minutes) : ""}</strong>
    </div>
  `).join("");
}

function renderTasks(items) {
  const pie = document.querySelector("#task-pie");
  const list = document.querySelector("#task-list");
  if (!items.length) {
    pie.style.background = "rgba(255,255,255,0.04)";
    list.innerHTML = `<p class="empty">暂无科目统计。</p>`;
    return;
  }
  const total = items.reduce((sum, item) => sum + item.minutes, 0) || 1;
  let angle = 0;
  const stops = items.map((item, index) => {
    const next = angle + (item.minutes / total) * 360;
    const color = colors[index % colors.length];
    const stop = `${color} ${angle.toFixed(2)}deg ${next.toFixed(2)}deg`;
    angle = next;
    return stop;
  });
  pie.style.background = `conic-gradient(${stops.join(",")})`;
  list.innerHTML = items.map((item, index) => `
    <div class="task-item">
      <span class="swatch" style="background:${colors[index % colors.length]}"></span>
      <strong>${escapeHtml(item.task)}</strong>
      <span>${hours(item.minutes)}</span>
    </div>
  `).join("");
}

function renderNotes(items) {
  const root = document.querySelector("#note-list");
  if (!items.length) {
    root.innerHTML = `<p class="empty">这批记录里还没有备注。</p>`;
    return;
  }
  root.innerHTML = items.slice(0, 12).map((item) => `
    <article class="note-item">
      <strong>${escapeHtml(item.date)} / ${escapeHtml(item.task)} / ${hours(item.minutes)}</strong>
      <div>${escapeHtml(item.note)}</div>
    </article>
  `).join("");
}

function renderRecords(items) {
  const root = document.querySelector("#record-table");
  if (!items.length) {
    root.innerHTML = `<p class="empty">导入后这里显示最近 30 条记录。</p>`;
    return;
  }
  root.innerHTML = items.map((item) => `
    <article class="record-row">
      <strong>${escapeHtml(item.start.replace("T", " "))}</strong>
      <span>${escapeHtml(item.task)}</span>
      <span>${hours(item.minutes)}</span>
      <span class="record-note">${escapeHtml(item.note || "")}</span>
      <span>${escapeHtml(item.status || "")}</span>
    </article>
  `).join("");
}

uploadForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const file = fileInput.files?.[0];
  if (!file) {
    uploadStatus.textContent = "先选择一份番茄 ToDo 导出表。";
    return;
  }
  uploadStatus.textContent = "导入中...";
  const formData = new FormData();
  formData.append("file", file);
  let response;
  try {
    const records = await parseTomatodoFile(file);
    formData.append("records_json", JSON.stringify(records));
    response = await fetch("/api/routine/import-json", { method: "POST", body: formData });
  } catch (error) {
    uploadStatus.textContent = `浏览器解析失败，尝试后端导入：${error.message}`;
    response = await fetch("/api/routine/import", { method: "POST", body: formData });
  }
  if (!response.ok) {
    let detail = `HTTP ${response.status}`;
    try {
      detail = (await response.json()).detail || detail;
    } catch {}
    uploadStatus.textContent = `导入失败：${detail}`;
    return;
  }
  const result = await response.json();
  uploadStatus.textContent = `导入完成：新增 ${result.merge.added} 条，已存在/更新 ${result.merge.updated} 条，总计 ${result.merge.total} 条。`;
  await loadStats();
});

seriesButtons.forEach((button) => {
  button.addEventListener("click", () => {
    currentSeries = button.dataset.series;
    seriesButtons.forEach((item) => item.classList.toggle("active", item === button));
    if (currentPayload) {
      renderSeries(currentPayload.stats[currentSeries] || []);
    }
  });
});

calendarModeButtons.forEach((button) => {
  button.addEventListener("click", () => {
    currentCalendarMode = button.dataset.calendarMode || "month";
    if (currentPayload) {
      renderCalendar(currentPayload.stats.calendar || [], currentPayload.store || {});
    }
  });
});

monthPrev?.addEventListener("click", () => {
  if (!currentPayload || currentMonthIndex <= 0) return;
  currentMonthIndex -= 1;
  selectedDate = null;
  renderCalendar(currentPayload.stats.calendar || [], currentPayload.store || {});
});

monthNext?.addEventListener("click", () => {
  if (!currentPayload) return;
  const months = currentPayload.stats.calendar || [];
  if (currentMonthIndex >= months.length - 1) return;
  currentMonthIndex += 1;
  selectedDate = null;
  renderCalendar(months, currentPayload.store || {});
});

milestonesButton?.addEventListener("click", async () => {
  calendarStatus.textContent = "DeepSeek 正在读取备注并标注月历...";
  milestonesButton.disabled = true;
  const response = await fetch("/api/routine/milestones", { method: "POST" });
  milestonesButton.disabled = false;
  if (!response.ok) {
    let detail = `HTTP ${response.status}`;
    try {
      detail = (await response.json()).detail || detail;
    } catch {}
    calendarStatus.textContent = `AI 标注失败：${detail}`;
    return;
  }
  const data = await response.json();
  currentPayload = data.payload || currentPayload;
  selectedDate = null;
  render(currentPayload);
  calendarStatus.textContent = `AI 标注完成：${data.milestones?.length || 0} 个关键节点。`;
});

summaryButton.addEventListener("click", async () => {
  summaryBox.textContent = "生成中...";
  const response = await fetch("/api/routine/summary", { method: "POST" });
  if (!response.ok) {
    let detail = `HTTP ${response.status}`;
    try {
      detail = (await response.json()).detail || detail;
    } catch {}
    summaryBox.textContent = `暂时无法生成：${detail}`;
    return;
  }
  const data = await response.json();
  summaryBox.textContent = data.summary || "模型没有返回内容。";
});

loadStats().catch((error) => {
  uploadStatus.textContent = error.message;
});
