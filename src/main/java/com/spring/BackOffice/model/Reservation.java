package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Modèle pour représenter une réservation
 */
public class Reservation {
    
    private Long idReservation;
    private String idClient;
    private Long idHotel;
    private Integer nombrePassagers;
    private String statut; // 'en_attente', 'planifiee', 'en_cours', 'terminee', 'annulee'
    private String commentaire;
    private Timestamp dateCreation;
    private Timestamp dateModification;
    
    // Champs additionnels pour affichage (jointure)
    private String nomHotel;

    // Constructeurs
    public Reservation() {}

    public Reservation(String idClient, Long idHotel, Integer nombrePassagers, String commentaire) {
        this.idClient = idClient;
        this.idHotel = idHotel;
        this.nombrePassagers = nombrePassagers;
        this.commentaire = commentaire;
        this.statut = "en_attente"; // Statut par défaut
    }

    // -------------------
    // Méthodes statiques avec JdbcTemplate
    // -------------------
    
    /**
     * Récupérer toutes les réservations
     */
    public static List<Reservation> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT r.*, h.nom_hotel FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "ORDER BY r.date_creation DESC";
        return jdbcTemplate.query(sql, new ReservationRowMapper());
    }

    /**
     * Récupérer les réservations d'un client
     */
    public static List<Reservation> findByClient(JdbcTemplate jdbcTemplate, String idClient) {
        String sql = "SELECT r.*, h.nom_hotel FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "WHERE r.id_client = ? " +
                     "ORDER BY r.date_creation DESC";
        return jdbcTemplate.query(sql, new Object[]{idClient}, new ReservationRowMapper());
    }

    /**
     * Récupérer une réservation par ID
     */
    public static Reservation findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT r.*, h.nom_hotel FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "WHERE r.id_reservation = ?";
        List<Reservation> reservations = jdbcTemplate.query(sql, new Object[]{id}, new ReservationRowMapper());
        return reservations.isEmpty() ? null : reservations.get(0);
    }

    /**
     * Sauvegarder une nouvelle réservation
     */
    public Long save(JdbcTemplate jdbcTemplate) {
        if (this.idHotel == null) {
            throw new IllegalArgumentException("idHotel ne peut pas être null");
        }
        if (this.idClient == null || this.idClient.trim().isEmpty()) {
            throw new IllegalArgumentException("idClient ne peut pas être vide");
        }
        if (this.nombrePassagers == null || this.nombrePassagers <= 0) {
            throw new IllegalArgumentException("nombrePassagers doit être supérieur à 0");
        }
        
        String sql = "INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, commentaire) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        KeyHolder keyHolder = new GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id_reservation"});
            ps.setString(1, this.idClient);
            ps.setLong(2, this.idHotel);
            ps.setInt(3, this.nombrePassagers);
            ps.setString(4, this.statut != null ? this.statut : "en_attente");
            ps.setString(5, this.commentaire);
            return ps;
        }, keyHolder);
        
        return keyHolder.getKey() != null ? keyHolder.getKey().longValue() : null;
    }

    /**
     * Mettre à jour le statut d'une réservation
     */
    public static void updateStatut(JdbcTemplate jdbcTemplate, Long idReservation, String nouveauStatut) {
        String sql = "UPDATE reservation SET statut = ?, date_modification = CURRENT_TIMESTAMP WHERE id_reservation = ?";
        jdbcTemplate.update(sql, nouveauStatut, idReservation);
    }

    // -------------------
    // RowMapper pour JdbcTemplate
    // -------------------
    private static class ReservationRowMapper implements RowMapper<Reservation> {
        @Override
        public Reservation mapRow(ResultSet rs, int rowNum) throws SQLException {
            Reservation reservation = new Reservation();
            reservation.setIdReservation(rs.getLong("id_reservation"));
            reservation.setIdClient(rs.getString("id_client"));
            reservation.setIdHotel(rs.getLong("id_hotel"));
            reservation.setNombrePassagers(rs.getInt("nombre_passagers"));
            reservation.setStatut(rs.getString("statut"));
            reservation.setCommentaire(rs.getString("commentaire"));
            reservation.setDateCreation(rs.getTimestamp("date_creation"));
            reservation.setDateModification(rs.getTimestamp("date_modification"));
            
            // Champ de la jointure
            try {
                reservation.setNomHotel(rs.getString("nom_hotel"));
            } catch (SQLException e) {
                // Pas de jointure, on ignore
            }
            
            return reservation;
        }
    }

    // -------------------
    // Getters et setters
    // -------------------
    public Long getIdReservation() { return idReservation; }
    public void setIdReservation(Long idReservation) { this.idReservation = idReservation; }

    public String getIdClient() { return idClient; }
    public void setIdClient(String idClient) { this.idClient = idClient; }

    public Long getIdHotel() { return idHotel; }
    public void setIdHotel(Long idHotel) { this.idHotel = idHotel; }

    public Integer getNombrePassagers() { return nombrePassagers; }
    public void setNombrePassagers(Integer nombrePassagers) { this.nombrePassagers = nombrePassagers; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getCommentaire() { return commentaire; }
    public void setCommentaire(String commentaire) { this.commentaire = commentaire; }

    public Timestamp getDateCreation() { return dateCreation; }
    public void setDateCreation(Timestamp dateCreation) { this.dateCreation = dateCreation; }

    public Timestamp getDateModification() { return dateModification; }
    public void setDateModification(Timestamp dateModification) { this.dateModification = dateModification; }

    public String getNomHotel() { return nomHotel; }
    public void setNomHotel(String nomHotel) { this.nomHotel = nomHotel; }

    @Override
    public String toString() {
        return String.format("Reservation{id=%d, client='%s', hotel=%d, passagers=%d, statut='%s'}", 
            idReservation, idClient, idHotel, nombrePassagers, statut);
    }
}
