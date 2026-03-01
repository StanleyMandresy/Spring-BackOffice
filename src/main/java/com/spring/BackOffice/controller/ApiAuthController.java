package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.JsonResponse;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Token;
import com.spring.BackOffice.model.User;
import com.spring.BackOffice.model.Voiture;

import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * API REST pour l'authentification avec retour JSON
 * Sprint 11 bis - Sécurité et Session
 */
@Controller
public class ApiAuthController {

    private JdbcTemplate jdbcTemplate;

    public ApiAuthController() {
        this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        if (this.jdbcTemplate == null) {
            System.err.println("⚠️ ATTENTION: JdbcTemplate est null dans ApiAuthController !");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    /**
     * Vérifier le token d'API depuis le header Authorization ou paramètre ?token=
     * Retourne null si valide, sinon retourne une JsonResponse d'erreur
     */
    private JsonResponse verifierToken(HttpServletRequest request, @RequestParam("token") String tokenParam) {
        // Essayer de récupérer le token depuis le header Authorization
        String authHeader = request.getHeader("Authorization");
        String tokenValue = null;
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            tokenValue = authHeader.substring(7);
        } else if (tokenParam != null && !tokenParam.trim().isEmpty()) {
            // Sinon utiliser le paramètre ?token=
            tokenValue = tokenParam;
        }
        
        if (tokenValue == null || tokenValue.trim().isEmpty()) {
            return JsonResponse.error(401, createErrorData("Token d'API requis. Utilisez 'Authorization: Bearer <token>' ou '?token=<token>'"));
        }
        
        // Vérifier la validité du token
        if (!Token.isTokenValide(jdbcTemplate, tokenValue)) {
            return JsonResponse.error(401, createErrorData("Token invalide ou expiré"));
        }
        
        return null; // Token valide
    }

    /**
     * POST /api/auth/login - Connexion utilisateur
     * Retourne un JSON avec les infos utilisateur
     * 
     * Test curl:
     * curl -X POST "http://localhost:8080/sprint0/api/auth/login" \
     *      -d "username=admin&password=adminpass" \
     *      -c cookies.txt
     */
    @RestAPI
    @PostMapping("/api/auth/login")
    @AllowAnonymous
    public JsonResponse login(HttpSession session,
                             @RequestParam("username") String username,
                             @RequestParam("password") String password) {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, 
                    createErrorData("Erreur serveur: Base de données non disponible"));
            }

            // Authentifier l'utilisateur
            User user = User.authenticate(jdbcTemplate, username, password);
            
            if (user != null) {
                // Stocker en session
                session.setAttribute("user", user.getNom());
                session.setAttribute("userId", user.getId());
                session.setAttribute("role", "USER"); // À adapter selon votre logique
                
                // Créer la réponse avec les données utilisateur
                Map<String, Object> userData = new HashMap<>();
                userData.put("id", user.getId());
                userData.put("username", user.getNom());
                userData.put("role", "USER");
                userData.put("message", "Connexion réussie");
                
                return JsonResponse.success(userData);
            } else {
                return JsonResponse.error(401, 
                    createErrorData("Identifiants incorrects"));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, 
                createErrorData("Erreur lors de l'authentification: " + e.getMessage()));
        }
    }

    /**
     * POST /api/auth/logout - Déconnexion
     * 
     * Test curl:
     * curl -X POST "http://localhost:8080/sprint0/api/auth/logout" \
     *      -b cookies.txt
     */
    @RestAPI
    @PostMapping("/api/auth/logout")
    @AllowAnonymous
    public JsonResponse logout(HttpSession session) {
        try {
            String username = (String) session.getAttribute("user");
            session.invalidate();
            
            Map<String, Object> data = new HashMap<>();
            data.put("message", "Déconnexion réussie");
            data.put("username", username != null ? username : "inconnu");
            
            return JsonResponse.success(data);
            
        } catch (Exception e) {
            return JsonResponse.error(500, 
                createErrorData("Erreur lors de la déconnexion"));
        }
    }

    /**
     * GET /api/auth/me - Récupérer le profil de l'utilisateur connecté
     * Nécessite d'être authentifié
     * 
     * Test curl:
     * curl "http://localhost:8080/sprint0/api/auth/me" -b cookies.txt
     */
    @RestAPI
    @GetMapping("/api/auth/me")
    @AllowAnonymous
    public JsonResponse getCurrentUser(HttpSession session) {
        // Vérification manuelle de l'authentification pour retourner JSON
        String username = (String) session.getAttribute("user");
        
        if (username == null) {
            return JsonResponse.error(403, 
                createErrorData("Accès non autorisé. Authentification requise."));
        }
        
        Long userId = (Long) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        
        Map<String, Object> userData = new HashMap<>();
        userData.put("id", userId);
        userData.put("username", username);
        userData.put("role", role != null ? role : "USER");
        userData.put("authenticated", true);
        
        return JsonResponse.success(userData);
    }

    /**
     * POST /api/auth/register - Inscription d'un nouvel utilisateur
     * 
     * Test curl:
     * curl -X POST "http://localhost:8080/sprint0/api/auth/register" \
     *      -d "username=testuser&password=testpass123"
     */
    @RestAPI
    @PostMapping("/api/auth/register")
    @AllowAnonymous
    public JsonResponse register(@RequestParam("username") String username,
                                @RequestParam("password") String password) {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, 
                    createErrorData("Erreur serveur: Base de données non disponible"));
            }

            // Vérifier si l'utilisateur existe déjà
            String checkSql = "SELECT COUNT(*) FROM users WHERE username = ?";
            Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, username);
            
            if (count != null && count > 0) {
                return JsonResponse.error(409, 
                    createErrorData("Ce nom d'utilisateur existe déjà"));
            }

            // Créer le nouvel utilisateur
            User newUser = new User(username, null, password);
            newUser.save(jdbcTemplate);
            
            Map<String, Object> data = new HashMap<>();
            data.put("username", username);
            data.put("message", "Inscription réussie");
            
            return JsonResponse.success(data);
            
        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, 
                createErrorData("Erreur lors de l'inscription: " + e.getMessage()));
        }
    }

    /**
     * GET /api/auth/check - Vérifier si l'utilisateur est connecté
     * 
     * Test curl:
     * curl "http://localhost:8080/sprint0/api/auth/check" -b cookies.txt
     */
    @RestAPI
    @GetMapping("/api/auth/check")
    @AllowAnonymous
    public JsonResponse checkAuth(HttpSession session) {
        String username = (String) session.getAttribute("user");
        
        Map<String, Object> data = new HashMap<>();
        data.put("authenticated", username != null);
        if (username != null) {
            data.put("username", username);
            data.put("userId", session.getAttribute("userId"));
            data.put("role", session.getAttribute("role"));
        }
        
        return JsonResponse.success(data);
    }

    /**
     * GET /api/voitures - Lister toutes les voitures (Token API requis)
     * 
     * Test curl avec Authorization header:
     * curl "http://localhost:8080/sprint0/api/voitures" -H "Authorization: Bearer <votre_token>"
     * 
     * Test curl avec paramètre:
     * curl "http://localhost:8080/sprint0/api/voitures?token=<votre_token>"
     */
    @RestAPI
    @GetMapping("/api/voitures")
    @AllowAnonymous
    public JsonResponse listVoitures(HttpServletRequest request, 
                                     @RequestParam("token") String token) {
        try {
            // Vérifier le token d'API
            JsonResponse tokenError = verifierToken(request, token);
            if (tokenError != null) {
                return tokenError; // Token invalide ou manquant
            }

            if (jdbcTemplate == null) {
                return JsonResponse.error(500, 
                    createErrorData("Erreur serveur: Base de données non disponible"));
            }

            // Récupérer toutes les voitures
            List<Voiture> voitures = Voiture.findAll(jdbcTemplate);
            
            // Créer la réponse avec les métadonnées
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("voitures", voitures);
            responseData.put("total", voitures.size());
            responseData.put("message", "Liste des voitures récupérée avec succès");
            
            return JsonResponse.success(responseData);
            
        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, 
                createErrorData("Erreur lors de la récupération des voitures: " + e.getMessage()));
        }
    }

    /**
     * GET /api/voitures/mes-voitures - Lister les voitures de l'utilisateur connecté (Session requise)
     * Note: Cet endpoint utilise toujours la session car il nécessite l'ID utilisateur
     * 
     * Test curl:
     * curl "http://localhost:8080/sprint0/api/voitures/mes-voitures" -b cookies.txt
     */
    @RestAPI
    @GetMapping("/api/voitures/mes-voitures")
    @AllowAnonymous
    public JsonResponse listMesVoitures(HttpSession session) {
        try {
            // Vérification manuelle de l'authentification
            String username = (String) session.getAttribute("user");
            Long userId = (Long) session.getAttribute("userId");
            
            if (username == null || userId == null) {
                return JsonResponse.error(403, 
                    createErrorData("Accès non autorisé. Vous devez être connecté."));
            }

            if (jdbcTemplate == null) {
                return JsonResponse.error(500, 
                    createErrorData("Erreur serveur: Base de données non disponible"));
            }

            // Récupérer les voitures de l'utilisateur
            List<Voiture> mesVoitures = Voiture.findByUserId(jdbcTemplate, userId);
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("voitures", mesVoitures);
            responseData.put("total", mesVoitures.size());
            responseData.put("proprietaire", username);
            responseData.put("message", "Vos voitures récupérées avec succès");
            
            return JsonResponse.success(responseData);
            
        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, 
                createErrorData("Erreur lors de la récupération de vos voitures: " + e.getMessage()));
        }
    }

    /**
     * Méthode utilitaire pour créer un objet d'erreur
     */
    private Map<String, String> createErrorData(String message) {
        Map<String, String> error = new HashMap<>();
        error.put("error", message);
        return error;
    }
}
