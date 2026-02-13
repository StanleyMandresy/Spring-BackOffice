package com.spring.BackOffice;

import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Token;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDateTime;
import java.sql.Timestamp;

/**
 * Exemple de génération de token en Java
 * Démontre l'utilisation du modèle Token
 */
public class TokenGeneratorExample {

    public static void main(String[] args) {
        System.out.println("╔════════════════════════════════════════════╗");
        System.out.println("║   GÉNÉRATEUR DE TOKENS D'API - SPRINT 2   ║");
        System.out.println("╚════════════════════════════════════════════╝");
        System.out.println();

        // Initialiser la connexion JDBC
        JdbcTemplate jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        
        if (jdbcTemplate == null) {
            System.err.println("❌ Erreur: Impossible de se connecter à la base de données");
            System.err.println("   Vérifiez votre configuration dans application.properties");
            return;
        }
        
        System.out.println("✅ Connexion à la base de données établie");
        System.out.println();

        // MÉTHODE 1 : Générer un token simple (UUID)
        System.out.println("📝 Méthode 1: Génération d'un token simple");
        System.out.println("   String tokenValue = Token.genererToken();");
        String tokenValue = Token.genererToken();
        System.out.println("   Token généré: " + tokenValue);
        System.out.println();

        // MÉTHODE 2 : Créer et sauvegarder un token avec expiration
        System.out.println("📝 Méthode 2: Créer un token avec expiration (7 jours)");
        System.out.println("   Token token = Token.creerToken(7);");
        Token token = Token.creerToken(7);
        System.out.println("   Token: " + token.getToken());
        System.out.println("   Expiration: " + token.getDateExpiration());
        System.out.println();

        // Sauvegarder en base de données
        System.out.println("💾 Sauvegarde en base de données");
        System.out.println("   Long tokenId = token.save(jdbcTemplate);");
        Long tokenId = token.save(jdbcTemplate);
        System.out.println("   ✅ Token sauvegardé avec ID: " + tokenId);
        System.out.println();

        // MÉTHODE 3 : Création manuelle avec LocalDateTime
        System.out.println("📝 Méthode 3: Création manuelle d'un token");
        System.out.println("   Token t = new Token();");
        System.out.println("   t.setToken(Token.genererToken());");
        System.out.println("   LocalDateTime expiration = LocalDateTime.now().plusDays(7);");
        System.out.println("   t.setDateExpiration(Timestamp.valueOf(expiration));");
        
        Token t = new Token();
        t.setToken(Token.genererToken());
        LocalDateTime expiration = LocalDateTime.now().plusDays(7);
        t.setDateExpiration(Timestamp.valueOf(expiration));
        
        System.out.println("   Token: " + t.getToken());
        System.out.println("   Expiration: " + t.getDateExpiration());
        System.out.println();

        // Sauvegarder ce token aussi
        System.out.println("💾 Sauvegarde du second token");
        Long tokenId2 = t.save(jdbcTemplate);
        System.out.println("   ✅ Token sauvegardé avec ID: " + tokenId2);
        System.out.println();

        // Vérifier la validité des tokens
        System.out.println("🔍 Vérification de la validité des tokens");
        System.out.println("   boolean valide1 = Token.isTokenValide(jdbcTemplate, token.getToken());");
        boolean valide1 = Token.isTokenValide(jdbcTemplate, token.getToken());
        System.out.println("   Token 1 valide: " + (valide1 ? "✅ OUI" : "❌ NON"));
        
        System.out.println("   boolean valide2 = Token.isTokenValide(jdbcTemplate, t.getToken());");
        boolean valide2 = Token.isTokenValide(jdbcTemplate, t.getToken());
        System.out.println("   Token 2 valide: " + (valide2 ? "✅ OUI" : "❌ NON"));
        System.out.println();

        // Lister tous les tokens
        System.out.println("📋 Liste de tous les tokens en base");
        System.out.println("   List<Token> tokens = Token.findAll(jdbcTemplate);");
        var tokens = Token.findAll(jdbcTemplate);
        System.out.println("   Total: " + tokens.size() + " token(s)");
        System.out.println();
        
        for (int i = 0; i < Math.min(5, tokens.size()); i++) {
            Token tk = tokens.get(i);
            String status = tk.isExpire() ? "⏰ EXPIRÉ" : "✅ VALIDE";
            System.out.println("   " + (i + 1) + ". " + tk.getToken() + " - " + status);
        }
        
        if (tokens.size() > 5) {
            System.out.println("   ... (" + (tokens.size() - 5) + " autres)");
        }
        System.out.println();

        // Test avec un faux token
        System.out.println("❌ Test avec un token invalide");
        System.out.println("   boolean valideTest = Token.isTokenValide(jdbcTemplate, \"FAUX_TOKEN_123\");");
        boolean valideTest = Token.isTokenValide(jdbcTemplate, "FAUX_TOKEN_123");
        System.out.println("   Résultat: " + (valideTest ? "✅ VALIDE" : "❌ INVALIDE (attendu)"));
        System.out.println();

        // Nettoyer les tokens expirés
        System.out.println("🧹 Nettoyage des tokens expirés");
        System.out.println("   int deleted = Token.supprimerTokensExpires(jdbcTemplate);");
        int deleted = Token.supprimerTokensExpires(jdbcTemplate);
        System.out.println("   ✅ " + deleted + " token(s) expiré(s) supprimé(s)");
        System.out.println();

        // Résumé final
        System.out.println("╔════════════════════════════════════════════╗");
        System.out.println("║            RÉSUMÉ DES TOKENS               ║");
        System.out.println("╚════════════════════════════════════════════╝");
        System.out.println("✅ Token 1: " + token.getToken());
        System.out.println("✅ Token 2: " + t.getToken());
        System.out.println();
        System.out.println("💡 Utilisez ces tokens pour tester les APIs protégées:");
        System.out.println("   curl \"http://localhost:8080/sprint0/api/voitures?token=" + token.getToken() + "\"");
        System.out.println();
        System.out.println("   curl \"http://localhost:8080/sprint0/api/voitures\" \\");
        System.out.println("        -H \"Authorization: Bearer " + token.getToken() + "\"");
        System.out.println();
    }
}
