<script setup>
import { ref, onMounted } from 'vue'

// Vidéo YouTube : https://youtu.be/1xTrYJh4G8U
const YT_VIDEO_ID = '1xTrYJh4G8U'
let player = null
const playerReady = ref(false)

// Le temps est-il arrêté ? (référence JoJo : Star Platinum « The World »)
const timeStopped = ref(false)

// Volume commun (0 à 1)
const volume = ref(0.7)

// Audios JoJo (dans public/jotaro)
const audioStop = new Audio('/jotaro/star-platinum-za-warudo.mp3')
const audioResume = new Audio('/jotaro/Time_resumes.mp3')
audioStop.volume = volume.value
audioResume.volume = volume.value

// Charge l'API IFrame de YouTube une seule fois
function loadYouTubeAPI() {
  return new Promise((resolve) => {
    if (window.YT && window.YT.Player) {
      resolve()
      return
    }
    const tag = document.createElement('script')
    tag.src = 'https://www.youtube.com/iframe_api'
    window.onYouTubeIframeAPIReady = () => resolve()
    document.head.appendChild(tag)
  })
}

onMounted(async () => {
  await loadYouTubeAPI()
  player = new window.YT.Player('yt-player', {
    videoId: YT_VIDEO_ID,
    playerVars: { rel: 0 },
    events: {
      onReady: (e) => {
        e.target.setVolume(volume.value * 100)
        playerReady.value = true
      },
    },
  })
})

function applyVolume() {
  audioStop.volume = volume.value
  audioResume.volume = volume.value
  if (player && playerReady.value) player.setVolume(volume.value * 100)
}

function playFromStart(audio) {
  audio.currentTime = 0
  audio.play().catch(() => {})
}

function toggleTime() {
  timeStopped.value = !timeStopped.value
  // Le fond de page réagit aussi à l'état
  document.body.classList.toggle('time-stopped', timeStopped.value)

  if (timeStopped.value) {
    // Star Platinum « The World » : on stoppe le temps
    audioResume.pause()
    playFromStart(audioStop)
    if (player && playerReady.value) player.pauseVideo()
  } else {
    // Time resumes...
    audioStop.pause()
    playFromStart(audioResume)
    if (player && playerReady.value) player.playVideo()
  }
}
</script>

<template>
  <main class="card" :class="{ stopped: timeStopped }">
    <header class="head">
      <span class="badge">Docker · Vue 3 · Nginx</span>
      <h1 class="title">LEEX</h1>
      <p class="subtitle">
        Déploiement manuel d'un serveur — comparaison avec / sans Terraform
      </p>
    </header>

    <!-- Bouton à deux états -->
    <div class="btn-zone">
      <span class="aura" :class="{ on: timeStopped }" aria-hidden="true"></span>
      <button
        class="btn"
        :class="{ stopped: timeStopped }"
        @click="toggleTime"
        :aria-pressed="timeStopped"
      >
        {{ timeStopped ? 'Time resumes...' : 'Star Platinum : The World' }}
      </button>
    </div>

    <p class="state">
      <span class="dot" :class="{ on: timeStopped }"></span>
      {{ timeStopped ? 'Le temps est arrêté' : 'Le temps s\'écoule' }}
    </p>

    <!-- Contrôle du volume -->
    <div class="volume">
      <label for="vol" class="vol-icon" aria-label="Volume">🔊</label>
      <input
        id="vol"
        type="range"
        min="0"
        max="1"
        step="0.01"
        v-model.number="volume"
        @input="applyVolume"
        :style="{ '--pct': volume * 100 + '%' }"
      />
      <span class="vol-val">{{ Math.round(volume * 100) }}%</span>
    </div>

    <!-- Vidéo YouTube (API IFrame, pilotée par le bouton et le volume) -->
    <section class="video-zone" :class="{ frozen: timeStopped }">
      <div class="yt-wrapper">
        <div id="yt-player"></div>
      </div>
    </section>
  </main>
</template>

<style scoped>
/* ---------- Carte principale ---------- */
.card {
  width: 100%;
  max-width: 780px;
  padding: 2.5rem 2rem 2rem;
  text-align: center;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.09);
  backdrop-filter: blur(14px);
  box-shadow:
    0 24px 60px rgba(0, 0, 0, 0.55),
    inset 0 1px 0 rgba(255, 255, 255, 0.06);
  transition: border-color 0.5s ease, box-shadow 0.5s ease;
}
.card.stopped {
  border-color: rgba(240, 192, 64, 0.35);
  box-shadow:
    0 24px 70px rgba(0, 0, 0, 0.6),
    0 0 60px rgba(240, 192, 64, 0.12),
    inset 0 1px 0 rgba(255, 255, 255, 0.06);
}

/* ---------- En-tête ---------- */
.badge {
  display: inline-block;
  font-size: 0.72rem;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--muted);
  padding: 0.35rem 0.8rem;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.03);
}
.title {
  margin: 1rem 0 0.4rem;
  font-size: clamp(2.6rem, 8vw, 4.2rem);
  font-weight: 800;
  letter-spacing: 0.16em;
  line-height: 1;
  background: linear-gradient(180deg, #ffffff 10%, var(--purple) 130%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  transition: filter 0.5s ease;
}
.card.stopped .title {
  background: linear-gradient(180deg, #fff6dd 10%, var(--gold) 130%);
  -webkit-background-clip: text;
  background-clip: text;
  filter: drop-shadow(0 0 18px rgba(240, 192, 64, 0.4));
}
.subtitle {
  color: var(--muted);
  font-size: 0.95rem;
  margin: 0 auto 2.2rem;
  max-width: 46ch;
}

/* ---------- Bouton + aura ---------- */
.btn-zone {
  position: relative;
  display: inline-flex;
  justify-content: center;
}
.aura {
  position: absolute;
  inset: -22px;
  border-radius: 999px;
  background: radial-gradient(circle, rgba(168, 85, 247, 0.45), transparent 68%);
  filter: blur(14px);
  opacity: 0.75;
  transition: background 0.5s ease;
  animation: pulse 2.8s ease-in-out infinite;
  pointer-events: none;
}
.aura.on {
  background: radial-gradient(circle, rgba(240, 192, 64, 0.55), transparent 68%);
  animation-duration: 1.4s;
}
@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.09); opacity: 0.95; }
}

.btn {
  position: relative;
  font-size: 1rem;
  font-weight: 700;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  padding: 1rem 2.2rem;
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 999px;
  color: #fff;
  background: linear-gradient(135deg, var(--purple-deep), var(--purple));
  cursor: pointer;
  transition: transform 0.15s ease, box-shadow 0.3s ease, background 0.4s ease;
  box-shadow: 0 8px 26px rgba(109, 40, 217, 0.45);
}
.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 34px rgba(109, 40, 217, 0.6);
}
.btn:active {
  transform: translateY(0) scale(0.98);
}
.btn.stopped {
  background: linear-gradient(135deg, #b8860b, var(--gold-soft));
  color: #1a1405;
  border-color: rgba(255, 255, 255, 0.3);
  box-shadow: 0 10px 34px rgba(240, 192, 64, 0.5);
}
.btn.stopped:hover {
  box-shadow: 0 14px 42px rgba(240, 192, 64, 0.65);
}

/* ---------- Indicateur d'état ---------- */
.state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.55rem;
  margin: 1.6rem 0 0;
  color: var(--muted);
  font-size: 0.86rem;
  letter-spacing: 0.05em;
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #4ade80;
  box-shadow: 0 0 10px #4ade80;
  transition: background 0.4s ease, box-shadow 0.4s ease;
}
.dot.on {
  background: var(--gold);
  box-shadow: 0 0 12px var(--gold);
}

/* ---------- Slider de volume ---------- */
.volume {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.9rem;
  margin-top: 1.6rem;
}
.vol-icon {
  font-size: 1.05rem;
  cursor: pointer;
}
.volume input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 220px;
  height: 6px;
  border-radius: 999px;
  outline: none;
  cursor: pointer;
  background: linear-gradient(
    to right,
    var(--purple) 0%,
    var(--purple) var(--pct, 70%),
    rgba(255, 255, 255, 0.12) var(--pct, 70%),
    rgba(255, 255, 255, 0.12) 100%
  );
  transition: background 0.2s linear;
}
.card.stopped .volume input[type="range"] {
  background: linear-gradient(
    to right,
    var(--gold) 0%,
    var(--gold) var(--pct, 70%),
    rgba(255, 255, 255, 0.12) var(--pct, 70%),
    rgba(255, 255, 255, 0.12) 100%
  );
}
.volume input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 17px;
  height: 17px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid rgba(0, 0, 0, 0.25);
  box-shadow: 0 0 10px rgba(255, 255, 255, 0.55);
  transition: transform 0.15s ease;
}
.volume input[type="range"]::-webkit-slider-thumb:hover {
  transform: scale(1.18);
}
.volume input[type="range"]::-moz-range-thumb {
  width: 15px;
  height: 15px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid rgba(0, 0, 0, 0.25);
  box-shadow: 0 0 10px rgba(255, 255, 255, 0.55);
}
.vol-val {
  min-width: 3.2rem;
  text-align: left;
  color: var(--muted);
  font-size: 0.86rem;
  font-variant-numeric: tabular-nums;
}

/* ---------- Vidéo ---------- */
.video-zone {
  margin-top: 2.4rem;
  transition: filter 0.6s ease, transform 0.6s ease;
}
.video-zone.frozen {
  filter: sepia(0.55) contrast(1.12) brightness(0.82) saturate(1.2);
  transform: scale(0.985);
}
.yt-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: 14px;
  overflow: hidden;
  background: #000;
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 16px 44px rgba(0, 0, 0, 0.6);
}
.yt-wrapper :deep(iframe) {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  border: 0;
}

/* ---------- Accessibilité ---------- */
@media (prefers-reduced-motion: reduce) {
  .aura { animation: none; }
  .btn, .video-zone, .card { transition: none; }
}
</style>
