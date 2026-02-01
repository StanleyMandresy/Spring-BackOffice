# 🔧 Notes Techniques - Gestion des Erreurs d'Authentification

## ❓ Problème Initial

Lors de l'utilisation de `@RequireAuth` sur un endpoint avec `@RestAPI`, le framework retournait du **HTML** au lieu de **JSON** en cas d'erreur d'authentification.

### Comportement observé :
```bash
curl "http://localhost:8080/sprint0/api/auth/me"
```

**Réponse reçue (HTML):**
```html
<!DOCTYPE html>
<html>
<head><meta charset='UTF-8'>
...
<h1>🔒 401 - Non autorisé</h1>
<p>Authentification requise. Vous devez être connecté.</p>
...
</html>
```

**Réponse attendue (JSON):**
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

## 🔍 Analyse du Problème

### Flux d'exécution avec `@RequireAuth`

```
Client Request
     │
     v
FrontServlet.doGet()
     │
     ├─> checkAuthorization(method, req, res)
     │       │
     │       ├─> method.isAnnotationPresent(RequireAuth.class)? ✅
     │       │
     │       ├─> session.getAttribute("user") == null? ✅
     │       │
     │       └─> sendUnauthorizedError(res, "...")
     │               │
     │               └─> res.setContentType("text/html")  ⚠️ PROBLÈME
     │                   HTML retourné, STOP ici
     │
     └─> [Le contrôleur n'est jamais appelé]
```

### Code dans FrontServlet.java

```java
private void sendUnauthorizedError(HttpServletResponse res, String message) 
        throws IOException {
    res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    res.setContentType("text/html; charset=UTF-8");  // ⚠️ Toujours HTML
    PrintWriter out = res.getWriter();
    out.println("<!DOCTYPE html>");
    out.println("<html>...");
    // ...
}
```

**Problème:** Le framework ne vérifie pas si la méthode a `@RestAPI` avant de retourner l'erreur.

---

## ✅ Solution Implémentée

### Approche : Vérification Manuelle de Session

Au lieu d'utiliser `@RequireAuth`, on utilise `@AllowAnonymous` et on vérifie **manuellement** la session dans le contrôleur.

#### Avant (ne fonctionne pas pour JSON) :
```java
@RestAPI
@GetMapping("/api/auth/me")
@RequireAuth  // ⚠️ Retourne HTML en cas d'erreur
public JsonResponse getCurrentUser(@Session("user") String username,
                                   @Session("userId") Long userId,
                                   @Session("role") String role) {
    // Ce code n'est jamais exécuté si pas authentifié
    Map<String, Object> userData = new HashMap<>();
    userData.put("id", userId);
    userData.put("username", username);
    userData.put("role", role);
    userData.put("authenticated", true);
    
    return JsonResponse.success(userData);
}
```

#### Après (fonctionne avec JSON) :
```java
@RestAPI
@GetMapping("/api/auth/me")
@AllowAnonymous  // ✅ Laisser passer, on vérifie manuellement
public JsonResponse getCurrentUser(HttpSession session) {
    // Vérification manuelle de l'authentification
    String username = (String) session.getAttribute("user");
    
    if (username == null) {
        // ✅ Retourne JSON car on est dans le contrôleur
        return JsonResponse.error(403, 
            createErrorData("Accès non autorisé. Authentification requise."));
    }
    
    // Utilisateur authentifié, récupérer les données
    Long userId = (Long) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    
    Map<String, Object> userData = new HashMap<>();
    userData.put("id", userId);
    userData.put("username", username);
    userData.put("role", role != null ? role : "USER");
    userData.put("authenticated", true);
    
    return JsonResponse.success(userData);
}
```

### Flux d'exécution avec `@AllowAnonymous`

```
Client Request
     │
     v
FrontServlet.doGet()
     │
     ├─> checkAuthorization(method, req, res)
     │       │
     │       ├─> method.isAnnotationPresent(AllowAnonymous.class)? ✅
     │       │
     │       └─> return true (passer)
     │
     ├─> Appeler la méthode du contrôleur
     │       │
     │       ├─> session.getAttribute("user") == null?
     │       │       │
     │       │       └─> return JsonResponse.error(403, ...) ✅ JSON
     │       │
     │       └─> return JsonResponse.success(...) ✅ JSON
     │
     └─> Sérialiser JsonResponse en JSON avec JsonSerializer
```

---

## 🎯 Avantages de cette Solution

| Aspect | Avec `@RequireAuth` | Avec Vérification Manuelle |
|--------|---------------------|----------------------------|
| **Format d'erreur** | HTML | ✅ JSON |
| **Cohérence API** | Incohérent | ✅ Cohérent |
| **Code HTTP** | 401 | ✅ 403 (plus approprié) |
| **Personnalisation** | Limitée | ✅ Totale |
| **Tests API** | Échouent | ✅ Passent |

---

## 🔄 Solutions Alternatives (Non Implémentées)

### Solution 1 : Modifier le Framework

Modifier `FrontServlet.checkAuthorization()` pour détecter `@RestAPI` et retourner du JSON :

```java
private boolean checkAuthorization(Method method, HttpServletRequest req, 
                                   HttpServletResponse res) throws IOException {
    // ...
    if (method.isAnnotationPresent(RequireAuth.class)) {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            
            // ✅ NOUVEAU: Vérifier si @RestAPI
            if (method.isAnnotationPresent(RestAPI.class)) {
                sendJsonUnauthorizedError(res);  // Nouveau JSON
            } else {
                sendUnauthorizedError(res, "...");  // Ancien HTML
            }
            return false;
        }
    }
    // ...
}

private void sendJsonUnauthorizedError(HttpServletResponse res) 
        throws IOException {
    res.setStatus(HttpServletResponse.SC_FORBIDDEN);
    res.setContentType("application/json; charset=UTF-8");
    PrintWriter out = res.getWriter();
    
    JsonResponse errorResponse = JsonResponse.error(403, 
        Map.of("error", "Accès non autorisé. Authentification requise."));
    
    out.print(JsonSerializer.toJson(errorResponse));
}
```

**Avantage:** `@RequireAuth` fonctionne correctement avec `@RestAPI`  
**Inconvénient:** Nécessite de modifier le code du framework (pas toujours possible)

---

### Solution 2 : Créer une Annotation Personnalisée

Créer `@RequireAuthJson` qui combine `@RequireAuth` et retour JSON :

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface RequireAuthJson {
}
```

**Avantage:** Sémantique claire  
**Inconvénient:** Nécessite aussi de modifier le framework

---

## 📝 Recommandations

### Pour les APIs JSON (`@RestAPI`)

✅ **Utiliser la vérification manuelle** (solution actuelle)
```java
@RestAPI
@AllowAnonymous
public JsonResponse endpoint(HttpSession session) {
    if (session.getAttribute("user") == null) {
        return JsonResponse.error(403, ...);
    }
    // ...
}
```

### Pour les Pages HTML

✅ **Utiliser `@RequireAuth`** (retour HTML souhaité)
```java
@GetMapping("/admin")
@RequireAuth
public ModelView adminPage() {
    // ...
}
```

---

## 🧪 Tests de Validation

### Test avec session valide

```bash
curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     -d "username=admin&password=adminpass" \
     -c cookies.txt

curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt
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
    "authenticated": true
  }
}
```

### Test sans session

```bash
curl "http://localhost:8080/sprint0/api/auth/me"
```

**Résultat attendu:**
```json
{
  "status": "error",
  "code": 403,
  "data": {
    "error": "Accès non autorisé. Authentification requise."
  }
}
```

✅ **Plus de HTML retourné !**

---

## 💡 Conclusion

La vérification manuelle de session dans le contrôleur est une **solution pragmatique** qui garantit des réponses JSON cohérentes pour les APIs REST, même si elle nécessite un peu plus de code.

Cette approche est préférable à la modification du framework, surtout dans un contexte académique où le framework peut être utilisé par plusieurs projets.

---

## 🔗 Références

- [ApiAuthController.java](src/main/java/com/spring/BackOffice/controller/ApiAuthController.java) - Implémentation
- [FrontServlet.java](../../Framework-S5/framework/src/main/java/com/myframework/core/FrontServlet.java) - Code framework
- [test-api.sh](test-api.sh) - Tests de validation
