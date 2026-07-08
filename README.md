# LEEX — Déploiement manuel d'un serveur avec Docker

Frontend **Vue 3 + Vite**, conteneurisé et servi par **Nginx**, déployé **entièrement à la main** avec Docker.

Ce dépôt constitue la **branche « sans Terraform »** d'un projet de comparaison :
> *Comparer les performances du déploiement d'un serveur avec Terraform et sans Terraform.*

Le déploiement manuel (étapes, temps, erreurs) est consigné dans [JOURNAL.md](JOURNAL.md), qui sert de base à la comparaison chiffrée.

---

## 🚀 Démarrage rapide

### Prérequis
- **Docker Desktop** installé **et démarré** (sinon : `failed to connect to the docker API`)
- **Node.js 20+** et **npm** (uniquement pour le mode développement)

### Lancer l'application (Docker — mode production)
```bash
docker compose up -d --build
```
➡️ Application disponible sur **http://localhost**

### Lancer en mode développement (hot-reload)
```bash
npm install
npm run dev
```
➡️ Application disponible sur **http://localhost:5173**

---

## 🎬 Fonctionnalités

L'interface est un hommage à *JoJo's Bizarre Adventure* (Star Platinum « The World »).

| Élément | Comportement |
|---|---|
| **Bouton (état 1)** | `Star Platinum : The World` — **arrête le temps** : joue l'audio `star-platinum-za-warudo.mp3`, met la vidéo YouTube en **pause**, applique un filtre sépia « figé » |
| **Bouton (état 2)** | `Time resumes...` — **relance le temps** : joue l'audio `Time_resumes.mp3`, **reprend** la lecture de la vidéo, retire le filtre |
| **Slider de volume** | Contrôle simultanément le volume des **deux audios** et celui du **lecteur YouTube** (0 → 100 %) |
| **Lecteur vidéo** | Vidéo YouTube intégrée via l'**API IFrame**, ratio 16:9 responsive |

### Notes de fonctionnement
- Le lecteur YouTube **nécessite une connexion Internet** (le navigateur charge `youtube.com/iframe_api`).
- Au premier chargement, une **interaction utilisateur** est requise avant que le son puisse être joué (politique d'autoplay des navigateurs).

---

## 📁 Structure du projet

```
manuel-docker/
├── src/
│   ├── App.vue           # Composant principal : bouton 2 états, audios, slider, lecteur YouTube
│   ├── main.js           # Point d'entrée Vue
│   └── style.css         # Styles globaux
├── public/
│   ├── jotaro/
│   │   ├── star-platinum-za-warudo.mp3   # Audio « arrêt du temps »
│   │   └── Time_resumes.mp3              # Audio « reprise du temps »
│   ├── video-poster.svg  # (non utilisé depuis le passage à YouTube)
│   └── vite.svg          # Favicon
├── index.html            # Point d'entrée HTML (Vite)
├── vite.config.js        # Configuration Vite + plugin Vue
├── package.json          # Dépendances et scripts npm
├── Dockerfile            # Build multi-stage (Node → Nginx)
├── .dockerignore         # Exclusions du contexte de build
├── docker-compose.yml    # Orchestration du service frontend
├── JOURNAL.md            # 📓 Journal de bord : étapes, temps, erreurs
├── A_FAIRE_VM.md         # ✅ Checklist : déployer sur une VM accessible sur Internet
└── README.md             # Ce fichier
```

---

## 🐳 Architecture Docker

Le [Dockerfile](Dockerfile) utilise un **build multi-stage** pour produire une image finale légère (l'environnement Node n'est pas embarqué dans l'image de production) :

| Étape | Image de base | Rôle |
|---|---|---|
| **1 — build** | `node:20-alpine` | `npm ci` puis `npm run build` → génère `dist/` |
| **2 — serve** | `nginx:alpine` | Copie `dist/` dans `/usr/share/nginx/html`, expose le port **80** |

Un **`HEALTHCHECK`** interroge `http://localhost/` toutes les 30 s pour vérifier que Nginx répond.

> ℹ️ Le conteneur affiche `health: starting` pendant ~30 s avant de passer à `healthy` : c'est le délai du premier test (`--interval=30s`). Ajouter `--start-period=5s` accélérerait ce passage.

Le [docker-compose.yml](docker-compose.yml) construit l'image (`leex-nginx:3.0`), publie le port **80 → 80** et applique `restart: unless-stopped`.

---

## 🛠️ Commandes utiles

### Docker
```bash
docker compose up -d --build   # construire l'image + démarrer le conteneur
docker compose ps              # état du conteneur + statut du healthcheck
docker compose logs -f         # suivre les logs en direct
docker compose down            # arrêter et supprimer le conteneur
```

### Développement
```bash
npm install        # installer les dépendances
npm run dev        # serveur de dev avec hot-reload
npm run build      # build de production → dist/
npm run preview    # prévisualiser le build de production
```

---

## 🔧 Personnalisation

### Changer la vidéo
Modifier la constante en haut de [src/App.vue](src/App.vue) avec l'identifiant de la vidéo YouTube :
```js
const YT_VIDEO_ID = '1xTrYJh4G8U'
```

### Changer les audios
Remplacer les fichiers dans `public/jotaro/`, puis ajuster les chemins dans [src/App.vue](src/App.vue) :
```js
const audioStop = new Audio('/jotaro/star-platinum-za-warudo.mp3')
const audioResume = new Audio('/jotaro/Time_resumes.mp3')
```

### Changer le port
Modifier le mapping dans [docker-compose.yml](docker-compose.yml) (`hôte:conteneur`) :
```yaml
ports:
  - "8080:80"   # l'application serait alors sur http://localhost:8080
```

---

## 📊 Contexte : la comparaison Terraform / manuel

### Mesures relevées (déploiement local)

| Opération | Temps |
|---|---|
| Démarrage de Docker Desktop | ~15–60 s |
| `docker pull nginx:alpine` | ~4 s |
| Build de l'image multi-stage | ~13 s |
| `docker compose up -d --build` | ~7 s |
| Passage du healthcheck à `healthy` | ~30 s |

### Limites du déploiement manuel
1. **Non reproductible** — chaque commande doit être retapée à l'identique.
2. **Sensible à l'environnement** — comportements divergents entre Git Bash et PowerShell (voir l'erreur de montage de volume documentée dans [JOURNAL.md](JOURNAL.md)).
3. **Aucun versioning de l'infrastructure** — à l'inverse d'un fichier `.tf` suivi dans Git.
4. **Risque d'erreur humaine élevé** dès que le nombre de paramètres augmente.

➡️ **Étapes suivantes** : suivre [A_FAIRE_VM.md](A_FAIRE_VM.md) pour héberger l'application sur une VM publique, puis reproduire l'ensemble avec Terraform afin de comparer temps, nombre d'actions manuelles et taux d'erreur.

---

## 🧰 Stack technique

- **Vue 3** (Composition API, `<script setup>`)
- **Vite 6** (build et serveur de développement)
- **Nginx Alpine** (serveur web de production)
- **Docker** + **Docker Compose** (conteneurisation)
- **YouTube IFrame API** (lecteur vidéo piloté depuis Vue)
