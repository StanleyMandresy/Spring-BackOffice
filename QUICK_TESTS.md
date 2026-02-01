# 🧪 Exemples de Tests Rapides

## 🚀 Test Immédiat (copier-coller)

### 1️⃣ Test de connexion simple
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass"
```

**Résultat attendu:**
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

---

### 2️⃣ Test avec session complète
```bash
# Connexion + sauvegarde session
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt

# Vérifier le profil
curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt
```

**Résultat profil:**
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

---

### 3️⃣ Test inscription
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/register" \
     -d "username=testuser&password=test123"
```

**Résultat:**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "username": "testuser",
    "message": "Inscription réussie"
  }
}
```

---

## 🔄 Flux Complet en Une Commande

```bash
# Test du cycle complet
echo "1. Vérification initiale..." && \
curl -s "http://localhost:8080/sprint0/api/auth/check" && \
echo -e "\n\n2. Connexion..." && \
curl -s -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt && \
echo -e "\n\n3. Profil..." && \
curl -s "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt && \
echo -e "\n\n4. Déconnexion..." && \
curl -s -X POST "http://localhost:8080/sprint0/api/auth/logout" -b cookies.txt && \
echo -e "\n\n✅ Tests terminés !" && \
rm -f cookies.txt
```

---

## 🎯 Tests avec jq (JSON Pretty Print)

Si vous avez `jq` installé (`brew install jq`):

```bash
# Test avec formatage JSON
curl -s -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" | jq .

# Extraire uniquement le username
curl -s "http://localhost:8080/sprint0/api/auth/me" \
     -b cookies.txt | jq -r '.data.username'
```

---

## ⚡ One-Liners Utiles

### Vérifier si connecté
```bash
curl -s "http://localhost:8080/sprint0/api/auth/check" | grep -o '"authenticated":[^,]*'
```

### Login + Extract Session ID
```bash
curl -s -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt -D - | grep -i "Set-Cookie:"
```

### Compter les utilisateurs (via ancien endpoint)
```bash
curl -s "http://localhost:8080/sprint0/auth/users" | grep -c "User{"
```

---

## 🐛 Debug Mode (Verbose)

### Voir les headers complets
```bash
curl -v -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt
```

### Voir uniquement les headers de réponse
```bash
curl -I "http://localhost:8080/sprint0/api/auth/check"
```

---

## 📊 Mesurer le Temps de Réponse

```bash
curl -w "\n⏱️ Temps: %{time_total}s\n" \
     -o /dev/null -s \
     "http://localhost:8080/sprint0/api/auth/check"
```

---

## 🔐 Tests d'Erreurs

### Login invalide
```bash
curl -s -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=wrong"
```
**Résultat:** `{"status":"error","code":401,"data":{"error":"Identifiants incorrects"}}`

### Accès protégé sans session
```bash
curl -s "http://localhost:8080/sprint0/api/auth/me"
```
**Résultat:** `{"status":"error","code":403,"data":{"error":"Accès non autorisé"}}`

### Inscription doublon
```bash
curl -s -X POST "http://localhost:8080/sprint0/api/auth/register" \
     -d "username=admin&password=anypass"
```
**Résultat:** `{"status":"error","code":409,"data":{"error":"Ce nom d'utilisateur existe déjà"}}`

---

## 🎨 Avec Coloration (macOS/Linux)

```bash
# Installer grc si nécessaire: brew install grc
curl -s "http://localhost:8080/sprint0/api/auth/check" | python3 -m json.tool
```

---

## 📱 Tests Depuis un Autre Ordinateur

Remplacer `localhost` par l'IP de votre machine:

```bash
# Trouver votre IP
ipconfig getifaddr en0  # macOS WiFi
# ou
hostname -I  # Linux

# Tester depuis une autre machine
curl "http://192.168.1.X:8080/sprint0/api/auth/check"
```

---

## 🔄 Script de Test en Boucle

Test de charge simple:

```bash
for i in {1..10}; do
  echo "Test #$i"
  curl -s "http://localhost:8080/sprint0/api/auth/check" | grep -o '"authenticated":[^,]*'
done
```

---

## 💾 Sauvegarder les Réponses

```bash
# Sauvegarder toutes les réponses
mkdir -p test_results

curl -s "http://localhost:8080/sprint0/api/auth/check" \
     > test_results/check.json

curl -s -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c test_results/cookies.txt \
     > test_results/login.json

curl -s "http://localhost:8080/sprint0/api/auth/me" \
     -b test_results/cookies.txt \
     > test_results/profile.json
```

---

## ✅ Validation Rapide

```bash
# Vérifier que l'API est up
curl -f -s "http://localhost:8080/sprint0/api/auth/check" > /dev/null && \
  echo "✅ API en ligne" || \
  echo "❌ API hors ligne"
```

---

## 🎓 Pour les Débutants

### Commande minimale
```bash
curl "http://localhost:8080/sprint0/api/auth/check"
```

### Avec méthode POST
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass"
```

### Avec cookies (2 étapes)
```bash
# 1. Login
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt

# 2. Utiliser la session
curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt
```

---

## 🏆 Challenge

Créez un script qui:
1. ✅ Se connecte
2. ✅ Vérifie le profil
3. ✅ Crée 5 nouveaux utilisateurs
4. ✅ Se déconnecte
5. ✅ Affiche un rapport

**Indice:** Utilisez une boucle `for` et des variables !

---

**💡 Astuce:** Ajoutez ces commandes à votre `.bash_aliases` pour un accès rapide !
