
package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Modèle pour représenter les paramètres de transport
 */
public class Parametre {

    private Long id;
    private BigDecimal vitesseKmh;
    private Integer tempsAttenteMinute;

    // Constructeurs
    public Parametre() {}

    public Parametre(BigDecimal vitesseKmh, Integer tempsAttenteMinute) {
        this.vitesseKmh = vitesseKmh;
        this.tempsAttenteMinute = tempsAttenteMinute;
    }

    // -------------------
    // Méthodes statiques
    // -------------------

    public static List<Parametre> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM parametre ORDER BY id";
        return jdbcTemplate.query(sql, new ParametreRowMapper());
    }

    public static Parametre findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT * FROM parametre WHERE id = ?";
        List<Parametre> list = jdbcTemplate.query(sql, new Object[]{id}, new ParametreRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    public static Parametre getLatest(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM parametre ORDER BY id DESC LIMIT 1";
        List<Parametre> list = jdbcTemplate.query(sql, new ParametreRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    public void save(JdbcTemplate jdbcTemplate) {
        String sql = "INSERT INTO parametre (vitesse_kmh, temps_attente_minute) VALUES (?, ?)";
        jdbcTemplate.update(sql, this.vitesseKmh, this.tempsAttenteMinute);
    }

    // -------------------
    // RowMapper
    // -------------------

    private static class ParametreRowMapper implements RowMapper<Parametre> {
        @Override
        public Parametre mapRow(ResultSet rs, int rowNum) throws SQLException {
            Parametre p = new Parametre();
            p.setId(rs.getLong("id"));
            p.setVitesseKmh(rs.getBigDecimal("vitesse_kmh"));
            p.setTempsAttenteMinute(rs.getInt("temps_attente_minute"));
            return p;
        }
    }

    // -------------------
    // Getters / Setters
    // -------------------

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public BigDecimal getVitesseKmh() { return vitesseKmh; }
    public void setVitesseKmh(BigDecimal vitesseKmh) { this.vitesseKmh = vitesseKmh; }

    public Integer getTempsAttenteMinute() { return tempsAttenteMinute; }
    public void setTempsAttenteMinute(Integer tempsAttenteMinute) { this.tempsAttenteMinute = tempsAttenteMinute; }

    @Override
    public String toString() {
        return "Parametre{id=" + id +
                ", vitesse=" + vitesseKmh +
                ", attente=" + tempsAttenteMinute + "}";
    }
}