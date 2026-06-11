// 背景のぼかし（ゆっくり漂う）を生成してページ全体に散らす
(function buildBackgroundBlobs() {
  const BLUE = 'rgba(96,164,222,.86)';
  const TEAL = 'rgba(118,198,178,.80)';
  const CREAM = 'rgba(246,190,108,.72)';
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
