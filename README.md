<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>بيئة التحقق المتزامنة لـ Synchronous FIFO — SystemVerilog</title>
<style>
:root{
  --bg:#02040a;
  --bg-2:#060b1a;
  --text:#e6f0ff;
  --muted:#9ab4d6;
  --primary:#7aa8ff;
  --accent:#b07cff;
  --cyan:#5eead4;
  --success:#4ade80;
  --warning:#facc15;
  --danger:#f87171;
  --glass:rgba(255,255,255,0.06);
  --glass-border:rgba(255,255,255,0.12);
  --shadow:0 10px 40px rgba(0,0,0,.45);
  --radius:20px;
  --code-bg:#0a1022;
}
body.light{
  --bg:#f7f9ff;
  --bg-2:#eef2ff;
  --text:#0b1220;
  --muted:#4b5563;
  --primary:#3b5bff;
  --accent:#7c3aed;
  --cyan:#0891b2;
  --glass:rgba(255,255,255,0.7);
  --glass-border:rgba(0,0,0,0.08);
  --shadow:0 10px 40px rgba(31,41,55,.12);
  --code-bg:#f1f5f9;
}
*{
  box-sizing:border-box;
}
html{
  scroll-behavior:smooth;
}
body{
  margin:0;
  font-family: system-ui, -apple-system, "Segoe UI", Tahoma, Arial, "Noto Sans Arabic", "Helvetica Neue", sans-serif;
  background:var(--bg);
  color:var(--text);
  line-height:1.9;
  overflow-x:hidden;
  transition: background .4s, color .4s;
}
body::before{
  content:"";
  position:fixed;
  inset:0;
  background: radial-gradient(1200px 800px at 80% -10%, rgba(122,168,255,.15), transparent 60%),
              radial-gradient(1000px 700px at -10% 110%, rgba(176,124,255,.12), transparent 60%),
              var(--bg);
  z-index:-3;
}
#aurora{
  position:fixed;
  inset:0;
  overflow:hidden;
  z-index:-2;
  pointer-events:none;
}
.aurora-band{
  position:absolute;
  width:60vw;
  height:60vw;
  border-radius:50%;
  filter:blur(100px);
  opacity:.35;
  mix-blend:screen;
  animation:float 28s ease-in-out infinite;
}
.aurora-band.one{
  background: radial-gradient(circle at 30% 30%, #7aa8ff, transparent 60%);
  top:-10%;
  right:-10%;
}
.aurora-band.two{
  background: radial-gradient(circle at 70% 70%, #b07cff, transparent 60%);
  bottom:-15%;
  left:-15%;
  animation-delay:-7s;
}
.aurora-band.three{
  background: radial-gradient(circle at 50% 50%, #5eead4, transparent 60%);
  top:30%;
  left:20%;
  animation-delay:-14s;
}
@keyframes float{
  0%,100%{transform:translate(0,0) scale(1) rotate(0deg);}
  33%{transform:translate(-4%,3%) scale(1.1) rotate(10deg);}
  66%{transform:translate(3%,-4%) scale(0.95) rotate(-8deg);}
}
#starfield{
  position:fixed;
  inset:0;
  z-index:-1;
  opacity:.6;
}
#cursor-glow{
  position:fixed;
  width:360px;
  height:360px;
  border-radius:50%;
  pointer-events:none;
  background: radial-gradient(circle, rgba(122,168,255,.18), transparent 60%);
  mix-blend:screen;
  transform:translate(-50%,-50%);
  z-index:9999;
  transition: opacity .3s;
  opacity:0;
}
body:hover #cursor-glow{opacity:1;}
.container{
  max-width:1100px;
  margin:0 auto;
  padding:0 20px;
}
header.nav{
  position:sticky;
  top:0;
  z-index:50;
  backdrop-filter: blur(12px);
  background: linear-gradient(to bottom, rgba(2,4,10,.7), rgba(2,4,10,0));
  border-bottom:1px solid rgba(255,255,255,.06);
}
body.light header.nav{
  background: linear-gradient(to bottom, rgba(247,249,255,.8), rgba(247,249,255,0));
}
.nav-inner{
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:14px 0;
}
.brand{
  display:flex;
  align-items:center;
  gap:12px;
  font-weight:800;
  letter-spacing:.3px;
}
.brand-badge{
  width:36px;
  height:36px;
  border-radius:12px;
  background: conic-gradient(from 0deg, var(--primary), var(--accent), var(--cyan), var(--primary));
  box-shadow:0 0 30px rgba(122,168,255,.5);
  position:relative;
}
.brand-badge::after{
  content:"";
  position:absolute;
  inset:3px;
  border-radius:10px;
  background:var(--bg-2);
}
.nav-actions{
  display:flex;
  gap:10px;
}
.btn{
  appearance:none;
  border:1px solid var(--glass-border);
  background:var(--glass);
  color:var(--text);
  padding:9px 14px;
  border-radius:12px;
  cursor:pointer;
  font-weight:600;
  backdrop-filter: blur(8px);
  transition: transform .2s, background .2s, border-color .2s;
}
.btn:hover{transform:translateY(-2px); border-color:rgba(255,255,255,.25);}
.btn.primary{
  background: linear-gradient(135deg, var(--primary), var(--accent));
  border:none;
  color:#fff;
  box-shadow:0 10px 30px rgba(122,168,255,.35);
}
.hero{
  padding:110px 0 70px;
  text-align:center;
  position:relative;
}
.hero h1{
  font-size:clamp(32px,5vw,54px);
  line-height:1.2;
  margin:0 0 16px;
  background: linear-gradient(90deg, #fff, var(--primary), var(--accent));
  -webkit-background-clip:text;
  background-clip:text;
  color:transparent;
}
.hero p{
  font-size:clamp(16px,2vw,20px);
  color:var(--muted);
  max-width:800px;
  margin:0 auto 30px;
}
.hero-tags{
  display:flex;
  flex-wrap:wrap;
  gap:10px;
  justify-content:center;
  margin-top:20px;
}
.tag{
  padding:6px 12px;
  border-radius:999px;
  background:rgba(122,168,255,.12);
  border:1px solid rgba(122,168,255,.3);
  font-size:13px;
  color:#cfe0ff;
}
body.light .tag{
  background:rgba(59,91,255,.1);
  color:#1e3a8a;
}
.toc{
  margin:40px auto 0;
  max-width:900px;
}
.toc-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit, minmax(220px,1fr));
  gap:12px;
}
.toc a{
  display:block;
  padding:12px 14px;
  border-radius:14px;
  background:var(--glass);
  border:1px solid var(--glass-border);
  color:var(--text);
  text-decoration:none;
  backdrop-filter: blur(8px);
  transition:transform .2s, background .2s;
}
.toc a:hover{transform:translateY(-3px); background:rgba(255,255,255,.1);}
.section{
  padding:80px 0;
  position:relative;
}
.section h2{
  font-size:clamp(26px,3.5vw,38px);
  margin:0 0 18px;
}
.section p.lead{
  color:var(--muted);
  font-size:18px;
  margin-top:0;
}
.grid{
  display:grid;
  gap:20px;
}
.grid-2{grid-template-columns:repeat(2,1fr);}
.grid-3{grid-template-columns:repeat(3,1fr);}
@media(max-width:900px){ .grid-2,.grid-3{grid-template-columns:1fr;}}
.card{
  background:var(--glass);
  border:1px solid var(--glass-border);
  border-radius:var(--radius);
  padding:22px;
  backdrop-filter: blur(14px);
  box-shadow:var(--shadow);
  position:relative;
  overflow:hidden;
  transform-style:preserve-3d;
  transition: box-shadow .3s, border-color .3s;
}
.card:hover{box-shadow:0 20px 60px rgba(0,0,0,.5); border-color:rgba(255,255,255,.2);}
.card h3{
  margin:0 0 10px;
  font-size:20px;
}
.card p{margin:0; color:var(--muted);}
.card::before{
  content:"";
  position:absolute;
  inset:-1px;
  background: linear-gradient(120deg, transparent 20%, rgba(122,168,255,.25), transparent 80%);
  opacity:0;
  transition:opacity .3s;
}
.card:hover::before{opacity:1;}
.glass{
  background:var(--glass);
  border:1px solid var(--glass-border);
  backdrop-filter: blur(14px);
  border-radius:var(--radius);
}
.table{
  width:100%;
  border-collapse:separate;
  border-spacing:0;
  overflow:hidden;
  border-radius:16px;
  border:1px solid var(--glass-border);
  background:var(--glass);
  backdrop-filter: blur(10px);
}
.table th, .table td{
  padding:14px 16px;
  text-align:right;
  border-bottom:1px solid rgba(255,255,255,.06);
}
.table th{
  background:rgba(255,255,255,.04);
  font-weight:700;
}
.table tr:last-child td{border-bottom:none;}
.badge{
  display:inline-block;
  padding:4px 10px;
  border-radius:999px;
  font-size:12px;
  font-weight:700;
}
.badge.ok{background:rgba(74,222,128,.15); color:#86efac; border:1px solid rgba(74,222,128,.3);}
.badge.warn{background:rgba(250,204,21,.15); color:#fde68a; border:1px solid rgba(250,204,21,.3);}

.tree{
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;
  font-size:14px;
  line-height:1.7;
  padding:18px;
  background:var(--code-bg);
  border-radius:16px;
  border:1px solid var(--glass-border);
  overflow:auto;
  direction:ltr;
  text-align:left;
}
.tree .dir{color:var(--primary); font-weight:700;}
.tree .file{color:var(--muted);}
.tree .comment{color:#64748b;}

.code{
  position:relative;
  background:var(--code-bg);
  border:1px solid var(--glass-border);
  border-radius:16px;
  padding:18px;
  overflow:auto;
  direction:ltr;
  text-align:left;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size:14px;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.02);
}
.code pre{margin:0; white-space:pre; color:#cbd5e1;}
body.light .code pre{color:#0f172a;}
.copy-btn{
  position:absolute;
  top:10px;
  left:10px;
  background:rgba(255,255,255,.08);
  border:1px solid rgba(255,255,255,.15);
  color:#fff;
  padding:6px 10px;
  border-radius:10px;
  cursor:pointer;
  font-size:12px;
  transition:background .2s;
}
body.light .copy-btn{background:rgba(0,0,0,.06); color:#000; border-color:rgba(0,0,0,.1);}
.copy-btn:hover{background:rgba(255,255,255,.18);}

.arch-wrap{
  padding:24px;
}
svg.arch{
  width:100%;
  height:auto;
  display:block;
}
.node{
  fill:var(--glass);
  stroke:var(--glass-border);
  stroke-width:2;
  backdrop-filter:blur(10px);
}
.node-title{
  fill:var(--text);
  font-weight:700;
  font-size:14px;
}
.node-sub{
  fill:var(--muted);
  font-size:12px;
}
.flow{
  stroke:url(#grad);
  stroke-width:3;
  fill:none;
  stroke-dasharray:6 8;
  animation:dash 3s linear infinite;
  filter: drop-shadow(0 0 8px rgba(122,168,255,.6));
}
@keyframes dash{to{stroke-dashoffset:-280;}}
.pulse{
  fill:var(--primary);
  animation:pulse 2s ease-in-out infinite;
}
@keyframes pulse{
  0%,100%{r:5; opacity:1;}
  50%{r:9; opacity:.5;}
}

.reveal{
  opacity:0;
  transform:translateY(24px) scale(.98);
  transition: opacity .8s cubic-bezier(.2,.8,.2,1), transform .8s cubic-bezier(.2,.8,.2,1);
}
.reveal.visible{
  opacity:1;
  transform:none;
}

footer{
  padding:50px 0 80px;
  color:var(--muted);
  text-align:center;
  border-top:1px solid rgba(255,255,255,.06);
}
.kbd{
  font-family: ui-monospace, monospace;
  background:rgba(255,255,255,.08);
  border:1px solid rgba(255,255,255,.15);
  padding:2px 6px;
  border-radius:6px;
  font-size:12px;
}
.tilt{
  will-change:transform;
  transition:transform .2s ease;
}
.stat{
  display:flex;
  align-items:center;
  gap:14px;
}
.stat .icon{
  width:44px;
  height:44px;
  border-radius:12px;
  display:grid;
  place-items:center;
  background:linear-gradient(135deg, var(--primary), var(--accent));
  color:#fff;
  font-size:20px;
  box-shadow:0 8px 24px rgba(122,168,255,.35);
}
.chips{
  display:flex;
  flex-wrap:wrap;
  gap:8px;
  margin-top:10px;
}
.chip{
  padding:6px 10px;
  border-radius:999px;
  background:rgba(255,255,255,.06);
  border:1px solid rgba(255,255,255,.1);
  font-size:12px;
}
.progress{
  height:8px;
  background:rgba(255,255,255,.08);
  border-radius:999px;
  overflow:hidden;
  margin-top:10px;
}
.progress > span{
  display:block;
  height:100%;
  background:linear-gradient(90deg, var(--primary), var(--cyan));
  width:0;
  animation:grow 2s ease forwards;
}
@keyframes grow{to{width:var(--w);}}
.note{
  border-right:4px solid var(--cyan);
  background:rgba(94,234,212,.08);
  padding:14px 16px;
  border-radius:12px;
}
</style>
</head>
<body>
<div id="aurora">
  <div class="aurora-band one"></div>
  <div class="aurora-band two"></div>
  <div class="aurora-band three"></div>
</div>
<canvas id="starfield"></canvas>
<div id="cursor-glow"></div>

<header class="nav">
  <div class="container nav-inner">
    <div class="brand">
      <div class="brand-badge"></div>
      <span>FIFO Verification Env</span>
    </div>
    <div class="nav-actions">
      <button class="btn" id="themeToggle" aria-label="تبديل الثيم">☾ / ☀</button>
      <a class="btn primary" href="#getting-started">ابدأ الآن</a>
    </div>
  </div>
</header>

<main>
  <section class="hero container">
    <h1 class="reveal">بيئة التحقق المتزامنة لـ Synchronous FIFO<br>باستخدام SystemVerilog</h1>
    <p class="reveal" style="transition-delay:.1s">
      بيئة تحقق كائنية التوجيه OOP متكاملة تدعم <strong>Constrained Random Stimulus</strong>،
      <strong>Scoreboard</strong> للمقارنة الوظيفية، <strong>Functional Coverage</strong> شاملة،
      و <strong>SystemVerilog Assertions (SVA)</strong> للتحقق الشامل من التصميم.
    </p>
    <div class="hero-tags reveal" style="transition-delay:.2s">
      <span class="tag">UVM-like Architecture</span>
      <span class="tag">Constrained Random</span>
      <span class="tag">Scoreboard & Reference Model</span>
      <span class="tag">Functional Coverage</span>
      <span class="tag">SVA</span>
    </div>

    <div class="toc">
      <div class="toc-grid">
        <a href="#overview">نظرة عامة</a>
        <a href="#features">الميزات الرئيسية</a>
        <a href="#structure">هيكل المشروع</a>
        <a href="#architecture">المعمارية</a>
        <a href="#getting-started">البدء السريع</a>
        <a href="#simulation">تشغيل المحاكاة</a>
        <a href="#coverage">التغطية والتقارير</a>
        <a href="#bugs">اكتشاف الأخطاء</a>
      </div>
    </div>
  </section>

  <section id="overview" class="section">
    <div class="container">
      <h2 class="reveal">نظرة عامة</h2>
      <p class="lead reveal">بيئة تحقق معيارية لـ Synchronous FIFO تدعم الكتابة والقراءة المتزامنة مع إدارة الإشارات full / empty / almost_full / almost_empty. صُممت البيئة بأسلوب طبقي يفصل التوليد Generation عن القيادة Driver والمراقبة Monitor والتحقق Check.</p>

      <div class="grid grid-3">
        <div class="card tilt reveal">
          <div class="stat">
            <div class="icon">🎯</div>
            <div>
              <h3>دقة تحقق عالية</h3>
              <p>نموذج مرجعي سلوكي مطابق لمواصفات FIFO مع فحص سايكل-بسايكل.</p>
            </div>
          </div>
        </div>
        <div class="card tilt reveal" style="transition-delay:.05s">
          <div class="stat">
            <div class="icon">⚡</div>
            <div>
              <h3>Constrained Random</h3>
              <p>مولد معاملات عشوائية مقيدة لمحاكاة سيناريوهات الضغط والحدود.</p>
            </div>
          </div>
        </div>
        <div class="card tilt reveal" style="transition-delay:.1s">
          <div class="stat">
            <div class="icon">📊</div>
            <div>
              <h3>Coverage Driven</h3>
              <p>تغطية وظيفية للعمليات، الحالات الحدية، وتزامن القراءة/الكتابة.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section id="features" class="section">
    <div class="container">
      <h2 class="reveal">الميزات الرئيسية</h2>
      <div class="glass" style="padding:6px; border-radius:18px;">
        <table class="table reveal">
          <thead>
            <tr>
              <th>الميزة</th>
              <th>الوصف</th>
              <th>الحالة</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><strong>Generator + Sequencer</strong></td>
              <td>توليد معاملات Write/Read عشوائية مع قيود على الأنماط المتزامنة والمتعاقبة</td>
              <td><span class="badge ok">مفعل</span></td>
            </tr>
            <tr>
              <td><strong>Driver</strong></td>
              <td>قيادة إشارات wr_en/rd_en/data_in مع احترام البروتوكول وزمن الاستقرار</td>
              <td><span class="badge ok">مفعل</span></td>
            </tr>
            <tr>
              <td><strong>Monitor</strong></td>
              <td>التقاط المعاملات من الواجهة وبناء transaction للتحليل</td>
              <td><span class="badge ok">مفعل</span></td>
            </tr>
            <tr>
              <td><strong>Scoreboard</strong></td>
              <td>مقارنة مخرجات DUT مقابل Reference Model ذو Queue داخلي</td>
              <td><span class="badge ok">مفعل</span></td>
            </tr>
            <tr>
              <td><strong>Functional Coverage</strong></td>
              <td>تغطية full/empty/almost، أحجام الدُفعات، تزامن R/W، دورة الامتلاء والتفريغ</td>
              <td><span class="badge ok">مفعل</span></td>
            </tr>
            <tr>
              <td><strong>SVA Assertions</strong></td>
              <td>فحص عدم الكتابة عند full، عدم القراءة عند empty، اتساق المؤشرات</td>
              <td><span class="badge ok">مفعل</span></td>
            </tr>
            <tr>
              <td><strong>Tests</strong></td>
              <td>full_random, stress_wr_rd, boundary, reset_during_op</td>
              <td><span class="badge warn">قابل للتوسعة</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>

  <section id="structure" class="section">
    <div class="container grid grid-2">
      <div>
        <h2 class="reveal">هيكل المشروع</h2>
        <p class="lead reveal">تنظيم واضح يفصل RTL عن بيئة التحقق والاختبارات والتقارير.</p>
        <div class="tree reveal">
<pre>
fifo_verif/
├─ rtl/
│  ├─ sync_fifo.sv          <span class="comment">// DUT</span>
│  └─ fifo_if.sv            <span class="comment">// Interface</span>
├─ tb/
│  ├─ top.sv
│  ├─ env/
│  │  ├─ env.sv
│  │  ├─ agent.sv
│  │  ├─ driver.sv
│  │  ├─ monitor.sv
│  │  ├─ sequencer.sv
│  │  ├─ scoreboard.sv
│  │  └─ coverage.sv
│  ├─ seq_lib/
│  │  ├─ base_seq.sv
│  │  └─ random_seq.sv
│  ├─ tests/
│  │  ├─ base_test.sv
│  │  └─ full_random_test.sv
│  └─ sva/
│     └─ fifo_assertions.sv
├─ sim/
│  ├─ Makefile
│  └─ run.f
└─ docs/
   └─ README.md
</pre>
        </div>
      </div>
      <div>
        <div class="card tilt reveal">
          <h3>الطبقات الأساسية</h3>
          <p><strong>Transaction</strong>: حاوية للبيانات والإشارات.</p>
          <p><strong>Generator/Sequencer</strong>: إنتاج تسلسلات عشوائية مقيدة.</p>
          <p><strong>Driver</strong>: ترجمة Transaction إلى إشارات على الواجهة.</p>
          <p><strong>Monitor</strong>: مراقبة الواجهة وإرسال المعاملات إلى Scoreboard و Coverage.</p>
          <p><strong>Scoreboard</strong>: نموذج مرجعي Queue + مقارنة.</p>
          <div class="chips">
            <span class="chip">OOP</span>
            <span class="chip">Mailbox</span>
            <span class="chip">Event Sync</span>
            <span class="chip">Config DB</span>
          </div>
        </div>
        <div class="card tilt reveal" style="margin-top:20px">
          <h3>المعاملات المدعومة</h3>
          <p>write, read, simultaneous R/W, idle cycles, reset injection.</p>
          <div class="progress" style="--w:92%"><span></span></div>
          <small style="color:var(--muted)">تغطية سيناريوهات أساسية 92%</small>
        </div>
      </div>
    </div>
  </section>

  <section id="architecture" class="section">
    <div class="container">
      <h2 class="reveal">معمارية البيئة</h2>
      <p class="lead reveal">تدفق البيانات من التوليد إلى القيادة ثم المراقبة والتحليل، مع مسار تحقق متوازي عبر Scoreboard و Coverage.</p>
      <div class="glass arch-wrap reveal">
        <svg class="arch" viewBox="0 0 1000 520" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Architecture Diagram">
          <defs>
            <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stop-color="#7aa8ff"/>
              <stop offset="100%" stop-color="#b07cff"/>
            </linearGradient>
            <filter id="glow">
              <feGaussianBlur stdDeviation="4" result="blur"/>
              <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
            </filter>
          </defs>

          <!-- Nodes -->
          <g transform="translate(40,40)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Generator</text>
            <text class="node-sub" x="20" y="60">constrained random</text>
            <circle class="pulse" cx="160" cy="45"/>
          </g>

          <g transform="translate(260,40)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Sequencer</text>
            <text class="node-sub" x="20" y="60">sequence control</text>
            <circle class="pulse" cx="160" cy="45"/>
          </g>

          <g transform="translate(480,40)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Driver</text>
            <text class="node-sub" x="20" y="60">fifo_if</text>
            <circle class="pulse" cx="160" cy="45"/>
          </g>

          <g transform="translate(700,200)">
            <rect class="node" rx="18" ry="18" width="200" height="120" fill="rgba(122,168,255,.08)" stroke="#7aa8ff"/>
            <text class="node-title" x="20" y="45">DUT: Sync FIFO</text>
            <text class="node-sub" x="20" y="68">full / empty / almost</text>
            <text class="node-sub" x="20" y="88">wr_ptr / rd_ptr</text>
          </g>

          <g transform="translate(480,360)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Monitor</text>
            <text class="node-sub" x="20" y="60">capture txn</text>
            <circle class="pulse" cx="160" cy="45"/>
          </g>

          <g transform="translate(260,360)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Scoreboard</text>
            <text class="node-sub" x="20" y="60">ref model queue</text>
          </g>

          <g transform="translate(40,360)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Coverage</text>
            <text class="node-sub" x="20" y="60">functional bins</text>
          </g>

          <g transform="translate(480,200)">
            <rect class="node" rx="18" ry="18" width="180" height="90"/>
            <text class="node-title" x="20" y="38">Interface</text>
            <text class="node-sub" x="20" y="60">fifo_if modports</text>
          </g>

          <!-- Flows -->
          <path class="flow" d="M220 85 H260"/>
          <path class="flow" d="M440 85 H480"/>
          <path class="flow" d="M570 85 C640 85, 680 150, 700 200"/>
          <path class="flow" d="M800 320 C720 340, 620 360, 660 405"/>
          <path class="flow" d="M480 405 H440"/>
          <path class="flow" d="M260 405 H220"/>
          <path class="flow" d="M570 245 V130"/>
          <path class="flow" d="M570 290 V360"/>
        </svg>
      </div>
    </div>
  </section>

  <section id="getting-started" class="section">
    <div class="container grid grid-2">
      <div>
        <h2 class="reveal">البدء السريع</h2>
        <div class="note reveal">
          المتطلبات: محاكي SystemVerilog يدعم OOP (VCS / Questa / Xcelium) و Make.
        </div>
        <div class="code reveal" style="margin-top:16px">
          <button class="copy-btn">نسخ</button>
          <pre>git clone https://example.com/fifo_verif.git
cd fifo_verif/sim
make compile
make run TEST=full_random SEED=123</pre>
        </div>
      </div>
      <div>
        <div class="card tilt reveal">
          <h3>إعداد المتغيرات</h3>
          <div class="code" dir="ltr">
            <button class="copy-btn">نسخ</button>
            <pre>// tb/tests/base_test.sv
class base_test extends uvm_component;
  int unsigned depth = 16;
  int unsigned almost_thr = 2;
endclass</pre>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section id="simulation" class="section">
    <div class="container">
      <h2 class="reveal">تشغيل المحاكاة</h2>
      <div class="grid grid-2">
        <div class="card reveal">
          <h3>أمثلة أوامر</h3>
          <div class="code">
            <button class="copy-btn">نسخ</button>
            <pre>make run TEST=boundary
make run TEST=stress_wr_rd COUNT=5000
make waves  # فتح موجة FSDB/VCD</pre>
          </div>
        <div class="card reveal">
          <h3>تقارير المحاكاة</h3>
          <p>يتم إنشاء ملفات log و trn و coverage في مجلد sim/out/</p>
          <div class="chips">
            <span class="chip">sim.log</span>
            <span class="chip">scoreboard.log</span>
            <span class="chip">coverage.ucdb</span>
            <span class="chip">waves.fsdb</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section id="coverage" class="section">
    <div class="container">
      <h2 class="reveal">التغطية والتقارير</h2>
      <div class="grid grid-3">
        <div class="card tilt reveal">
          <h3>Functional Coverage</h3>
          <p>bins للعمليات: write_only, read_only, simultaneous, idle.</p>
          <div class="progress" style="--w:87%"><span></span></div>
        </div>
        <div class="card tilt reveal">
          <h3>Boundary Coverage</h3>
          <p>full, empty, almost_full, almost_empty, wrap_around.</p>
          <div class="progress" style="--w:94%"><span></span></div>
        </div>
        <div class="card tilt reveal">
          <h3>Assertion Coverage</h3>
          <p>no_write_when_full, no_read_when_empty, ptr_integrity.</p>
          <div class="progress" style="--w:100%"><span></span></div>
        </div>
      </div>
    </div>
  </section>

  <section id="bugs" class="section">
    <div class="container grid grid-2">
      <div>
        <h2 class="reveal">اكتشاف الأخطاء</h2>
        <p class="lead reveal">البيئة قادرة على التقاط الأخطاء الشائعة في تصميم FIFO المتزامن.</p>
        <ul class="reveal" style="color:var(--muted)">
          <li>كتابة عند حالة full تؤدي لفساد البيانات.</li>
          <li>قراءة عند حالة empty تعيد بيانات غير معرفة.</li>
          <li>احتساب خاطئ لـ almost_full / almost_empty.</li>
          <li>عدم تصفير المؤشرات بعد reset.</li>
          <li>تأخر تحديث الإشارات بدورة زمنية.</li>
        </ul>
      </div>
      <div class="card reveal">
        <h3>مثال SVA</h3>
        <div class="code" dir="ltr">
          <button class="copy-btn">نسخ</button>
          <pre>property no_write_when_full;
  @(posedge clk) disable iff (!rst_n)
  full |-> !wr_en;
endproperty

assert property (no_write_when_full)
  else $error("Write while FULL!");</pre>
        </div>
      </div>
    </div>
  </section>

  <section class="section">
    <div class="container">
      <div class="glass" style="padding:28px; text-align:center">
        <h2 style="margin-top:0">جاهز للإطلاق؟</h2>
        <p style="color:var(--muted); margin:0 0 18px">وسّع البيئة بإضافة Agent ثانٍ للتحقق من CDC أو اربطها مع بيئة UVM كاملة.</p>
        <a class="btn primary" href="#getting-started">ابدأ الآن</a>
      </div>
    </div>
  </section>
</main>

<footer>
  <div class="container">
    <p>ترخيص MIT — يمكنك الاستخدام والتعديل بحرية.</p>
    <p style="font-size:12px; opacity:.7">صُمم بواجهة عربية RTL مع أنيميشن سحري وتأثيرات زجاجية.</p>
  </div>
</footer>

<script>
/* Starfield */
(function(){
  const canvas = document.getElementById('starfield');
  const ctx = canvas.getContext('2d');
  let w,h,stars;
  function resize(){
    w = canvas.width = window.innerWidth;
    h = canvas.height = window.innerHeight;
    stars = Array.from({length: Math.min(250, Math.floor(w*h/8000))}, ()=>({
      x: Math.random()*w,
      y: Math.random()*h,
      r: Math.random()*1.3+0.2,
      a: Math.random()*0.6+0.2,
      v: Math.random()*0.15+0.02
    }));
  }
  resize();
  window.addEventListener('resize', resize);
  function tick(){
    ctx.clearRect(0,0,w,h);
    for(const s of stars){
      s.y += s.v;
      if(s.y>h) s.y=0;
      ctx.beginPath();
      ctx.arc(s.x,s.y,s.r,0,Math.PI*2);
      ctx.fillStyle=`rgba(200,230,255,${s.a})`;
      ctx.fill();
    }
    requestAnimationFrame(tick);
  }
  tick();
})();

/* Cursor glow */
(function(){
  const glow = document.getElementById('cursor-glow');
  let mx=-9999, my=-9999, gx=mx, gy=my;
  window.addEventListener('mousemove', e=>{mx=e.clientX; my=e.clientY;});
  function loop(){
    gx += (mx-gx)*0.12;
    gy += (my-gy)*0.12;
    glow.style.transform = `translate(${gx}px,${gy}px) translate(-50%,-50%)`;
    requestAnimationFrame(loop);
  }
  loop();
})();

/* Reveal on scroll */
(function(){
  const obs = new IntersectionObserver(entries=>{
    entries.forEach(e=>{
      if(e.isIntersecting){
        e.target.classList.add('visible');
        obs.unobserve(e.target);
      }
    });
  },{threshold:0.15});
  document.querySelectorAll('.reveal').forEach(el=>obs.observe(el));
})();

/* Tilt cards */
(function(){
  const cards = document.querySelectorAll('.tilt');
  cards.forEach(card=>{
    card.addEventListener('mousemove', e=>{
      const r = card.getBoundingClientRect();
      const x = e.clientX - r.left;
      const y = e.clientY - r.top;
      const rx = ((y/r.height)-0.5)* -8;
      const ry = ((x/r.width)-0.5)* 8;
      card.style.transform = `perspective(900px) rotateX(${rx}deg) rotateY(${ry}deg) translateZ(0)`;
    });
    card.addEventListener('mouseleave', ()=>{card.style.transform='perspective(900px) rotateX(0) rotateY(0)';});
  });
})();

/* Copy buttons */
document.querySelectorAll('.copy-btn').forEach(btn=>{
  btn.addEventListener('click', ()=>{
    const code = btn.nextElementSibling.innerText;
    navigator.clipboard.writeText(code).then(()=>{
      btn.textContent='تم النسخ ✓';
      setTimeout(()=>btn.textContent='نسخ',1500);
    });
  });
});

/* Theme toggle */
const toggle = document.getElementById('themeToggle');
toggle.addEventListener('click', ()=>{
  document.body.classList.toggle('light');
});
</script>
</body>
</html>
