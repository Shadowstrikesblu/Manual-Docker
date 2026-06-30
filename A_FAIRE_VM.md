# À FAIRE — Créer une VM (Linux ou Windows) et la rendre accessible sur Internet

> Objectif : héberger le frontend (conteneur Docker `leex-nginx`) sur une **vraie VM dans le cloud**,
> accessible publiquement, **à la main** (pour ensuite comparer avec la version Terraform).
>
> Coche au fur et à mesure et note le **temps** + les **erreurs** dans [JOURNAL.md](JOURNAL.md).

---

## 0. Choisir un fournisseur cloud

- [ ] Choisir un provider : **AWS** (EC2), **Azure** (Virtual Machine), **GCP** (Compute Engine), ou **OVH / Scaleway** (FR).
- [ ] Créer un compte + activer la facturation (souvent un **free tier** : AWS t2.micro, Azure B1s, GCP e2-micro).
- [ ] Noter la **région** choisie (ex : `eu-west-3` Paris).

> 💡 Pour la comparaison Terraform, garde le même provider et la même région que ce que fera le `.tf`.

---

## 1. Créer la VM

### Option A — VM Linux (recommandé, plus simple pour Docker)
- [ ] OS : **Ubuntu Server 22.04 LTS** (ou Debian 12).
- [ ] Taille : 1 vCPU / 1 Go RAM minimum (free tier OK).
- [ ] Générer / téléverser une **paire de clés SSH** (garde le `.pem` / clé privée en sécurité).
- [ ] Lancer l'instance et noter son **IP publique**.

### Option B — VM Windows
- [ ] OS : **Windows Server 2022**.
- [ ] Définir le mot de passe administrateur.
- [ ] Lancer l'instance et noter son **IP publique**.
- [ ] Connexion via **RDP** (Bureau à distance) sur le port 3389.

---

## 2. Ouvrir les ports (rendre accessible sur le net)

Dans le **pare-feu / security group / NSG** du provider :

- [ ] **Port 22** (SSH) — Linux, source = ton IP uniquement (sécurité).
- [ ] **Port 3389** (RDP) — Windows, source = ton IP uniquement.
- [ ] **Port 80** (HTTP) — ouvert à `0.0.0.0/0` (tout le monde) → c'est ce qui rend le site public.
- [ ] **Port 443** (HTTPS) — si tu mets un certificat TLS plus tard.
- [ ] (Le frontend tourne sur le port 80 du conteneur ; on le mappera sur le port 80 de la VM.)

> ⚠️ Erreur fréquente : oublier le port 80 dans le security group → le site est injoignable même si Docker tourne.

---

## 3. Se connecter à la VM

### Linux (depuis ta machine Windows)
```powershell
ssh -i "C:\chemin\vers\ta-cle.pem" ubuntu@IP_PUBLIQUE
```
### Windows
- [ ] Ouvrir **Connexion Bureau à distance** (`mstsc`), saisir l'IP publique + identifiants.

---

## 4. Installer Docker sur la VM

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # puis se reconnecter
docker --version
```
### Windows Server
- [ ] Installer **Docker Desktop** ou activer le rôle conteneurs + Docker Engine.

---

## 5. Déployer le frontend sur la VM

Deux possibilités :

### Via le code source (build sur la VM)
- [ ] Copier le projet sur la VM (`git clone` du dépôt, ou `scp` du dossier `manuel-docker`).
```bash
scp -i ta-cle.pem -r ./manuel-docker ubuntu@IP_PUBLIQUE:~/leex
```
- [ ] Sur la VM :
```bash
cd ~/leex
docker compose up -d --build
```

### Via une image déjà publiée (plus rapide)
- [ ] Sur ta machine : `docker tag leex-nginx:2.0 TONUSER/leex-nginx:2.0 && docker push TONUSER/leex-nginx:2.0`
- [ ] Sur la VM : `docker run -d -p 80:80 TONUSER/leex-nginx:2.0`

> ⚠️ Sur la VM, mapper sur le **port 80** (`-p 80:80`), pas 8080, pour un accès direct sans `:port` dans l'URL.

---

## 6. Vérifier l'accès public

- [ ] Depuis ta machine (ou ton téléphone en 4G) : ouvrir `http://IP_PUBLIQUE`
- [ ] Vérifier que le frontend Vue s'affiche (bouton + vidéo).
- [ ] Tester depuis un autre réseau pour confirmer que c'est bien **public**.

---

## 7. (Optionnel) Nom de domaine + HTTPS

- [ ] Acheter / utiliser un **nom de domaine** et pointer un enregistrement **A** vers l'IP publique.
- [ ] Installer un reverse proxy (Nginx/Caddy/Traefik) + **certificat Let's Encrypt** pour le HTTPS.

---

## 8. Mesures pour la comparaison (à reporter dans JOURNAL.md)

- [ ] **Temps total** de création + déploiement manuel de la VM : `____`
- [ ] **Nombre de clics/commandes** dans la console du provider : `____`
- [ ] **Erreurs rencontrées** (port oublié, clé SSH, droits Docker...) : `____`
- [ ] **Reproductibilité** : pourrais-tu refaire à l'identique sans te tromper ? `____`

> ➡️ Ces mêmes étapes seront ensuite automatisées par Terraform (`terraform apply`) pour comparer
> le temps, le nombre d'actions manuelles et le risque d'erreur.
