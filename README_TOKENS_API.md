# 🔐 Système de Tokens d'API - Sprint 2

## Vue d'ensemble

Ce système permet de **sécuriser les API REST** avec des tokens d'authentification. Chaque token :
- ✅ Est généré automatiquement avec UUID
- ✅ Est stocké en base de données PostgreSQL
- ✅ A une date d'expiration configurable
- ✅ Est vérifié à chaque appel API
- ❌ Refuse l'accès si invalide ou expiré

## Architecture

### 1. Table `token`

```sql
CREATE TABLE token (
    id SERIAL PRIMARY KEY,
    token VARCHAR(100) NOT NULL UNIQUE,
    date_expiration TIMESTAMP NOT NULL
);
```

### 2. Modèle `Token.java`

Fonctionnalités :
- `genererToken()` - Génère un token aléatoire de 14 caractères
- `creerToken(int jours)` - Crée un token avec durée de validité
- `save()` - Sauvegarde en base de données
- `isTokenValide()` - Vérifie si un token existe et n'est pas expiré
- `findByToken()` - Recherche un token par sa valeur
- `supprimerTokensExpires()` - Nettoie les tokens expirés

### 3. Contrôleur `TokenController.java`

Endpoints disponibles :

#### **POST** `/api/token/generer`
Génère un nouveau token

**Paramètres :**
- `jours` (optionnel, défaut: 7) - Durée de validité en jours

**Exemple :**
```bash
curl -X POST "http://localhost:8080/sprint0/api/token/generer?jours=7"
```

**Réponse :**
```json
{
  "status": "success",
  "data": {
    "token": "abc123xyz456de",
    "expiration": "2026-02-20T10:30:00",
    "validite_jours": 7,
    "message": "Token généré avec succès. Conservez-le précieusement !"
  }
}
```

#### **GET** `/api/token/verifier`
Vérifie la validité d'un token

**Paramètres :**
- `token` (requis) - Le token à vérifier

**Exemple :**
```bash
curl "http://localhost:8080/sprint0/api/token/verifier?token=abc123xyz456de"
```

#### **GET** `/api/token/liste`
Liste tous les tokens en base

**Exemple :**
```bash
curl "http://localhost:8080/sprint0/api/token/liste"
```

#### **DELETE** `/api/token/supprimer`
Supprime un token

**Paramètres :**
- `token` (requis) - Le token à supprimer

**Exemple :**
```bash
curl -X DELETE "http://localhost:8080/sprint0/api/token/supprimer?token=abc123xyz456de"
```

#### **POST** `/api/token/nettoyer`
Supprime tous les tokens expirés

**Exemple :**
```bash
curl -X POST "http://localhost:8080/sprint0/api/token/nettoyer"
```

## Utilisation avec les APIs protégées

### APIs protégées par token :

1. **GET** `/api/voitures` - Liste des voitures
2. **GET** `/reservation/list` - Liste des réservations

### Méthode 1 : Header Authorization (Recommandée)

```bash
curl "http://localhost:8080/sprint0/api/voitures" \
  -H "Authorization: Bearer abc123xyz456de"
```

### Méthode 2 : Paramètre URL

```bash
curl "http://localhost:8080/sprint0/api/voitures?token=abc123xyz456de"
```

## Workflow complet

```bash
# 1. Générer un token
curl -X POST "http://localhost:8080/sprint0/api/token/generer?jours=7"
# Réponse: { "data": { "token": "abc123xyz456de" } }

# 2. Utiliser le token pour accéder à une API
curl "http://localhost:8080/sprint0/api/voitures" \
  -H "Authorization: Bearer abc123xyz456de"

# 3. Vérifier le token si besoin
curl "http://localhost:8080/sprint0/api/token/verifier?token=abc123xyz456de"

# 4. Nettoyer les tokens expirés (maintenance)
curl -X POST "http://localhost:8080/sprint0/api/token/nettoyer"
```

## Codes d'erreur

| Code | Message | Description |
|------|---------|-------------|
| 401 | Token d'API requis | Aucun token fourni |
| 401 | Token invalide ou expiré | Token non trouvé ou date d'expiration dépassée |
| 400 | Le nombre de jours doit être entre 1 et 365 | Durée invalide |
| 404 | Token non trouvé | Le token n'existe pas en base |
| 500 | Base de données non disponible | Erreur serveur |

## Tests automatisés

Un script de test complet est disponible : `test-tokens.sh`

```bash
# Rendre le script exécutable
chmod +x test-tokens.sh

# Exécuter les tests
./test-tokens.sh
```

Le script teste :
- ✅ Génération de tokens
- ✅ Vérification de validité
- ✅ Protection des APIs (rejet sans token)
- ✅ Accès avec token valide (header et paramètre)
- ✅ Rejet des tokens invalides
- ✅ Nettoyage des tokens expirés
- ✅ Suppression de tokens

## Sécurité

### ✅ Bonnes pratiques implémentées :

1. **Tokens uniques** : UUID garantit l'unicité
2. **Expiration automatique** : Limite la durée de vie
3. **Validation stricte** : Vérification à chaque appel
4. **Stockage sécurisé** : Base de données PostgreSQL
5. **Nettoyage automatique** : Endpoint pour supprimer les tokens expirés

### 🔒 Recommandations :

- Ne pas exposer les tokens dans les logs
- Utiliser HTTPS en production
- Définir une durée de validité courte pour les tokens sensibles
- Implémenter un mécanisme de révocation si nécessaire
- Limiter le taux d'appels API (rate limiting)

## Exemples d'intégration

### JavaScript/Fetch

```javascript
const token = 'abc123xyz456de';

fetch('http://localhost:8080/sprint0/api/voitures', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})
.then(res => res.json())
.then(data => console.log(data));
```

### Python/Requests

```python
import requests

token = 'abc123xyz456de'
headers = {'Authorization': f'Bearer {token}'}

response = requests.get(
    'http://localhost:8080/sprint0/api/voitures',
    headers=headers
)
print(response.json())
```

### Java/HttpClient

```java
HttpClient client = HttpClient.newHttpClient();
String token = "abc123xyz456de";

HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("http://localhost:8080/sprint0/api/voitures"))
    .header("Authorization", "Bearer " + token)
    .build();

HttpResponse<String> response = client.send(request, 
    HttpResponse.BodyHandlers.ofString());
System.out.println(response.body());
```

## Configuration

La connexion à la base de données est définie dans `application.properties` :

```properties
db.url=jdbc:postgresql://localhost:5432/sprint0
db.username=cindy
db.password=cindy2301
db.driver=org.postgresql.Driver
```

## Maintenance

### Nettoyer régulièrement les tokens expirés

```bash
# Cron job quotidien (00h00)
0 0 * * * curl -X POST "http://localhost:8080/sprint0/api/token/nettoyer"
```

### Surveiller les tokens actifs

```bash
# Lister tous les tokens
curl "http://localhost:8080/sprint0/api/token/liste"
```

## FAQ

**Q: Combien de temps un token est-il valide ?**  
A: Par défaut 7 jours, configurable entre 1 et 365 jours lors de la génération.

**Q: Que se passe-t-il si mon token expire ?**  
A: Vous recevrez une erreur 401 "Token invalide ou expiré". Générez un nouveau token.

**Q: Puis-je avoir plusieurs tokens actifs ?**  
A: Oui, vous pouvez générer autant de tokens que nécessaire.

**Q: Comment révoquer un token ?**  
A: Utilisez l'endpoint `/api/token/supprimer?token=<votre_token>`

**Q: Les tokens sont-ils compatibles avec toutes les APIs ?**  
A: Non, seules les APIs marquées avec la vérification de token sont protégées. Les endpoints d'authentification classiques (`/api/auth/login`, etc.) utilisent toujours les sessions.

---

**📅 Créé le :** 13 février 2026  
**🏷️ Version :** Sprint 2  
**👨‍💻 Framework :** Spring 6.1.2 + Custom MVC Framework
