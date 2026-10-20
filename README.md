# Agent de résumé de mails (Gmail / Outlook)

Un petit agent IA en Python qui lit les **nouveaux mails** de ta boîte de réception et t'affiche une liste avec un **résumé de chacun**.

```
5 mail(s) (source : gmail, IA : gemini)

=== À lire (personnes, travail, démarches) : 1 ===
- [19/10 09:40] Marie Dupont : Réunion déplacée
  → URGENT : La réunion de jeudi est avancée à 9h, elle demande confirmation avant ce soir.

=== Notifications et comptes (banque, livraisons, factures, sécurité) : 2 ===
- [19/10 08:12] Banque Exemple : Votre relevé est disponible
  → Ton relevé d'octobre est disponible en ligne, aucune action requise.
- [19/10 07:55] Transporteur : Votre colis arrive demain
  → Livraison prévue demain entre 9h et 13h.

=== Publicités et promotions : 2 ===
- [19/10 06:30] Boutique Exemple : -30 % sur tout le site
- [18/10 22:10] Voyages Exemple : Vos vacances d'été à prix réduit
```

## Comment ça marche

1. Connexion à ta boîte Gmail en IMAP, **en lecture seule** : l'agent ne marque rien comme lu, n'envoie et ne supprime rien.
2. Récupération des mails reçus depuis la dernière exécution.
3. Classement de chaque mail (à lire, notifications, newsletters, publicités) et résumé, avec le fournisseur d'IA de ton choix, en un seul appel par mail.
4. Affichage de la liste, puis mémorisation du dernier mail traité.

Le contenu des mails est traité comme du texte à résumer, jamais comme des instructions.

**Tu as une adresse Outlook / Hotmail ?** Les connexions par mot de passe sont désactivées chez Microsoft : le plus simple est de transférer tes mails vers Gmail (voir ci-dessous). Une lecture directe d'Outlook existe aussi (`MAIL_SOURCE=outlook`), mais elle demande une application Azure.

## Le tri des mails

L'agent range chaque mail dans l'une de ces catégories, affichées dans cet ordre :

| Catégorie | Contenu |
|---|---|
| À lire | Messages de vraies personnes, travail, démarches, rendez-vous |
| Notifications et comptes | Banque, livraisons, factures, confirmations, alertes de sécurité |
| Newsletters et réseaux sociaux | Lettres d'information, réseaux sociaux, mises à jour de service |
| Publicités et promotions | Promotions, soldes, démarchage (seuls l'expéditeur et l'objet sont affichés) |

- Le tri s'appuie sur l'IA, aidée par l'en-tête de désinscription que contiennent les envois en masse. Il ne coûte aucun appel supplémentaire.
- **En cas de doute, le mail reste dans "À lire"** : mieux vaut lire une pub que rater un mail utile.
- L'agent trie uniquement dans la liste affichée : il ne déplace, n'archive et ne supprime rien dans ta boîte mail.
- Les catégories et la consigne de l'IA se règlent dans `CATEGORIES` et `SYSTEM_PROMPT`, en haut de `agent_mails.py`.

## 1. Préparer Gmail

### Transférer Outlook vers Gmail (si tu utilises Outlook / Hotmail)

Dans Outlook.com, ouvre les paramètres du courrier, section *Transfert*, et active le transfert vers ton adresse Gmail. Dans Gmail, crée un filtre sur ton adresse Outlook avec l'option **Ne jamais envoyer dans les spams**, pour que les mails transférés arrivent bien dans la boîte de réception. Seuls les mails arrivés après l'activation du transfert sont concernés.

### Créer un mot de passe d'application

1. Active la **validation en deux étapes** sur ton compte Google (obligatoire).
2. Va sur [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords), crée un mot de passe pour "agent mails" et copie les 16 caractères.
3. Vérifie que l'accès IMAP est activé dans les paramètres Gmail (*Transfert et POP/IMAP*).

## 2. Choisir le fournisseur d'IA

| `LLM_PROVIDER` | Coût | Confidentialité | À savoir |
|---|---|---|---|
| `gemini` (défaut) | Gratuit (palier gratuit de Google AI Studio) | Google indique que les requêtes du palier gratuit peuvent servir à améliorer ses produits | Débit limité : l'agent espace les appels |
| `ollama` | Gratuit | Tout reste sur ta machine | Qualité et vitesse selon la puissance de ton PC |
| `anthropic` | Payant (quelques centimes par jour) | Selon les conditions d'Anthropic | Nécessite `pip install anthropic` |

### Obtenir une clé Gemini gratuite

1. Va sur [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) et connecte-toi avec un compte Google.
2. Clique sur **Create API key** et copie la clé.
3. Colle-la dans `.env` : `GEMINI_API_KEY=...`

### Utiliser Ollama (local)

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2
```
Puis dans `.env` : `LLM_PROVIDER=ollama`.

## 3. Installation

```bash
git clone https://github.com/<ton-compte>/agent-mails-outlook.git
cd agent-mails-outlook
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env     # puis remplis GMAIL_ADDRESS, GMAIL_APP_PASSWORD et GEMINI_API_KEY
```

## 4. Utilisation

```bash
python agent_mails.py          # nouveaux mails depuis la dernière exécution
python agent_mails.py --all    # les 15 derniers mails, sans tenir compte de l'historique
```

### Lancement automatique au démarrage (Ubuntu)

1. Teste d'abord à la main : `python agent_mails.py --all`.
2. Installe le lancement automatique :
   ```bash
   chmod +x run_agent.sh install_autostart.sh
   ./install_autostart.sh
   ```
3. Teste sans redémarrer : `./run_agent.sh`. Puis ferme ta session et rouvre-la.

À chaque ouverture de session, l'agent attend que le réseau soit disponible, ajoute la liste des nouveaux mails à `resume.txt`, affiche une notification et ouvre le fichier.

Pour désinstaller : `rm ~/.config/autostart/agent-mails.desktop`.

## Configuration

| Variable | Obligatoire | Description |
|---|---|---|
| `MAIL_SOURCE` | non | `gmail` (défaut) ou `outlook` |
| `GMAIL_ADDRESS` | si Gmail | Ton adresse Gmail |
| `GMAIL_APP_PASSWORD` | si Gmail | Mot de passe d'application Google |
| `AZURE_CLIENT_ID` | si Outlook | ID de l'application Azure (`pip install msal`) |
| `LLM_PROVIDER` | non | `gemini` (défaut), `ollama` ou `anthropic` |
| `GEMINI_API_KEY` | si Gemini | Clé Google AI Studio |
| `ANTHROPIC_API_KEY` | si Anthropic | Clé API Anthropic |
| `OLLAMA_HOST` | non | Adresse d'Ollama (défaut : `http://localhost:11434`) |
| `LLM_MODEL` | non | Remplace le modèle par défaut du fournisseur |
| `LLM_DELAY` | non | Pause entre deux résumés, en secondes (défaut : 6 pour Gemini, 0 sinon) |

## Option : lire Outlook directement (avancé)

Il faut inscrire une application dans Microsoft Entra ID (type de compte "Comptes Microsoft personnels uniquement", flux clients publics activés, permission Graph déléguée `Mail.Read`), puis `pip install msal`, `MAIL_SOURCE=outlook` et `AZURE_CLIENT_ID` dans `.env`. Au premier lancement, un code s'affiche à saisir sur [microsoft.com/devicelogin](https://microsoft.com/devicelogin).

## Confidentialité et sécurité

- Avec Gemini ou Anthropic, le texte des mails (4000 premiers caractères de chacun) est envoyé au fournisseur pour être résumé. Avec Ollama, rien ne quitte ta machine.
- La date du dernier mail traité est stockée dans `~/.agent_mails/` sur ta machine.
- Ne commit jamais ton fichier `.env` (il est déjà dans le `.gitignore`) : il contient ton mot de passe d'application. Tu peux le révoquer à tout moment dans ton compte Google.

## Dépannage

- **`GMAIL_ADDRESS ou GMAIL_APP_PASSWORD manquant`** : le fichier `.env` est absent ou mal rempli.
- **`Connexion Gmail refusée`** : utilise le mot de passe d'application (pas ton mot de passe Gmail), vérifie la validation en deux étapes et l'activation d'IMAP.
- **Les mails d'Outlook n'apparaissent pas** : vérifie le transfert et le filtre "Ne jamais envoyer dans les spams" dans Gmail.
- **`résumé indisponible` avec une erreur 429** : limite de requêtes atteinte, augmente `LLM_DELAY`.
- **Aucun nouveau mail** : normal si rien n'est arrivé depuis la dernière exécution. Essaie `--all`.
- **Repartir de zéro** : supprime le dossier `~/.agent_mails/`.

## Licence

MIT, voir [LICENSE](LICENSE).
