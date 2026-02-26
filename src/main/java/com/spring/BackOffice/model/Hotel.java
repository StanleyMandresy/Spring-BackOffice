package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Modèle pour représenter un hôtel
 */
public class Hotel {
    
    private Long idHotel;
    private String nomHotel;
    private String adresse;
    private String ville;
    private BigDecimal prixNuit;
    private Integer nombreEtoiles;
    private Timestamp dateCreation;

    // Constructeurs
    public Hotel() {}

    public Hotel(String nomHotel, String adresse, String ville, BigDecimal prixNuit, Integer nombreEtoiles) {
        this.nomHotel = nomHotel;
        this.adresse = adresse;
        this.ville = ville;
        this.prixNuit = prixNuit;
        this.nombreEtoiles = nombreEtoiles;
    }

    // -------------------
    // Méthodes statiques avec JdbcTemplate
    // -------------------
    
    /**
     * Récupérer tous les hôtels
     */
    public static List<Hotel> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM hotel ORDER BY nom_hotel";
        return jdbcTemplate.query(sql, new HotelRowMapper());
    }

    /**
     * Récupérer un hôtel par ID
     */
    public static Hotel findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT * FROM hotel WHERE id_hotel = ?";
        List<Hotel> hotels = jdbcTemplate.query(sql, new Object[]{id}, new HotelRowMapper());
        return hotels.isEmpty() ? null : hotels.get(0);
    }

    /**
     * Rechercher des hôtels par ville
     */
    public static List<Hotel> findByVille(JdbcTemplate jdbcTemplate, String ville) {
        String sql = "SELECT * FROM hotel WHERE ville ILIKE ? ORDER BY nom_hotel";
        return jdbcTemplate.query(sql, new Object[]{"%" + ville + "%"}, new HotelRowMapper());
    }

     public static Hotel findByNom(JdbcTemplate jdbcTemplate, String nom) {
        String sql = "SELECT * FROM hotel WHERE nom_hotel ILIKE ? ORDER BY nom_hotel";
        List<Hotel> hotels = jdbcTemplate.query(sql, new Object[]{"%" + nom + "%"}, new HotelRowMapper());
        return hotels.isEmpty() ? null : hotels.get(0); 
    }

    /**
     * Sauvegarder un nouvel hôtel
     */
    public void save(JdbcTemplate jdbcTemplate) {
        String sql = "INSERT INTO hotel (nom_hotel, adresse, ville, prix_nuit, nombre_etoiles) VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, this.nomHotel, this.adresse, this.ville, this.prixNuit, this.nombreEtoiles);
    }

    

    // -------------------
    // RowMapper pour JdbcTemplate
    // -------------------
    private static class HotelRowMapper implements RowMapper<Hotel> {
        @Override
        public Hotel mapRow(ResultSet rs, int rowNum) throws SQLException {
            Hotel hotel = new Hotel();
            hotel.setIdHotel(rs.getLong("id_hotel"));
            hotel.setNomHotel(rs.getString("nom_hotel"));
            hotel.setAdresse(rs.getString("adresse"));
            hotel.setVille(rs.getString("ville"));
            hotel.setPrixNuit(rs.getBigDecimal("prix_nuit"));
            hotel.setNombreEtoiles(rs.getInt("nombre_etoiles"));
            hotel.setDateCreation(rs.getTimestamp("date_creation"));
            return hotel;
        }
    }

    // -------------------
    // Getters et setters
    // -------------------
    public Long getIdHotel() { return idHotel; }
    public void setIdHotel(Long idHotel) { this.idHotel = idHotel; }

    public String getNomHotel() { return nomHotel; }
    public void setNomHotel(String nomHotel) { this.nomHotel = nomHotel; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }

    public BigDecimal getPrixNuit() { return prixNuit; }
    public void setPrixNuit(BigDecimal prixNuit) { this.prixNuit = prixNuit; }

    public Integer getNombreEtoiles() { return nombreEtoiles; }
    public void setNombreEtoiles(Integer nombreEtoiles) { this.nombreEtoiles = nombreEtoiles; }

    public Timestamp getDateCreation() { return dateCreation; }
    public void setDateCreation(Timestamp dateCreation) { this.dateCreation = dateCreation; }

    @Override
    public String toString() {
        return String.format("Hotel{id=%d, nom='%s', ville='%s', prix=%.2f€, étoiles=%d}", 
            idHotel, nomHotel, ville, prixNuit, nombreEtoiles);
    }
}
