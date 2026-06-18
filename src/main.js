const state = {
  activeTab: 'workbench',
  modal: null,
  selectedMode: 'study',
  input: '',
  child: {
    name: '豆豆',
    age: 8,
    className: '二年级 3 班',
    avatar: '豆',
    device: '豆小宝 Watch S1',
    battery: 76,
    online: true,
    phone: '138 1024 8848',
    balance: 36.8,
    dataUsage: 1.8,
    dataLimit: 5,
    lastSync: '2 分钟前',
  },
  location: {
    place: '星河小学北门',
    status: '在安全区域内',
    updatedAt: '23:12',
    accuracy: '28m',
  },
  alerts: [
    { level: 'ok', title: '到校确认', detail: '07:58 已进入星河小学安全区' },
    { level: 'warn', title: '电量提醒', detail: '预计还能使用 8 小时，睡前建议充电' },
  ],
  messages: [
    { from: 'agent', text: '今天 16:42 已到达星河小学北门，路线稳定。' },
    { from: 'parent', text: '放学后提醒豆豆先完成阅读任务。' },
    { from: 'agent', text: '已创建 19:30 阅读提醒，并同步到手表。' },
  ],
  tasks: [
    { id: 1, title: '英语听读 15 分钟', time: '19:10', reward: 8, done: false },
    { id: 2, title: '整理明天书包', time: '20:20', reward: 6, done: true },
    { id: 3, title: '睡前刷牙打卡', time: '21:00', reward: 4, done: false },
  ],
  zones: [
    { name: '星河小学', type: '安全区', range: '300m', enabled: true },
    { name: '少年宫路口', type: '提醒区', range: '120m', enabled: true },
    { name: '城南施工段', type: '危险区', range: '200m', enabled: true },
  ],
  tracks: [
    { time: '07:36', place: '家', detail: '离家', status: '正常', distance: '0km' },
    { time: '07:51', place: '梧桐路公交站', detail: '通勤中', status: '正常', distance: '1.6km' },
    { time: '07:58', place: '星河小学', detail: '到校', status: '进入安全区', distance: '2.2km' },
    { time: '16:42', place: '星河小学北门', detail: '放学等待', status: '安全区内', distance: '2.2km' },
  ],
  contacts: [
    { name: '妈妈', relation: '管理员', phone: '138 1024 8848', trusted: true },
    { name: '爸爸', relation: '家人', phone: '136 2233 9001', trusted: true },
    { name: '班主任王老师', relation: '老师', phone: '139 0000 2016', trusted: true },
  ],
  apps: [
    { name: '电话', minutes: 12, enabled: true, locked: false },
    { name: '微聊', minutes: 18, enabled: true, locked: false },
    { name: '故事', minutes: 24, enabled: true, locked: true },
    { name: '运动', minutes: 31, enabled: true, locked: false },
  ],
  modes: [
    { id: 'study', name: '学习模式', time: '周一至周五 08:00-16:30', active: true },
    { id: 'sleep', name: '睡眠模式', time: '每天 21:30-07:00', active: true },
    { id: 'play', name: '娱乐模式', time: '每天最多 30 分钟', active: false },
  ],
  reports: {
    stars: 42,
    steps: 8650,
    sleep: '9h 10m',
    mood: '平稳',
  },
};

const tabs = [
  { id: 'workbench', label: '工作台', icon: '⌂' },
  { id: 'safety', label: '安全', icon: '⌖' },
  { id: 'growth', label: '成长', icon: '★' },
  { id: 'control', label: '管控', icon: '◐' },
  { id: 'profile', label: '我的', icon: '☰' },
];

const root = document.querySelector('#app');
let apiReady = false;

async function apiRequest(path, options = {}) {
  if (window.location.protocol === 'file:') return null;
  try {
    const response = await fetch(path, {
      headers: { 'Content-Type': 'application/json' },
      ...options,
    });
    if (!response.ok) return null;
    const payload = await response.json();
    return payload.code === 0 ? payload.data : null;
  } catch (error) {
    return null;
  }
}

async function syncRemoteState() {
  const data = await apiRequest('/api/v1/bootstrap');
  if (!data) return false;
  Object.assign(state, data);
  apiReady = true;
  render();
  return true;
}

function setState(patch) {
  Object.assign(state, patch);
  render();
}

function classNames(...items) {
  return items.filter(Boolean).join(' ');
}

function iconButton(label, icon, action, tone = '') {
  return `<button class="icon-button ${tone}" data-action="${action}" aria-label="${label}" title="${label}"><span>${icon}</span></button>`;
}

function topBar() {
  return `
    <header class="topbar">
      <div class="brand">
        <div class="brand-mark">豆</div>
        <div>
          <strong>豆小宝</strong>
          <span>家长端</span>
        </div>
      </div>
      <div class="top-actions">
        ${iconButton('消息通知', '●', 'notify')}
        ${iconButton('添加设备', '+', 'bindDevice')}
      </div>
    </header>
  `;
}

function childStatusCard() {
  const c = state.child;
  return `
    <section class="hero-panel">
      <div class="child-avatar">${c.avatar}</div>
      <div class="child-main">
        <div class="row between">
          <div>
            <h1>${c.name}</h1>
            <p>${c.className} · ${c.device}</p>
          </div>
          <span class="status-pill ${c.online ? 'ok' : 'warn'}">${c.online ? '在线' : '离线'}</span>
        </div>
        <div class="metric-strip">
          <span><b>${c.battery}%</b> 电量</span>
          <span><b>${state.location.updatedAt}</b> 定位</span>
          <span><b>${c.balance.toFixed(1)}</b> 话费</span>
        </div>
      </div>
    </section>
  `;
}

function workbench() {
  return `
    ${childStatusCard()}
    <section class="summary-band">
      <button data-action="locate"><b>${state.location.place}</b><span>${state.location.status} · ${state.location.accuracy}</span></button>
      <button data-action="track"><b>${state.tracks.length} 个轨迹点</b><span>今日路线稳定</span></button>
    </section>
    <section class="alert-stack">
      ${state.alerts.map(alertItem).join('')}
    </section>
    <section class="quick-grid">
      ${quickAction('call', '☎', '语音呼叫', '立即联系孩子')}
      ${quickAction('video', '▣', '视频呼叫', '确认状态')}
      ${quickAction('locate', '⌖', '实时定位', state.location.place)}
      ${quickAction('findWatch', '◎', '寻找手表', '响铃 60 秒')}
    </section>
    <section class="section">
      <div class="section-head">
        <h2>家庭 Agent</h2>
        <button class="text-button" data-action="openTask">新任务</button>
      </div>
      <div class="agent-stream">
        ${state.messages.map((message) => `<div class="bubble ${message.from}">${message.text}</div>`).join('')}
      </div>
      <form class="agent-input" data-form="agent">
        <button type="button" title="快捷建议" aria-label="快捷建议" data-action="suggest">＋</button>
        <input name="agentText" value="${state.input}" placeholder="让豆小宝提醒、切模式、总结今天..." />
        <button type="submit" title="发送" aria-label="发送">↑</button>
      </form>
    </section>
    <section class="section">
      <div class="section-head">
        <h2>今日任务</h2>
        <span>${state.tasks.filter((task) => task.done).length}/${state.tasks.length} 完成</span>
      </div>
      <div class="list">
        ${state.tasks.map(taskCard).join('')}
      </div>
    </section>
  `;
}

function alertItem(alert) {
  return `
    <article class="alert ${alert.level}">
      <span>${alert.level === 'ok' ? '✓' : '!'}</span>
      <div><strong>${alert.title}</strong><small>${alert.detail}</small></div>
    </article>
  `;
}

function quickAction(action, icon, title, desc) {
  return `
    <button class="quick-action" data-action="${action}">
      <span>${icon}</span>
      <strong>${title}</strong>
      <small>${desc}</small>
    </button>
  `;
}

function taskCard(task) {
  return `
    <article class="task ${task.done ? 'done' : ''}">
      <button class="check" data-action="toggleTask" data-id="${task.id}" aria-label="切换任务状态">${task.done ? '✓' : ''}</button>
      <div>
        <strong>${task.title}</strong>
        <span>${task.time} · 星能量 +${task.reward}</span>
      </div>
      <button class="ghost" data-action="remindTask" data-id="${task.id}">提醒</button>
    </article>
  `;
}

function safety() {
  return `
    <section class="map-panel">
      <div class="map-toolbar">
        <div>
          <h1>${state.location.place}</h1>
          <p>${state.location.status} · 精度 ${state.location.accuracy}</p>
        </div>
        <button class="primary" data-action="locate">刷新</button>
      </div>
      <div class="mock-map">
        <span class="road road-a"></span>
        <span class="road road-b"></span>
        <span class="zone"></span>
        <span class="map-label home">家</span>
        <span class="map-label school">学校</span>
        <span class="pin">豆</span>
      </div>
      <div class="safety-status">
        <div><strong>最近同步</strong><span>${state.location.updatedAt}</span></div>
        <div><strong>路线判断</strong><span>未发现异常绕行</span></div>
        <div><strong>守护状态</strong><span>${state.zones.filter((zone) => zone.enabled).length} 个区域开启</span></div>
      </div>
      <div class="map-actions">
        ${quickAction('track', '⌁', '历史轨迹', '查看今日路线')}
        ${quickAction('zone', '◌', '守护区域', '3 个已开启')}
        ${quickAction('findWatch', '◎', '找设备', '响铃定位')}
      </div>
    </section>
    <section class="section">
      <div class="section-head"><h2>守护区域</h2><button class="text-button" data-action="addZone">添加</button></div>
      <div class="list">${state.zones.map(zoneItem).join('')}</div>
    </section>
    <section class="section">
      <div class="section-head"><h2>今日轨迹</h2><span>辅助观察</span></div>
      <div class="timeline">${state.tracks.map((track) => `<div><time>${track.time}</time><strong>${track.place}</strong><span>${track.detail}</span></div>`).join('')}</div>
    </section>
  `;
}

function zoneItem(zone, index) {
  return `
    <article class="setting-row">
      <div>
        <strong>${zone.name}</strong>
        <span>${zone.type} · ${zone.range}</span>
      </div>
      <label class="switch"><input type="checkbox" data-action="toggleZone" data-id="${zone.id || index}" data-index="${index}" ${zone.enabled ? 'checked' : ''}><span></span></label>
    </article>
  `;
}

function trackDetail() {
  return `
    <div class="track-detail">
      ${state.tracks.map((track) => `
        <article>
          <time>${track.time}</time>
          <div>
            <strong>${track.place}</strong>
            <span>${track.detail} · ${track.status} · 距离 ${track.distance}</span>
          </div>
        </article>
      `).join('')}
    </div>
  `;
}

function zoneSummary() {
  return `
    <div class="zone-summary">
      ${state.zones.map((zone) => `
        <article>
          <strong>${zone.name}</strong>
          <span>${zone.type} · ${zone.range} · ${zone.enabled ? '已开启' : '已关闭'}</span>
        </article>
      `).join('')}
    </div>
  `;
}

function growth() {
  return `
    <section class="report-panel">
      <div>
        <h1>本周成长</h1>
        <p>报告只做辅助观察，不替代医疗或心理判断。</p>
      </div>
      <div class="score-ring"><strong>${state.reports.stars}</strong><span>星能量</span></div>
    </section>
    <section class="metric-cards">
      ${metricCard('步数', state.reports.steps.toLocaleString(), '较上周 +12%')}
      ${metricCard('睡眠', state.reports.sleep, '作息稳定')}
      ${metricCard('心情', state.reports.mood, '未见异常波动')}
    </section>
    <section class="section">
      <div class="section-head"><h2>Agent 洞察</h2><button class="text-button" data-action="weeklyPlan">下周行动</button></div>
      <div class="insight">
        <strong>建议把娱乐模式放在作业完成后开启。</strong>
        <p>本周故事应用使用集中在睡前，建议 21:00 后自动切入睡眠准备，减少反复手动提醒。</p>
      </div>
    </section>
    <section class="section">
      <div class="section-head"><h2>任务激励</h2><button class="text-button" data-action="openTask">创建</button></div>
      <div class="list">${state.tasks.map(taskCard).join('')}</div>
    </section>
  `;
}

function metricCard(label, value, detail) {
  return `<article class="metric-card"><span>${label}</span><strong>${value}</strong><small>${detail}</small></article>`;
}

function control() {
  return `
    <section class="section first">
      <div class="section-head"><h2>模式管控</h2><span>已同步</span></div>
      <div class="segmented">
        ${state.modes.map((mode) => `<button class="${state.selectedMode === mode.id ? 'active' : ''}" data-action="selectMode" data-id="${mode.id}">${mode.name}</button>`).join('')}
      </div>
      <div class="mode-detail">
        ${state.modes.map((mode) => mode.id === state.selectedMode ? `
          <strong>${mode.name}</strong>
          <span>${mode.time}</span>
          <label class="switch wide">启用 <input type="checkbox" data-action="toggleMode" data-id="${mode.id}" ${mode.active ? 'checked' : ''}><span></span></label>
        ` : '').join('')}
      </div>
    </section>
    <section class="section">
      <div class="section-head"><h2>应用使用</h2><button class="text-button" data-action="appCenter">应用中心</button></div>
      <div class="list">${state.apps.map(appItem).join('')}</div>
    </section>
    <section class="section">
      <div class="section-head"><h2>通讯白名单</h2><button class="text-button" data-action="addContact">添加</button></div>
      <div class="list">${state.contacts.map(contactItem).join('')}</div>
    </section>
    <section class="section">
      <div class="section-head"><h2>通话边界</h2><span>保护中</span></div>
      ${settingToggle('拒接陌生人', '只允许白名单联系人呼入', true, 'stranger')}
      ${settingToggle('聊天风险识别', '发现异常内容时通知家长审核', true, 'risk')}
    </section>
  `;
}

function appItem(app, index) {
  return `
    <article class="setting-row">
      <div>
        <strong>${app.name}</strong>
        <span>今日 ${app.minutes} 分钟${app.locked ? ' · 学习时段禁用' : ''}</span>
      </div>
      <label class="switch"><input type="checkbox" data-action="toggleApp" data-id="${app.id || index}" data-index="${index}" ${app.enabled ? 'checked' : ''}><span></span></label>
    </article>
  `;
}

function contactItem(contact) {
  return `
    <article class="contact">
      <div class="contact-avatar">${contact.name.slice(0, 1)}</div>
      <div>
        <strong>${contact.name}</strong>
        <span>${contact.relation} · ${contact.phone}</span>
      </div>
      <span class="mini-pill">${contact.trusted ? '白名单' : '待审核'}</span>
    </article>
  `;
}

function settingToggle(title, desc, checked, key) {
  return `
    <article class="setting-row">
      <div><strong>${title}</strong><span>${desc}</span></div>
      <label class="switch"><input type="checkbox" data-action="setting" data-id="${key}" ${checked ? 'checked' : ''}><span></span></label>
    </article>
  `;
}

function profile() {
  const c = state.child;
  return `
    ${childStatusCard()}
    <section class="device-panel">
      <div class="device-stat"><span>号码</span><strong>${c.phone}</strong></div>
      <div class="device-stat"><span>话费</span><strong>¥${c.balance.toFixed(1)}</strong></div>
      <div class="device-stat"><span>流量</span><strong>${c.dataUsage}/${c.dataLimit}GB</strong></div>
    </section>
    <section class="section">
      <div class="section-head"><h2>设备与成员</h2><span>${c.lastSync} 同步</span></div>
      ${menuRow('绑定设备', '当前 1 台手表', 'bindDevice')}
      ${menuRow('家庭成员', '3 位联系人可管理', 'members')}
      ${menuRow('SIM 与流量监管', '余额和用量提醒', 'sim')}
      ${menuRow('版本更新', '已是最新版本', 'version')}
    </section>
    <section class="section">
      <div class="section-head"><h2>服务与合规</h2></div>
      ${menuRow('客服与售后', '设备、号码、保修帮助', 'support')}
      ${menuRow('AI 与隐私设置', '授权、留存、删除数据', 'privacy')}
      ${menuRow('相关协议', '儿童隐私与家长监护说明', 'policy')}
    </section>
  `;
}

function menuRow(title, desc, action) {
  return `<button class="menu-row" data-action="${action}"><span><strong>${title}</strong><small>${desc}</small></span><b>›</b></button>`;
}

function modal() {
  if (!state.modal) return '';
  const content = {
    openTask: `
      <h2>创建任务</h2>
      <form data-form="task" class="modal-form">
        <label>任务名称<input name="title" required value="阅读课外书 15 分钟"></label>
        <label>提醒时间<input name="time" type="time" required value="19:30"></label>
        <label>星能量<input name="reward" type="number" min="1" max="20" value="6"></label>
        <button class="primary" type="submit">同步到手表</button>
      </form>
    `,
    bindDevice: `
      <h2>绑定设备</h2>
      <p>正式接口接入前，这里先保留扫码/输入绑定码流程。</p>
      <form data-form="bind" class="modal-form">
        <label>绑定码<input name="code" required value="DXB-2026"></label>
        <button class="primary" type="submit">确认绑定</button>
      </form>
    `,
    addContact: `
      <h2>添加联系人</h2>
      <form data-form="contact" class="modal-form">
        <label>姓名<input name="name" required value="外婆"></label>
        <label>关系<input name="relation" required value="家人"></label>
        <label>手机号<input name="phone" required value="137 0000 7788"></label>
        <button class="primary" type="submit">加入白名单</button>
      </form>
    `,
    addZone: `
      <h2>添加守护区域</h2>
      <form data-form="zone" class="modal-form">
        <label>区域名称<input name="name" required value="外婆家"></label>
        <label>区域类型<input name="type" required value="安全区"></label>
        <label>范围<input name="range" required value="200m"></label>
        <button class="primary" type="submit">保存并开启</button>
      </form>
    `,
    track: `
      <h2>今日轨迹详情</h2>
      <p>路线用于辅助观察，定位精度会受网络、建筑和设备状态影响。</p>
      ${trackDetail()}
      <button class="primary" data-action="closeModal">知道了</button>
    `,
    zone: `
      <h2>守护区域</h2>
      <p>开启后，孩子进入或离开对应区域时会提醒家长。</p>
      ${zoneSummary()}
      <button class="primary" data-action="addZone">添加区域</button>
    `,
    locate: `
      <h2>定位已刷新</h2>
      <p>当前在 ${state.location.place}，${state.location.status}，精度 ${state.location.accuracy}。</p>
      <div class="result-card"><strong>同步结果</strong><span>设备在线，路线稳定，未发现异常停留。</span></div>
      <button class="primary" data-action="closeModal">知道了</button>
    `,
    findWatch: `
      <h2>寻找手表</h2>
      <p>已向手表发送响铃指令。正式接入设备后，这里会显示指令送达和响铃状态。</p>
      <div class="result-card"><strong>预计响铃</strong><span>60 秒，可在手表端手动停止。</span></div>
      <button class="primary" data-action="closeModal">完成</button>
    `,
    call: `
      <h2>语音呼叫</h2>
      <p>正在准备拨打 ${state.child.name} 的手表号码。</p>
      <div class="result-card"><strong>${state.child.phone}</strong><span>白名单联系人呼叫，允许接通。</span></div>
      <button class="primary" data-action="closeModal">结束演示</button>
    `,
    video: `
      <h2>视频呼叫</h2>
      <p>视频呼叫入口已保留，后续需要接入设备音视频能力。</p>
      <div class="result-card"><strong>家长确认</strong><span>视频能力建议只对白名单管理员开放。</span></div>
      <button class="primary" data-action="closeModal">知道了</button>
    `,
    suggest: `
      <h2>快捷建议</h2>
      <div class="suggest-list">
        <button data-action="useSuggestion" data-text="今晚 19:30 提醒豆豆阅读 15 分钟">阅读提醒</button>
        <button data-action="useSuggestion" data-text="放学后如果离开学校安全区，请提醒我">离校提醒</button>
        <button data-action="useSuggestion" data-text="今晚 21:00 自动切换睡眠模式">睡眠模式</button>
      </div>
    `,
    weeklyPlan: `
      <h2>下周行动建议</h2>
      <div class="plan-list">
        <article><strong>固定睡前节奏</strong><span>20:50 整理书包，21:00 刷牙，21:30 睡眠模式。</span></article>
        <article><strong>娱乐后置</strong><span>作业任务完成后再开启故事应用 20 分钟。</span></article>
        <article><strong>安全复核</strong><span>保留学校和外婆家安全区，新增周末兴趣班提醒区。</span></article>
      </div>
      <button class="primary" data-action="closeModal">采纳为下周计划</button>
    `,
  }[state.modal] || `<h2>已记录</h2><p>该能力已作为正式工程入口保留，后续可接入真实接口。</p><button class="primary" data-action="closeModal">知道了</button>`;

  return `
    <div class="modal-backdrop" data-action="closeModal">
      <dialog open class="modal" onclick="event.stopPropagation()">
        <button class="modal-close" data-action="closeModal" aria-label="关闭">×</button>
        ${content}
      </dialog>
    </div>
  `;
}

function toast(text) {
  const node = document.createElement('div');
  node.className = 'toast';
  node.textContent = text;
  document.body.appendChild(node);
  setTimeout(() => node.remove(), 1800);
}

function nav() {
  return `
    <nav class="tabbar">
      ${tabs.map((tab) => `<button class="${state.activeTab === tab.id ? 'active' : ''}" data-tab="${tab.id}"><span>${tab.icon}</span>${tab.label}</button>`).join('')}
    </nav>
  `;
}

function currentPage() {
  return {
    workbench,
    safety,
    growth,
    control,
    profile,
  }[state.activeTab]();
}

function render() {
  root.innerHTML = `
    <main class="phone-shell">
      ${topBar()}
      <div class="page">${currentPage()}</div>
      ${nav()}
    </main>
    ${modal()}
  `;
}

async function loadRemoteState() {
  const loaded = await syncRemoteState();
  if (!loaded) console.info('Using local mock data.');
}

async function addAgentMessage(text) {
  state.messages.push({ from: 'parent', text });
  if (apiReady) {
    const childId = state.child.id || 'child_001';
    const result = await apiRequest(`/api/v1/children/${childId}/agent/messages`, {
      method: 'POST',
      body: JSON.stringify({ text }),
    });
    if (result) {
      state.messages.push({ from: 'agent', text: result.reply });
      await syncRemoteState();
      return;
    }
  }
  if (text.includes('阅读') || text.includes('任务') || text.includes('提醒')) {
    state.tasks.unshift({
      id: Date.now(),
      title: text.includes('阅读') ? '阅读课外书 15 分钟' : text.slice(0, 18),
      time: text.includes('19:30') ? '19:30' : '20:00',
      reward: 6,
      done: false,
    });
    state.messages.push({ from: 'agent', text: '已创建任务并放入今日任务列表，后端接入后会同步到手表。' });
    return;
  }
  if (text.includes('睡眠')) {
    const mode = state.modes.find((item) => item.id === 'sleep');
    if (mode) mode.active = true;
    state.messages.push({ from: 'agent', text: '已开启睡眠模式计划，今晚 21:30 自动生效。' });
    return;
  }
  state.messages.push({ from: 'agent', text: `已收到。我会把“${text.slice(0, 18)}”转成可执行提醒，接口上线后自动同步。` });
}

document.addEventListener('click', async (event) => {
  const tab = event.target.closest('[data-tab]');
  if (tab) setState({ activeTab: tab.dataset.tab });

  const actionNode = event.target.closest('[data-action]');
  if (!actionNode) return;
  const action = actionNode.dataset.action;
  const id = actionNode.dataset.id;

  if (['openTask', 'bindDevice', 'addContact'].includes(action)) setState({ modal: action });
  if (['notify', 'call', 'video', 'locate', 'findWatch', 'track', 'zone', 'addZone', 'weeklyPlan', 'appCenter', 'members', 'sim', 'version', 'support', 'privacy', 'policy', 'suggest'].includes(action)) {
    setState({ modal: action });
  }
  if (action === 'closeModal') setState({ modal: null });
  if (action === 'useSuggestion') {
    await addAgentMessage(actionNode.dataset.text);
    setState({ modal: null, activeTab: 'workbench' });
    toast('Agent 已生成可执行项');
  }
  if (action === 'toggleTask') {
    const task = state.tasks.find((item) => String(item.id) === String(id));
    if (task) {
      const done = !task.done;
      if (apiReady) {
        const result = await apiRequest(`/api/v1/tasks/${task.id}`, {
          method: 'PATCH',
          body: JSON.stringify({ done }),
        });
        if (result) {
          await syncRemoteState();
          toast(done ? '任务已完成' : '任务已恢复');
          return;
        }
      }
      task.done = done;
    }
    render();
  }
  if (action === 'remindTask') toast('提醒已同步到手表');
  if (action === 'selectMode') setState({ selectedMode: id });
});

document.addEventListener('change', async (event) => {
  const node = event.target.closest('[data-action]');
  if (!node) return;
  if (node.dataset.action === 'toggleZone') {
    const index = Number(node.dataset.index);
    const zone = state.zones[index];
    if (apiReady && zone?.id) {
      await apiRequest(`/api/v1/geo-zones/${zone.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ enabled: node.checked }),
      });
      await syncRemoteState();
    } else if (zone) {
      zone.enabled = node.checked;
    }
    toast(node.checked ? '守护区域已开启' : '守护区域已关闭');
  }
  if (node.dataset.action === 'toggleApp') {
    const index = Number(node.dataset.index);
    const app = state.apps[index];
    if (apiReady && app?.id) {
      const childId = state.child.id || 'child_001';
      await apiRequest(`/api/v1/children/${childId}/apps/${app.id}`, {
        method: 'PATCH',
        body: JSON.stringify({ enabled: node.checked }),
      });
      await syncRemoteState();
    } else if (app) {
      app.enabled = node.checked;
    }
    toast(node.checked ? '应用已允许使用' : '应用已禁用');
  }
  if (node.dataset.action === 'toggleMode') {
    const mode = state.modes.find((item) => item.id === node.dataset.id);
    if (mode) {
      if (apiReady) {
        const childId = state.child.id || 'child_001';
        await apiRequest(`/api/v1/children/${childId}/control/modes/${mode.id}`, {
          method: 'PATCH',
          body: JSON.stringify({ enabled: node.checked }),
        });
        await syncRemoteState();
      } else {
        mode.active = node.checked;
      }
    }
  }
  render();
});

document.addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = event.target;
  const data = new FormData(form);
  if (form.dataset.form === 'agent') {
    const text = data.get('agentText')?.trim();
    if (text) await addAgentMessage(text);
    state.input = '';
    render();
  }
  if (form.dataset.form === 'task') {
    if (apiReady) {
      const childId = state.child.id || 'child_001';
      const result = await apiRequest(`/api/v1/children/${childId}/tasks`, {
        method: 'POST',
        body: JSON.stringify({
          title: data.get('title'),
          time: data.get('time'),
          reward: Number(data.get('reward')),
        }),
      });
      if (result) {
        await syncRemoteState();
        setState({ modal: null, activeTab: 'growth' });
        toast('任务已创建');
        return;
      }
    }
    state.tasks.unshift({
      id: Date.now(),
      title: data.get('title'),
      time: data.get('time'),
      reward: Number(data.get('reward')),
      done: false,
    });
    setState({ modal: null, activeTab: 'growth' });
    toast('任务已创建');
  }
  if (form.dataset.form === 'zone') {
    if (apiReady) {
      const childId = state.child.id || 'child_001';
      const result = await apiRequest(`/api/v1/children/${childId}/geo-zones`, {
        method: 'POST',
        body: JSON.stringify({
          name: data.get('name'),
          type: data.get('type'),
          range: data.get('range'),
          enabled: true,
        }),
      });
      if (result) {
        state.alerts.unshift({ level: 'ok', title: '守护区域已添加', detail: `${data.get('name')} 已开启进入/离开提醒` });
        await syncRemoteState();
        setState({ modal: null, activeTab: 'safety' });
        toast('守护区域已添加');
        return;
      }
    }
    state.zones.push({
      name: data.get('name'),
      type: data.get('type'),
      range: data.get('range'),
      enabled: true,
    });
    state.alerts.unshift({ level: 'ok', title: '守护区域已添加', detail: `${data.get('name')} 已开启进入/离开提醒` });
    setState({ modal: null, activeTab: 'safety' });
    toast('守护区域已添加');
  }
  if (form.dataset.form === 'bind') {
    if (apiReady) {
      const result = await apiRequest('/api/v1/devices/bind', {
        method: 'POST',
        body: JSON.stringify({
          bindCode: data.get('code'),
          childId: state.child.id || 'child_001',
        }),
      });
      if (result) await syncRemoteState();
    }
    state.child.lastSync = '刚刚';
    setState({ modal: null });
    toast('设备绑定流程已完成');
  }
  if (form.dataset.form === 'contact') {
    if (apiReady) {
      const childId = state.child.id || 'child_001';
      const result = await apiRequest(`/api/v1/children/${childId}/contacts`, {
        method: 'POST',
        body: JSON.stringify({
          name: data.get('name'),
          relation: data.get('relation'),
          phone: data.get('phone'),
          trusted: true,
        }),
      });
      if (result) {
        await syncRemoteState();
        setState({ modal: null, activeTab: 'control' });
        toast('联系人已加入白名单');
        return;
      }
    }
    state.contacts.push({
      name: data.get('name'),
      relation: data.get('relation'),
      phone: data.get('phone'),
      trusted: true,
    });
    setState({ modal: null, activeTab: 'control' });
    toast('联系人已加入白名单');
  }
});

render();
loadRemoteState();
