package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.*;

/**
 * Modèle pour représenter une réservation
 */
public class Reservation {

    private Long idReservation;
    private String idClient;
    private Long idHotel;
    private Integer nombrePassagers;
    private String statut; // en_attente, planifiee, en_cours, terminee, annulee
    private String commentaire;

    // 👉 UNE SEULE DATE/HEURE
    private Timestamp dateHeureArrive;

    private Timestamp dateCreation;
    private Timestamp dateModification;

    // Champs jointure
    private String nomHotel;

    // -------------------
    // Constructeurs
    // -------------------
    public Reservation() {}

    public Reservation(String idClient, Long idHotel, Integer nombrePassagers,
                       String commentaire, Timestamp dateHeureArrive) {
        this.idClient = idClient;
        this.idHotel = idHotel;
        this.nombrePassagers = nombrePassagers;
        this.commentaire = commentaire;
        this.dateHeureArrive = dateHeureArrive;
        this.statut = "en_attente";
    }

    // -------------------
    // Méthodes JDBC
    // -------------------

    /**
     * Récupérer toutes les réservations
     */
    public static List<Reservation> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT r.*, h.nom_hotel " +
                     "FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "ORDER BY r.date_creation DESC";
        return jdbcTemplate.query(sql, new ReservationRowMapper());
    }

    /**
     * Récupérer les réservations d'un client
     */
    public static List<Reservation> findByClient(JdbcTemplate jdbcTemplate, String idClient) {
        String sql = "SELECT r.*, h.nom_hotel " +
                     "FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "WHERE r.id_client = ? " +
                     "ORDER BY r.date_creation DESC";
        return jdbcTemplate.query(sql, new Object[]{idClient}, new ReservationRowMapper());
    }

    /**
     * Récupérer une réservation par ID
     */
    public static Reservation findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT r.*, h.nom_hotel " +
                     "FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "WHERE r.id_reservation = ?";
        List<Reservation> list = jdbcTemplate.query(sql, new Object[]{id}, new ReservationRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Sauvegarder une réservation
     */
    public Long save(JdbcTemplate jdbcTemplate) {

        if (idClient == null || idClient.isEmpty())
            throw new IllegalArgumentException("idClient invalide");

        if (idHotel == null)
            throw new IllegalArgumentException("idHotel ne peut pas être null");

        if (nombrePassagers == null || nombrePassagers <= 0)
            throw new IllegalArgumentException("nombrePassagers invalide");

        if (dateHeureArrive == null)
            throw new IllegalArgumentException("dateHeureArrive obligatoire");

        String sql = "INSERT INTO reservation (id_client, id_hotel, nombre_passagers, statut, commentaire, date_heure_arrive) VALUES (?, ?, ?, ?, ?, ?)";

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    sql, new String[]{"id_reservation"});
            ps.setString(1, idClient);
            ps.setLong(2, idHotel);
            ps.setInt(3, nombrePassagers);
            ps.setString(4, statut);
            ps.setString(5, commentaire);
            ps.setTimestamp(6, dateHeureArrive);
            return ps;
        }, keyHolder);

        return keyHolder.getKey() != null ? keyHolder.getKey().longValue() : null;
    }

    /**
     * Mettre à jour le statut
     */
    public static void updateStatut(JdbcTemplate jdbcTemplate, Long idReservation, String nouveauStatut) {
        String sql = "UPDATE reservation SET statut = ?, date_modification = CURRENT_TIMESTAMP WHERE id_reservation = ?";
        jdbcTemplate.update(sql, nouveauStatut, idReservation);
    }

    public static List<Reservation> findByDate(JdbcTemplate jdbcTemplate, LocalDate date) {
        String sql = "SELECT r.*, h.nom_hotel " +
                     "FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "WHERE DATE(r.date_heure_arrive) = ? ";
        List<Reservation> list = jdbcTemplate.query(sql, new Object[]{date}, new ReservationRowMapper());
        return list.isEmpty() ? null : list;
    }

     public static List<Reservation> findByDateAnnuleList(JdbcTemplate jdbcTemplate, LocalDate date) {
        String sql = "SELECT r.*, h.nom_hotel " +
                     "FROM reservation r " +
                     "LEFT JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "WHERE DATE(r.date_heure_arrive) = ? AND r.statut = 'annule'";
        List<Reservation> list = jdbcTemplate.query(sql, new Object[]{date}, new ReservationRowMapper());
        return list.isEmpty() ? null : list;
    }
    
    

    // -------------------
    // RowMapper
    // -------------------
    private static class ReservationRowMapper implements RowMapper<Reservation> {
        @Override
        public Reservation mapRow(ResultSet rs, int rowNum) throws SQLException {
            Reservation r = new Reservation();
            r.setIdReservation(rs.getLong("id_reservation"));
            r.setIdClient(rs.getString("id_client"));
            r.setIdHotel(rs.getLong("id_hotel"));
            r.setNombrePassagers(rs.getInt("nombre_passagers"));
            r.setStatut(rs.getString("statut"));
            r.setCommentaire(rs.getString("commentaire"));
            r.setDateHeureArrive(rs.getTimestamp("date_heure_arrive"));
            r.setDateCreation(rs.getTimestamp("date_creation"));
            r.setDateModification(rs.getTimestamp("date_modification"));

            try {
                r.setNomHotel(rs.getString("nom_hotel"));
            } catch (SQLException ignored) {}

            return r;
        }
    }

    // -------------------
    // Getters & Setters
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

    public Timestamp getDateHeureArrive() { return dateHeureArrive; }
    public void setDateHeureArrive(Timestamp dateHeureArrive) { this.dateHeureArrive = dateHeureArrive; }

    public Timestamp getDateCreation() { return dateCreation; }
    public void setDateCreation(Timestamp dateCreation) { this.dateCreation = dateCreation; }

    public Timestamp getDateModification() { return dateModification; }
    public void setDateModification(Timestamp dateModification) { this.dateModification = dateModification; }

    public String getNomHotel() { return nomHotel; }
    public void setNomHotel(String nomHotel) { this.nomHotel = nomHotel; }

    @Override
    public String toString() {
        return "Reservation{" +
                "id=" + idReservation +
                ", client='" + idClient + '\'' +
                ", hotel=" + idHotel +
                ", passagers=" + nombrePassagers +
                ", statut='" + statut + '\'' +
                ", dateHeureArrive=" + dateHeureArrive +
                '}';
    }
}
