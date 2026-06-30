# Journal de bord — Déploiement MANUEL (sans Terraform)

> Projet LEEX — Comparaison des performances de déploiement d'un serveur **avec Terraform** vs **à la main avec Docker**.
> Objectif de ce document : noter **toutes les étapes**, le **temps** passé, et les **erreurs** rencontrées.

- **Date :** 2026-06-30
- **Machine :** Windows 11
- **Outil :** Docker Desktop (Docker v29.4.3, Compose v5.1.3)
- **Serveur déployé :** Nginx (serveur web statique)
- **Méthode finale :** image custom construite via **Dockerfile multi-stage** (`leex-nginx:2.0`)
- **Frontend :** application **Vue 3 + Vite** (bouton compteur + lecteur vidéo placeholder) buildée puis servie par Nginx

---

## ⏱️ Chrono global

| Évènement | Heure |
|---|---|
| Début (T0) | `09:33:48` |
| Fin (serveur accessible avec bon contenu) | `09:34:xx` |
| **Durée totale manuelle** | `~2-3 min (dont 1 erreur de volume à corriger)` |

> Note : le pull + run "techniques" prennent ~5s, mais le temps réel inclut le démarrage de Docker Desktop (~30-60s),
> la correction de l'erreur de montage, et les vérifications. C'est ÇA qu'on compare à Terraform.

---

## 📋 Étapes réalisées

| # | Étape | Commande / Action | Temps | Résultat / Erreur |
|---|---|---|---|---|
| 0 | Démarrer Docker Desktop | (manuel, attendre l'icône verte) | ~30-60s | ✅ daemon prêt |
| 1 | Vérifier que Docker répond | `docker ps` | ~1s | ✅ OK |
| 2 | Récupérer l'image Nginx | `docker pull nginx:alpine` | 4s | ✅ image téléchargée |
| 3 | Créer le contenu web | fichier `site/index.html` | ~1min | ✅ |
| 4 | Lancer le conteneur (1er essai) | `docker run -d -p 8080:80 -v ...` | 1s | ❌ servait la page par défaut (volume mal monté) |
| 5 | Diagnostic | `docker inspect` / `docker exec ls` | ~2min | 🔎 chemins mangés par Git Bash |
| 6 | Relancer via PowerShell (chemin Windows) | `docker run ... -v "C:\...:..."` | 0.4s | ✅ index.html bien monté |
| 7 | Tester | `curl http://localhost:8080` | <1s | ✅ HTTP 200, bon contenu |
| 8 | **Écrire un Dockerfile** (image custom) | fichier `Dockerfile` | ~1min | ✅ contenu intégré à l'image |
| 9 | **Build de l'image** | `docker build -t leex-nginx:1.0 .` | 1.8s | ✅ image `leex-nginx:1.0` |
| 10 | Run depuis notre image (sans volume) | `docker run -d --name leex-nginx -p 8080:80 leex-nginx:1.0` | <1s | ✅ HTTP 200 — plus de souci de chemin |
| 11 | (option) Arrêter / nettoyer | `docker rm -f leex-nginx` | <1s | — |

---

## 💥 Erreurs rencontrées

| Erreur (message) | Cause | Solution appliquée | Temps perdu |
|---|---|---|---|
| `failed to connect to the docker API ... daemon running?` | Docker Desktop pas démarré | Lancer Docker Desktop et attendre l'icône verte | ~40s |
| Nginx servait la page par défaut "Welcome to nginx!" au lieu de mon `index.html` | Sous **Git Bash (Windows)**, les chemins du `-v` sont automatiquement mal convertis : `/usr/share/nginx/html` est devenu `C:/Program Files/Git/usr/share/nginx/html` et la source a reçu un `;C` parasite | Relancer la commande **via PowerShell** avec un chemin Windows natif `C:\...\site` (ou utiliser `MSYS_NO_PATHCONV=1` en bash) | ~2 min |
| Accents bizarres (`Ã©`) dans la console | Encodage console PowerShell, pas le fichier | Aucune action : le fichier est en UTF-8, l'affichage navigateur est correct | 0 |

---

## 🧠 Observations pour la comparaison

- Nombre de commandes tapées à la main : **~6** (pull, run, ps, inspect, exec, curl) + démarrage Docker Desktop
- Étapes manuelles / non automatisées : **toutes** — rien n'est rejouable sans retaper les commandes
- Reproductibilité : **difficile** — si je change de machine ou que je recommence, je dois me souvenir de chaque commande et de l'ordre exact
- Risque d'erreur humaine : **élevé** — démontré par l'erreur de volume (page par défaut au lieu du contenu) qui a coûté ~2 min de debug

> C'est ici que Terraform brillera : 1 fichier `.tf` + `terraform apply` = tout automatisé, versionné et reproductible.
> La même erreur de chemin n'arriverait pas car le chemin est écrit une seule fois dans le code.

---

## ✅ Conclusion manuelle

Le déploiement manuel d'un serveur Nginx fonctionne et est **rapide en pur temps machine** (pull 4s + run <1s),
mais le **temps réel** est gonflé par : le démarrage de Docker Desktop, la saisie manuelle des commandes,
et surtout le **debug des erreurs** (ici, le montage de volume sous Git Bash).

Points faibles du manuel à mettre en avant dans la comparaison :

1. **Non reproductible** sans tout retaper.
2. **Sensible à l'environnement** (Git Bash vs PowerShell → comportement différent).
3. **Aucune trace/versioning** de l'infrastructure (≠ un fichier `.tf` dans Git).
4. **Erreur humaine probable** dès qu'il y a plusieurs paramètres.

➡️ Prochaine étape du projet : refaire EXACTEMENT le même serveur avec Terraform et chronométrer pour comparer.
