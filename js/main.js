// 背景のぼかし（ゆっくり漂う）を生成してページ全体に散らす
(function buildBackgroundBlobs() {
  const BLUE = 'rgba(96,164,222,.86)';
  const TEAL = 'rgba(118,198,178,.80)';
  const CREAM = 'rgba(245,164,55,.95)';
  // top%, left%, size(px), color, variant(1-3), duration(s), delay(s)
  const blobs = [
    [2,  80, 460, BLUE,  1, 18, 0],
    [8,  18, 400, TEAL,  2, 22, -4],
    [16, 60, 360, CREAM, 3, 16, -7],
    [24, 90, 500, BLUE,  2, 20, -2],
    [31, 8,  420, TEAL,  1, 24, -9],
    [39, 72, 460, CREAM, 2, 17, -12],
    [47, 30, 380, BLUE,  3, 21, -5],
    [54, 92, 520, TEAL,  1, 19, -8],
    [62, 12, 440, CREAM, 2, 23, -3],
    [68, 42, 360, BLUE,  3, 16, -1],
    [70, 70, 400, TEAL,  1, 15, -11],
    [77, 88, 480, CREAM, 3, 25, -6],
    [84, 20, 420, BLUE,  2, 18, -14],
    [90, 62, 380, TEAL,  2, 20, -2],
    [95, 6,  440, CREAM, 1, 22, -10],
  ];
  const layer = document.createElement('div');
  layer.className = 'bg-blobs';
  layer.setAttribute('aria-hidden', 'true');
  blobs.forEach(([top, left, size, color, v, dur, delay]) => {
    const b = document.createElement('span');
    b.className = 'bg-blob' + (v > 1 ? ' v' + v : '');
    b.style.top = top + '%';
    b.style.left = left + '%';
    b.style.width = size + 'px';
    b.style.height = size + 'px';
    b.style.marginLeft = -(size / 2) + 'px';
    b.style.marginTop = -(size / 2) + 'px';
    b.style.background = 'radial-gradient(closest-side, ' + color + ', transparent 72%)';
    b.style.animationDuration = dur + 's';
    b.style.animationDelay = delay + 's';
    layer.appendChild(b);
  });
  document.body.insertBefore(layer, document.body.firstChild);
})();

// マウスに追従するキラキラ（背景の丸と同じ 青・オレンジ・白 の小さな星）
(function sparkleCursor() {
  if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  if (!window.requestAnimationFrame) return;

  const canvas = document.createElement('canvas');
  canvas.setAttribute('aria-hidden', 'true');
  canvas.style.cssText = 'position:fixed;inset:0;width:100%;height:100%;pointer-events:none;z-index:9999';
  document.body.appendChild(canvas);
  const ctx = canvas.getContext('2d');

  let dpr = Math.min(window.devicePixelRatio || 1, 2);
  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width = window.innerWidth * dpr;
    canvas.height = window.innerHeight * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  resize();
  window.addEventListener('resize', resize);

  // 背景ぼかしと同じ系統の色
  const COLORS = ['rgba(96,164,222,', 'rgba(245,164,55,', 'rgba(255,255,255,'];
  const stars = [];
  const MAX = 240;

  function spawn(x, y) {
    const n = 1 + Math.floor(Math.random() * 2);
    for (let i = 0; i < n; i++) {
      stars.push({
        x: x + (Math.random() - 0.5) * 26,
        y: y + (Math.random() - 0.5) * 26,
        vx: (Math.random() - 0.5) * 0.7,
        vy: (Math.random() - 0.5) * 0.7 - 0.25,
        size: 3 + Math.random() * 6,
        rot: Math.random() * Math.PI,
        vrot: (Math.random() - 0.5) * 0.12,
        life: 0,
        ttl: 600 + Math.random() * 550,
        color: COLORS[Math.floor(Math.random() * COLORS.length)],
        scale: 0.5,
      });
    }
    if (stars.length > MAX) stars.splice(0, stars.length - MAX);
  }

  function drawStar(s, alpha) {
    const r = s.size * s.scale;
    ctx.save();
    ctx.translate(s.x, s.y);
    ctx.rotate(s.rot);
    ctx.beginPath();
    for (let i = 0; i < 8; i++) {
      const ang = (i * Math.PI) / 4;
      const rad = i % 2 === 0 ? r : r * 0.34;
      const px = Math.cos(ang) * rad;
      const py = Math.sin(ang) * rad;
      if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fillStyle = s.color + alpha + ')';
    ctx.shadowColor = s.color + '0.85)';
    ctx.shadowBlur = 7;
    ctx.fill();
    ctx.restore();
  }

  let last = 0;
  function tick(t) {
    if (!last) last = t;
    const dt = Math.min(t - last, 48);
    last = t;
    ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);
    for (let i = stars.length - 1; i >= 0; i--) {
      const s = stars[i];
      s.life += dt;
      if (s.life >= s.ttl) { stars.splice(i, 1); continue; }
      const k = s.life / s.ttl;
      s.x += s.vx;
      s.y += s.vy;
      s.vy += 0.0035 * dt;
      s.rot += s.vrot;
      const tw = Math.sin(k * Math.PI);      // 0→1→0 でキラッと点滅
      s.scale = 0.45 + tw * 0.85;
      drawStar(s, (tw * 0.9).toFixed(3));
    }
    requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);

  let lastSpawn = 0;
  window.addEventListener('mousemove', (e) => {
    const now = performance.now();
    if (now - lastSpawn < 16) return;
    lastSpawn = now;
    spawn(e.clientX, e.clientY);
  }, { passive: true });
})();

// モバイルメニューの開閉
const toggle = document.querySelector('.nav-toggle');
const menu = document.querySelector('.nav-menu');
if (toggle && menu) {
  toggle.addEventListener('click', () => {
    menu.classList.toggle('open');
  });
  menu.querySelectorAll('a').forEach(a =>
    a.addEventListener('click', () => menu.classList.remove('open'))
  );
}

// スクロールで要素をふわっと表示
const reveals = document.querySelectorAll('.reveal');
if ('IntersectionObserver' in window && reveals.length) {
  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        e.target.classList.add('in');
        io.unobserve(e.target);
      }
    });
  }, { threshold: 0.12 });
  reveals.forEach(el => io.observe(el));
} else {
  reveals.forEach(el => el.classList.add('in'));
}

// お問い合わせフォーム（Web3Forms 経由で info@trust-effort.co.jp へ送信）
const form = document.querySelector('#contact-form');
if (form) {
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const msg = document.querySelector('#form-message');
    const err = document.querySelector('#form-error');
    const btn = form.querySelector('button[type=submit]');
    const label = btn ? btn.textContent : '';
    if (err) err.style.display = 'none';
    if (msg) msg.style.display = 'none';
    if (btn) { btn.disabled = true; btn.textContent = '送信中…'; }
    try {
      const res = await fetch(form.action, {
        method: 'POST',
        headers: { Accept: 'application/json' },
        body: new FormData(form),
      });
      const data = await res.json().catch(() => ({}));
      if (res.ok && data.success) {
        form.reset();
        if (msg) { msg.style.display = 'block'; msg.scrollIntoView({ behavior: 'smooth', block: 'center' }); }
      } else {
        throw new Error(data.message || 'failed');
      }
    } catch (_) {
      if (err) { err.style.display = 'block'; err.scrollIntoView({ behavior: 'smooth', block: 'center' }); }
    } finally {
      if (btn) { btn.disabled = false; btn.textContent = label; }
    }
  });
}
