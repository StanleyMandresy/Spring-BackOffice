# 🔐 API d'Authentification JSON - BackOffice

API REST d'authentification utilisant le framework maison (Sprint 11 bis) avec gestion de session et retour JSON.

---

## 🚀 Démarrage Rapide

### 1. Compiler et déployer
```bash
cd /Users/apple/Documents/L3/S5/NAINA/Back/Spring-BackOffice
./deploy-and-test.sh
```

### 2. Tester l'API
```bash
# Tests automatisés
./test-api.sh

# Ou tests manuels
curl "http://localhost:8080/sprint0/api/auth/check"
```

---

## 📚 Endpoints Disponibles

### 🟢 **Endpoints Publics** (sans authentification)

#### `POST /api/auth/login`
Connexion utilisateur avec création de session.

**Paramètres:**
- `username` (string) - Nom d'utilisateur
- `password` (string) - Mot de passe

**Exemple:**
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt
```

**Réponse (200):**
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

#### `POST /api/auth/register`
Inscription d'un nouvel utilisateur.

**Paramètres:**
- `username` (string) - Nom d'utilisateur (unique)
- `password` (string) - Mot de passe

**Exemple:**
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/register" \
     -d "username=newuser&password=securepass123"
```

**Réponse (200):**
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

**Réponse (409 - Conflit):**
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

#### `GET /api/auth/check`
Vérifier le statut d'authentification (public, mais retourne des infos si connecté).

**Exemple:**
```bash
curl "http://localhost:8080/sprint0/api/auth/check" -b cookies.txt
```

**Réponse (non authentifié):**
```json
{
  "status": "success",
  "code": 200,
  "data": {
    "authenticated": false
  }
}
```

**Réponse (authentifié):**
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

#### `POST /api/auth/logout`
Déconnexion et invalidation de la session.

**Exemple:**
```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/logout" \
     -b cookies.txt
```

**Réponse:**
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

### 🔒 **Endpoints Protégés** (authentification requise)

#### `GET /api/auth/me`
Récupérer le profil de l'utilisateur connecté.

**Note:** Utilise `@AllowAnonymous` avec vérification manuelle de session pour retourner du JSON en cas d'erreur (au lieu de HTML avec `@RequireAuth`)

**Exemple:**
```bash
curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt
```

**Réponse (200):**
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

**Réponse (403 - Non autorisé):**
```json
{
  "status": "error",
  "code": 403,
  "data": {
    "error": "Accès non autorisé"
  }
}
```

---

## 🏗️ Architecture

### Composants Utilisés

**Framework Maison (Sprint 11 bis):**
- `@Controller` - Définir un contrôleur
- `@RestAPI` - Retourner du JSON (via `JsonSerializer`)
- `@PostMapping` / `@GetMapping` - Mapping des routes
- `@RequestParam` - Injection des paramètres
- `@Session` - Injection des valeurs de session
- `@RequireAuth` - Protéger une route (authentification)
- `@AllowAnonymous` - Autoriser l'accès public

**Spring JDBC:**
- `JdbcTemplate` - Requêtes SQL
- `DataSource` - Connexion PostgreSQL

**Classes:**
- [`ApiAuthController.java`](src/main/java/com/spring/BackOffice/controller/ApiAuthController.java) - Contrôleur API
- [`User.java`](src/main/java/com/spring/BackOffice/model/User.java) - Modèle utilisateur
- [`JdbcTemplateProvider.java`](src/main/java/com/spring/BackOffice/config/JdbcTemplateProvider.java) - Provider JDBC

---

## 🗄️ Base de Données

### Table `users`
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Données de test
```sql
INSERT INTO users (username, password, role) VALUES 
('admin', 'adminpass', 'ADMIN'),
('user', 'userpass', 'USER');
```

**⚠️ ATTENTION:** Les mots de passe sont stockés en clair (à des fins de démonstration uniquement).

---

## 📝 Format de Réponse Standard

Toutes les réponses suivent le format `JsonResponse`:

```json
{
  "status": "success" | "error",
  "code": 200 | 401 | 403 | 409 | 500,
  "data": { ... }
}
```

### Codes HTTP
| Code | Signification |
|------|---------------|
| 200 | Succès |
| 401 | Non autorisé (identifiants incorrects) |
| 403 | Accès interdit (pas de session/rôle) |
| 409 | Conflit (ex: utilisateur existe déjà) |
| 500 | Erreur serveur |

---

## 🧪 Tests

### Tests Automatisés
```bash
./test-api.sh
```

Ce script teste:
- ✅ Statut initial (non authentifié)
- ✅ Connexion invalide (401)
- ✅ Connexion valide (200)
- ✅ Vérification de session
- ✅ Récupération du profil
- ✅ Inscription nouvel utilisateur
- ✅ Inscription doublon (409)
- ✅ Déconnexion
- ✅ Accès protégé sans session (403)

### Scénario Manuel Complet
```bash
# 1. Vérifier le statut
curl "http://localhost:8080/sprint0/api/auth/check"

# 2. Se connecter
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt

# 3. Vérifier le profil
curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt

# 4. Se déconnecter
curl -X POST "http://localhost:8080/sprint0/api/auth/logout" \
     -b cookies.txt
```

---

## 🛠️ Configuration

### Base de données ([`application.properties`](src/main/resources/application.properties))
```properties
db.url=jdbc:postgresql://localhost:5432/sprint0
db.username=cindy
db.password=cindy2301
db.driver=org.postgresql.Driver
```

### Contexte Spring ([`spring-context.xml`](src/main/webapp/WEB-INF/spring-context.xml))
- DataSource configuré avec properties
- JdbcTemplate injecté

### Servlet ([`web.xml`](src/main/webapp/WEB-INF/web.xml))
- `FrontServlet` (framework maison)
- Scan package: `com.spring.BackOffice.controller`
- Context Spring chargé au démarrage

---

## 🔧 Dépannage

### Erreur: "JdbcTemplate est null"
1. Vérifiez que PostgreSQL est démarré
2. Vérifiez les credentials dans `application.properties`
3. Vérifiez que `spring-context.xml` est dans `WEB-INF/`

### Erreur: 404 Not Found
1. Vérifiez l'URL: `http://localhost:8080/sprint0/api/...`
2. Vérifiez que Tomcat est démarré
3. Vérifiez le déploiement du WAR dans `webapps/`

### Erreur: Session non détectée
1. Utilisez `-c cookies.txt` lors du login
2. Utilisez `-b cookies.txt` pour les requêtes suivantes
3. Vérifiez que le fichier `cookies.txt` contient `JSESSIONID`

---

## 📦 Scripts Utiles

| Script | Description |
|--------|-------------|
| [`deploy-and-test.sh`](deploy-and-test.sh) | Compile et déploie sur Tomcat |
| [`test-api.sh`](test-api.sh) | Tests automatisés complets |
| [`TEST_CURL.md`](TEST_CURL.md) | Documentation complète des tests curl |
| [`deploy.sh`](deploy.sh) | Script de déploiement original |

---

## 🎯 Fonctionnalités du Sprint 11 bis

- ✅ **Gestion de session HTTP** via `HttpSession`
- ✅ **Injection de session** via `@Session("key")`
- ✅ **Protection par authentification** via `@RequireAuth`
- ✅ **Protection par rôle** via `@RequireRole("ROLE")`
- ✅ **Accès anonyme** via `@AllowAnonymous`
- ✅ **Réponses JSON** via `@RestAPI` + `JsonResponse`
- ✅ **Sérialisation JSON** automatique via `JsonSerializer`

---

## 🚀 Prochaines Étapes

### Améliorations Sécurité
1. **Hash des passwords** (BCrypt/Argon2)
2. **HTTPS obligatoire**
3. **Rate limiting** sur login
4. **CSRF protection**

### Fonctionnalités
1. **JWT tokens** (alternative aux sessions)
2. **Refresh tokens**
3. **OAuth2 integration**
4. **Permissions granulaires**

### Architecture
1. **Service layer** (séparer logique métier)
2. **DTO** (séparer entités et réponses)
3. **Validation** des inputs (Jakarta Bean Validation)
4. **Tests unitaires** (JUnit + Mockito)

---

## 📚 Ressources

- [Documentation Framework-S5](../../Framework-S5/framework/README.md)
- [Sprint 11 bis - Test HTML](../../Framework-S5/test/src/main/webapp/sprint11bis-security.html)
- [Tests cURL Détaillés](TEST_CURL.md)

---

## 👨‍💻 Auteur

Projet académique - Framework S5 - Sprint 11 bis
