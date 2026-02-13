package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.JsonResponse;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Token;

import org.springframework.jdbc.core.JdbcTemplate;

import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour la gestion des tokens d'API
 */
@Controller
public class TokenController {

    private JdbcTemplate jdbcTemplate;

    public TokenController() {
        this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        if (this.jdbcTemplate == null) {
            System.err.println("⚠️ ATTENTION: JdbcTemplate est null dans TokenController !");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    /**
     * POST /api/token/generer - Générer un nouveau token
     * 
     * Test curl:
     * curl -X POST "http://localhost:8080/sprint0/api/token/generer?jours=7"
     */
    @RestAPI
    @PostMapping("/api/token/generer")
    public JsonResponse genererToken(@RequestParam("jours") String joursStr) {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, createErrorData("Base de données non disponible"));
            }

            // Parser le nombre de jours (défaut: 7 jours)
            int jours = 7;
            if (joursStr != null && !joursStr.trim().isEmpty()) {
                try {
                    jours = Integer.parseInt(joursStr);
                    if (jours <= 0 || jours > 365) {
                        return JsonResponse.error(400, createErrorData("Le nombre de jours doit être entre 1 et 365"));
                    }
                } catch (NumberFormatException e) {
                    return JsonResponse.error(400, createErrorData("Nombre de jours invalide"));
                }
            }

            // Créer et sauvegarder le token
            Token token = Token.creerToken(jours);
            Long tokenId = token.save(jdbcTemplate);

            if (tokenId != null) {
                // Récupérer le token depuis la base pour s'assurer qu'on retourne exactement ce qui est stocké
                Token tokenSauvegarde = Token.findByToken(jdbcTemplate, token.getToken());
                
                if (tokenSauvegarde == null) {
                    // Si le token n'est pas trouvé, utiliser l'objet original
                    tokenSauvegarde = token;
                }
                
                // Formater la date d'expiration en chaîne lisible
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String expirationFormatee = sdf.format(tokenSauvegarde.getDateExpiration());
                
                Map<String, Object> data = new HashMap<>();
                data.put("id", tokenSauvegarde.getId());
                data.put("token", tokenSauvegarde.getToken());
                data.put("expiration", expirationFormatee);
                data.put("validite_jours", jours);
                data.put("message", "Token généré avec succès. Conservez-le précieusement !");
                
                System.out.println("✅ Token généré: " + tokenSauvegarde.getToken() + " (ID: " + tokenSauvegarde.getId() + ", expire: " + expirationFormatee + ")");
                return JsonResponse.success(data);
            } else {
                return JsonResponse.error(500, createErrorData("Erreur lors de la génération du token"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, createErrorData("Erreur serveur: " + e.getMessage()));
        }
    }

    /**
     * GET /api/token/verifier - Vérifier la validité d'un token
     * 
     * Test curl:
     * curl "http://localhost:8080/sprint0/api/token/verifier?token=abc123xyz456"
     */
    @RestAPI
    @GetMapping("/api/token/verifier")
    public JsonResponse verifierToken(@RequestParam("token") String tokenValue) {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, createErrorData("Base de données non disponible"));
            }

            if (tokenValue == null || tokenValue.trim().isEmpty()) {
                return JsonResponse.error(400, createErrorData("Le token est requis"));
            }

            boolean valide = Token.isTokenValide(jdbcTemplate, tokenValue);
            
            Map<String, Object> data = new HashMap<>();
            data.put("token", tokenValue);
            data.put("valide", valide);
            
            if (valide) {
                Token token = Token.findByToken(jdbcTemplate, tokenValue);
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String expirationFormatee = sdf.format(token.getDateExpiration());
                data.put("expiration", expirationFormatee);
                data.put("message", "Token valide");
                return JsonResponse.success(data);
            } else {
                data.put("message", "Token invalide ou expiré");
                return JsonResponse.error(401, data);
            }

        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, createErrorData("Erreur serveur: " + e.getMessage()));
        }
    }

    /**
     * GET /api/token/liste - Lister tous les tokens
     * 
     * Test curl:
     * curl "http://localhost:8080/sprint0/api/token/liste"
     */
    @RestAPI
    @GetMapping("/api/token/liste")
    public JsonResponse listerTokens() {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, createErrorData("Base de données non disponible"));
            }

            List<Token> tokens = Token.findAll(jdbcTemplate);
            
            Map<String, Object> data = new HashMap<>();
            data.put("tokens", tokens);
            data.put("total", tokens.size());
            
            return JsonResponse.success(data);

        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, createErrorData("Erreur serveur: " + e.getMessage()));
        }
    }

    /**
     * DELETE /api/token/supprimer - Supprimer un token
     * 
     * Test curl:
     * curl -X DELETE "http://localhost:8080/sprint0/api/token/supprimer?token=abc123xyz456"
     */
    @RestAPI
    @PostMapping("/api/token/supprimer")
    public JsonResponse supprimerToken(@RequestParam("token") String tokenValue) {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, createErrorData("Base de données non disponible"));
            }

            if (tokenValue == null || tokenValue.trim().isEmpty()) {
                return JsonResponse.error(400, createErrorData("Le token est requis"));
            }

            int deleted = Token.deleteByToken(jdbcTemplate, tokenValue);
            
            Map<String, Object> data = new HashMap<>();
            if (deleted > 0) {
                data.put("message", "Token supprimé avec succès");
                data.put("token", tokenValue);
                return JsonResponse.success(data);
            } else {
                data.put("message", "Token non trouvé");
                return JsonResponse.error(404, data);
            }

        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, createErrorData("Erreur serveur: " + e.getMessage()));
        }
    }

    /**
     * POST /api/token/nettoyer - Supprimer tous les tokens expirés
     * 
     * Test curl:
     * curl -X POST "http://localhost:8080/sprint0/api/token/nettoyer"
     */
    @RestAPI
    @PostMapping("/api/token/nettoyer")
    public JsonResponse nettoyerTokensExpires() {
        try {
            if (jdbcTemplate == null) {
                return JsonResponse.error(500, createErrorData("Base de données non disponible"));
            }

            int deleted = Token.supprimerTokensExpires(jdbcTemplate);
            
            Map<String, Object> data = new HashMap<>();
            data.put("tokens_supprimes", deleted);
            data.put("message", deleted + " token(s) expiré(s) supprimé(s)");
            
            return JsonResponse.success(data);

        } catch (Exception e) {
            e.printStackTrace();
            return JsonResponse.error(500, createErrorData("Erreur serveur: " + e.getMessage()));
        }
    }

    /**
     * Créer un objet d'erreur standardisé
     */
    private Map<String, Object> createErrorData(String message) {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("error", message);
        return errorData;
    }
}
