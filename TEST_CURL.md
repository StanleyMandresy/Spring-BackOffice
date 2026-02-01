# 🧪 Tests API d'Authentification avec cURL

## 📋 Prérequis
- Serveur démarré sur `http://localhost:8080`
- Application déployée sous `/sprint0`
- Base de données PostgreSQL configurée

---

## 🔐 Tests d'Authentification

### 1. **Vérifier le statut d'authentification**
```bash
curl "http://localhost:8080/sprint0/api/auth/check"
```
**Réponse attendue:**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "authenticated": false
  }
}
```

---

### 2. **Connexion (Login)**
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt \
     -v
```
**Réponse attendue (succès):**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "role": "USER",
    "message": "Connexion réussie"
  }
}
```

**Réponse attendue (échec):**
```json
{
  "status": "error",
  "code": 401,
  "data": {
    "error": "Identifiants incorrects"
  }
}
```

**Note:** L'option `-c cookies.txt` sauvegarde les cookies (session) dans un fichier.

---

### 3. **Récupérer le profil utilisateur connecté**
```bash
curl "http://localhost:8080/sprint0/api/auth/me" \
     -b cookies.txt
```
**Réponse attendue:**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "role": "USER",
    "authenticated": true
  }
}
```

**Si non authentifié:**
```json
{
  "status": "error",
  "code": 403,
  "data": {
    "error": "Accès non autorisé. Authentification requise."
  }
}
```

---

### 4. **Vérifier l'authentification (avec session)**
```bash
curl "http://localhost:8080/sprint0/api/auth/check" \
     -b cookies.txt
```
**Réponse attendue:**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "authenticated": true,
    "username": "admin",
    "userId": 1,
    "role": "USER"
  }
}
```

---

### 5. **Inscription (Register)**
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/register" \
     -d "username=newuser&password=newpass123"
```
**Réponse attendue (succès):**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "username": "newuser",
    "message": "Inscription réussie"
  }
}
```

**Réponse attendue (utilisateur existe):**
```json
{
  "status": "error",
  "code": 409,
  "data": {
    "error": "Ce nom d'utilisateur existe déjà"
  }
}
```

---

### 6. **Déconnexion (Logout)**
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/logout" \
     -b cookies.txt
```
**Réponse attendue:**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "message": "Déconnexion réussie",
    "username": "admin"
  }
}
```

---

## 🎯 Scénario de Test Complet

### Test du flux complet d'authentification:
```bash
# 1. Vérifier que personne n'est connecté
curl "http://localhost:8080/sprint0/api/auth/check"

# 2. Se connecter et sauvegarder la session
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt

# 3. Vérifier le profil
curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt

# 4. Vérifier l'authentification
curl "http://localhost:8080/sprint0/api/auth/check" -b cookies.txt

# 5. Se déconnecter
curl -X POST "http://localhost:8080/sprint0/api/auth/logout" -b cookies.txt

# 6. Vérifier que la session est terminée
curl "http://localhost:8080/sprint0/api/auth/check" -b cookies.txt
```

---

## 🛠️ Options cURL Utiles

| Option | Description |
|--------|-------------|
| `-X POST` | Spécifie la méthode HTTP POST |
| `-d "key=value"` | Envoie des données en POST (form-encoded) |
| `-c cookies.txt` | Sauvegarde les cookies dans un fichier |
| `-b cookies.txt` | Envoie les cookies depuis un fichier |
| `-v` | Mode verbose (affiche les headers) |
| `-H "Header: value"` | Ajoute un header personnalisé |
| `-i` | Affiche les headers de réponse |

---

## 📊 Format de Réponse Standard

Toutes les réponses suivent le format **JsonResponse**:

```json
{
  "status": "success" | "error",
  "code": 200 | 401 | 403 | 404 | 500,
  "data": { ... }
}
```

### Codes de statut HTTP:
- **200** - Succès
- **401** - Non autorisé (identifiants incorrects)
- **403** - Accès interdit (pas de session)
- **409** - Conflit (utilisateur existe déjà)
- **500** - Erreur serveur

---

## 💡 Conseils

1. **Toujours utiliser `-c cookies.txt` lors du login** pour sauvegarder la session
2. **Utiliser `-b cookies.txt`** pour les requêtes nécessitant une authentification
3. **Ajouter `-v` ou `-i`** pour debugger les problèmes de headers/cookies
4. **Sur Windows**, utiliser `curl.exe` si vous avez des problèmes avec les guillemets

### Exemple avec headers visibles:
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt \
     -i
```

---

## 🐛 Dépannage

### Problème: "Accès non autorisé"
- Vérifiez que vous utilisez `-b cookies.txt`
- Vérifiez que le fichier cookies.txt existe et contient JSESSIONID

### Problème: "Base de données non disponible"
- Vérifiez que PostgreSQL est démarré
- Vérifiez les credentials dans `application.properties`
- Vérifiez que la table `users` existe

### Problème: 404 Not Found
- Vérifiez que l'URL contient le bon contexte (`/sprint0`)
- Vérifiez que le serveur Tomcat est démarré
