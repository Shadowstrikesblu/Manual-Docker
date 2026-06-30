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
  <main class="container">
    <h1>LEEX — Frontend Vue</h1>
    <p class="subtitle">Serveur déployé avec Docker (comparaison avec / sans Terraform)</p>

    <!-- Bouton à deux états -->
    <button class="btn" :class="{ stopped: timeStopped }" @click="toggleTime">
      {{ timeStopped ? 'Time resumes...' : 'Star Platinum : The World' }}
    </button>

    <!-- Contrôle du volume -->
    <div class="volume">
      <label for="vol">🔊 Volume</label>
      <input
        id="vol"
        type="range"
        min="0"
        max="1"
        step="0.01"
        v-model.number="volume"
        @input="applyVolume"
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
.container {
  max-width: 720px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}
.subtitle {
  color: #666;
  margin-bottom: 2rem;
}
.btn {
  font-size: 1.1rem;
  padding: 0.8rem 1.6rem;
  border: none;
  border-radius: 8px;
  background: #42b883;
  color: white;
  cursor: pointer;
  transition: background 0.2s;
}
.btn:hover {
  background: #369870;
}
.btn.stopped {
  background: #d4af37;
  color: #1a1a1a;
  box-shadow: 0 0 16px rgba(212, 175, 55, 0.7);
}
.btn.stopped:hover {
  background: #c39f2f;
}
.volume {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  margin-top: 1.5rem;
}
.volume input[type="range"] {
  width: 200px;
  accent-color: #42b883;
  cursor: pointer;
}
.vol-val {
  min-width: 3rem;
  text-align: left;
  color: #666;
  font-variant-numeric: tabular-nums;
}
.video-zone {
  margin-top: 2.5rem;
  transition: filter 0.3s;
}
.video-zone.frozen {
  filter: sepia(0.6) contrast(1.1) brightness(0.9);
}
.yt-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: 8px;
  overflow: hidden;
  background: #000;
}
.yt-wrapper :deep(iframe) {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  border: 0;
}
</style>
