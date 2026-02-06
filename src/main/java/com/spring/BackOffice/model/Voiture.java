package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Modèle pour représenter une voiture
 */
public class Voiture {
    
    private Long id;
    private String marque;
    private String modele;
    private Integer annee;
    private BigDecimal prix;
    private Long userId;
    private Timestamp createdAt;

    // Constructeurs
    public Voiture() {}

    public Voiture(String marque, String modele, Integer annee, BigDecimal prix, Long userId) {
        this.marque = marque;
        this.modele = modele;
        this.annee = annee;
        this.prix = prix;
        this.userId = userId;
    }

    // -------------------
    // Méthodes statiques avec JdbcTemplate
    // -------------------
    
    /**
     * Récupérer toutes les voitures
     */
    public static List<Voiture> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM voitures ORDER BY marque, modele";
        return jdbcTemplate.query(sql, new VoitureRowMapper());
    }

    /**
     * Récupérer les voitures d'un utilisateur spécifique
     */
    public static List<Voiture> findByUserId(JdbcTemplate jdbcTemplate, Long userId) {
        String sql = "SELECT * FROM voitures WHERE user_id = ? ORDER BY marque, modele";
        return jdbcTemplate.query(sql, new Object[]{userId}, new VoitureRowMapper());
    }

    /**
     * Récupérer une voiture par ID
     */
    public static Voiture findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT * FROM voitures WHERE id = ?";
        List<Voiture> voitures = jdbcTemplate.query(sql, new Object[]{id}, new VoitureRowMapper());
        return voitures.isEmpty() ? null : voitures.get(0);
    }

    /**
     * Compter le nombre total de voitures
     */
    public static int countAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT COUNT(*) FROM voitures";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    // -------------------
    // RowMapper pour JdbcTemplate
    // -------------------
    private static class VoitureRowMapper implements RowMapper<Voiture> {
        @Override
        public Voiture mapRow(ResultSet rs, int rowNum) throws SQLException {
            Voiture voiture = new Voiture();
            voiture.setId(rs.getLong("id"));
            voiture.setMarque(rs.getString("marque"));
            voiture.setModele(rs.getString("modele"));
            voiture.setAnnee(rs.getInt("annee"));
            voiture.setPrix(rs.getBigDecimal("prix"));
            
            // user_id peut être null
            Long userId = rs.getLong("user_id");
            if (rs.wasNull()) {
                userId = null;
            }
            voiture.setUserId(userId);
            
            voiture.setCreatedAt(rs.getTimestamp("created_at"));
            return voiture;
        }
    }

    // -------------------
    // Getters et setters
    // -------------------
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getMarque() { return marque; }
    public void setMarque(String marque) { this.marque = marque; }

    public String getModele() { return modele; }
    public void setModele(String modele) { this.modele = modele; }

    public Integer getAnnee() { return annee; }
    public void setAnnee(Integer annee) { this.annee = annee; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return String.format("Voiture{id=%d, marque='%s', modele='%s', annee=%d, prix=%.2f, userId=%s}", 
            id, marque, modele, annee, prix, userId);
    }
}