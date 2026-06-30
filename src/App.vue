<script setup>
import { ref } from 'vue'

const count = ref(0)

// Chemin de la vidéo (placeholder). Dépose ta vidéo dans public/video.mp4
// puis remplace cette valeur si besoin. Liée en :src pour éviter la résolution
// statique de Vite tant que le fichier n'existe pas.
const videoSrc = ref('/video.mp4')

function onClick() {
  count.value++
}
</script>

<template>
  <main class="container">
    <h1>LEEX — Frontend Vue</h1>
    <p class="subtitle">Serveur déployé avec Docker (comparaison avec / sans Terraform)</p>

    <!-- Bouton -->
    <button class="btn" @click="onClick">
      Clique-moi ({{ count }})
    </button>

    <!-- Vidéo : PLACEHOLDER — remplace le fichier public/video.mp4 par ta vraie vidéo -->
    <section class="video-zone">
      <video controls poster="/video-poster.svg" width="640" :src="videoSrc">
        Ton navigateur ne supporte pas la balise vidéo.
      </video>
      <p class="hint">📹 Placeholder vidéo — dépose ta vidéo dans <code>public/video.mp4</code></p>
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
.video-zone {
  margin-top: 2.5rem;
}
.video-zone video {
  max-width: 100%;
  border-radius: 8px;
  background: #000;
}
.hint {
  color: #888;
  font-size: 0.9rem;
  margin-top: 0.75rem;
}
</style>
