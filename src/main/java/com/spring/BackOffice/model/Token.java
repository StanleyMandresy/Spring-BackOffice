package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Modèle pour représenter un token d'API
 */
public class Token {
    
    private Long id;
    private String token;
    private Timestamp dateExpiration;

    // Constructeurs
    public Token() {}

    public Token(String token, Timestamp dateExpiration) {
        this.token = token;
        this.dateExpiration = dateExpiration;
    }

    /**
     * Générer un token aléatoire de 14 caractères
     */
    public static String genererToken() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 14);
    }

    /**
     * Créer un token avec une durée de validité en jours
     */
    public static Token creerToken(int joursValidite) {
        String tokenValue = genererToken();
        LocalDateTime expiration = LocalDateTime.now().plusDays(joursValidite);
        Timestamp dateExpiration = Timestamp.valueOf(expiration);
        return new Token(tokenValue, dateExpiration);
    }

    /**
     * Sauvegarder un token en base
     */
    public Long save(JdbcTemplate jdbcTemplate) {
        String sql = "INSERT INTO token (token, date_expiration) VALUES (?, ?)";
        
        KeyHolder keyHolder = new GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id"});
            ps.setString(1, this.token);
            ps.setTimestamp(2, this.dateExpiration);
            return ps;
        }, keyHolder);
        
        if (keyHolder.getKey() != null) {
            this.id = keyHolder.getKey().longValue();
        }
        
        return this.id;
    }

    /**
     * Trouver un token par sa valeur
     */
    public static Token findByToken(JdbcTemplate jdbcTemplate, String tokenValue) {
        String sql = "SELECT * FROM token WHERE token = ?";
        List<Token> tokens = jdbcTemplate.query(sql, new Object[]{tokenValue}, new TokenRowMapper());
        return tokens.isEmpty() ? null : tokens.get(0);
    }

    /**
     * Vérifier si un token est valide (existe et non expiré)
     */
    public static boolean isTokenValide(JdbcTemplate jdbcTemplate, String tokenValue) {
        Token token = findByToken(jdbcTemplate, tokenValue);
        
        if (token == null) {
            return false; // Token n'existe pas
        }
        
        // Vérifier si le token n'est pas expiré
        Timestamp maintenant = new Timestamp(System.currentTimeMillis());
        return token.getDateExpiration().after(maintenant);
    }

    /**
     * Récupérer tous les tokens
     */
    public static List<Token> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM token ORDER BY date_expiration DESC";
        return jdbcTemplate.query(sql, new TokenRowMapper());
    }

    /**
     * Supprimer les tokens expirés
     */
    public static int supprimerTokensExpires(JdbcTemplate jdbcTemplate) {
        String sql = "DELETE FROM token WHERE date_expiration < CURRENT_TIMESTAMP";
        return jdbcTemplate.update(sql);
    }

    /**
     * Supprimer un token par sa valeur
     */
    public static int deleteByToken(JdbcTemplate jdbcTemplate, String tokenValue) {
        String sql = "DELETE FROM token WHERE token = ?";
        return jdbcTemplate.update(sql, tokenValue);
    }

    /**
     * Vérifier si un token est expiré
     */
    public boolean isExpire() {
        Timestamp maintenant = new Timestamp(System.currentTimeMillis());
        return this.dateExpiration.before(maintenant);
    }

    // -------------------
    // RowMapper pour JdbcTemplate
    // -------------------
    private static class TokenRowMapper implements RowMapper<Token> {
        @Override
        public Token mapRow(ResultSet rs, int rowNum) throws SQLException {
            Token token = new Token();
            token.setId(rs.getLong("id"));
            token.setToken(rs.getString("token"));
            token.setDateExpiration(rs.getTimestamp("date_expiration"));
            return token;
        }
    }

    // -------------------
    // Getters et setters
    // -------------------
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public Timestamp getDateExpiration() { return dateExpiration; }
    public void setDateExpiration(Timestamp dateExpiration) { this.dateExpiration = dateExpiration; }

    @Override
    public String toString() {
        return String.format("Token{id=%d, token='%s', expiration=%s}", 
            id, token, dateExpiration);
    }
}
