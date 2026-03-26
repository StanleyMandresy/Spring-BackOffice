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

/**
 * Modèle pour représenter un événement véhicule
 * Types d'événements: DEPART, RETOUR, ATTENTE, REASSIGNATION
 */
public class EvenementVehicule {

    // Types d'événements constants
    public static final String TYPE_DEPART = "DEPART";
    public static final String TYPE_RETOUR = "RETOUR";
    public static final String TYPE_ATTENTE = "ATTENTE";
    public static final String TYPE_REASSIGNATION = "REASSIGNATION";

    private Long idEvenement;
    private Long idVehicule;
    private String typeEvenement;
    private Timestamp horodatage;
    private String details;
    private Long idPlanningTransport;

    // -------------------
    // Constructeurs
    // -------------------
    public EvenementVehicule() {
        this.horodatage = Timestamp.valueOf(LocalDateTime.now());
    }

    public EvenementVehicule(Long idVehicule, String typeEvenement, String details, Long idPlanningTransport) {
        this.idVehicule = idVehicule;
        this.typeEvenement = typeEvenement;
        this.details = details;
        this.idPlanningTransport = idPlanningTransport;
        this.horodatage = Timestamp.valueOf(LocalDateTime.now());
    }

    // -------------------
    // Méthodes CRUD
    // -------------------

    /**
     * Sauvegarder un événement en base
     */
    public Long save(JdbcTemplate jdbcTemplate) {
        if (idVehicule == null)
            throw new IllegalArgumentException("idVehicule requis");

        if (typeEvenement == null || !isValidTypeEvenement(typeEvenement))
            throw new IllegalArgumentException("typeEvenement invalide (DEPART, RETOUR, ATTENTE, REASSIGNATION)");

        String sql = "INSERT INTO evenements_vehicule (id_vehicule, type_evenement, horodatage, details, id_planning_transport) " +
                     "VALUES (?, ?, ?, ?, ?)";

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id_evenement"});
            ps.setLong(1, idVehicule);
            ps.setString(2, typeEvenement);
            ps.setTimestamp(3, horodatage);
            ps.setString(4, details);
            if (idPlanningTransport != null) {
                ps.setLong(5, idPlanningTransport);
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            return ps;
        }, keyHolder);

        Long generatedId = keyHolder.getKey() != null ? keyHolder.getKey().longValue() : null;
        if (generatedId != null) {
            this.idEvenement = generatedId;
        }
        return generatedId;
    }

    /**
     * Récupérer tous les événements
     */
    public static List<EvenementVehicule> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM evenements_vehicule ORDER BY horodatage DESC";
        return jdbcTemplate.query(sql, new EvenementVehiculeRowMapper());
    }

    /**
     * Récupérer un événement par ID
     */
    public static EvenementVehicule findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT * FROM evenements_vehicule WHERE id_evenement = ?";
        List<EvenementVehicule> list = jdbcTemplate.query(sql, new Object[]{id}, new EvenementVehiculeRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Récupérer les événements d'un véhicule spécifique
     */
    public static List<EvenementVehicule> findByVehicule(JdbcTemplate jdbcTemplate, Long idVehicule) {
        String sql = "SELECT * FROM evenements_vehicule WHERE id_vehicule = ? ORDER BY horodatage DESC";
        return jdbcTemplate.query(sql, new Object[]{idVehicule}, new EvenementVehiculeRowMapper());
    }

    /**
     * Récupérer les événements d'un véhicule dans une période
     */
    public static List<EvenementVehicule> findByVehiculeEtPeriode(
            JdbcTemplate jdbcTemplate, Long idVehicule, LocalDateTime debut, LocalDateTime fin) {
        String sql = "SELECT * FROM evenements_vehicule " +
                     "WHERE id_vehicule = ? AND horodatage BETWEEN ? AND ? " +
                     "ORDER BY horodatage DESC";
        return jdbcTemplate.query(sql,
                new Object[]{idVehicule, Timestamp.valueOf(debut), Timestamp.valueOf(fin)},
                new EvenementVehiculeRowMapper());
    }

    /**
     * Récupérer les événements par type
     */
    public static List<EvenementVehicule> findByType(JdbcTemplate jdbcTemplate, String typeEvenement) {
        String sql = "SELECT * FROM evenements_vehicule WHERE type_evenement = ? ORDER BY horodatage DESC";
        return jdbcTemplate.query(sql, new Object[]{typeEvenement}, new EvenementVehiculeRowMapper());
    }

    /**
     * Récupérer les événements récents (dernières N heures)
     */
    public static List<EvenementVehicule> findRecents(JdbcTemplate jdbcTemplate, int heures) {
        String sql = "SELECT * FROM evenements_vehicule " +
                     "WHERE horodatage >= NOW() - INTERVAL '" + heures + " hours' " +
                     "ORDER BY horodatage DESC";
        return jdbcTemplate.query(sql, new EvenementVehiculeRowMapper());
    }

    // -------------------
    // Méthodes de logging statiques (helpers)
    // -------------------

    /**
     * Logger un départ de véhicule
     */
    public static void logDepartVehicule(JdbcTemplate jdbcTemplate, Long idVehicule,
                                         LocalDateTime heureDepart, Long idPlanning) {
        try {
            String details = "Départ à " + heureDepart + " - Planning #" + idPlanning;
            EvenementVehicule event = new EvenementVehicule(idVehicule, TYPE_DEPART, details, idPlanning);
            event.save(jdbcTemplate);
            System.out.println("✅ Événement DEPART loggé - Véhicule #" + idVehicule);
        } catch (Exception e) {
            System.err.println("⚠️ Erreur logging événement DEPART: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Logger un retour de véhicule
     */
    public static void logRetourVehicule(JdbcTemplate jdbcTemplate, Long idVehicule,
                                         LocalDateTime heureRetour, Long idPlanning) {
        try {
            String details = "Retour à " + heureRetour + " - Planning #" + idPlanning;
            EvenementVehicule event = new EvenementVehicule(idVehicule, TYPE_RETOUR, details, idPlanning);
            event.save(jdbcTemplate);
            System.out.println("✅ Événement RETOUR loggé - Véhicule #" + idVehicule);
        } catch (Exception e) {
            System.err.println("⚠️ Erreur logging événement RETOUR: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Logger une attente de regroupement
     */
    public static void logAttenteRegroupement(JdbcTemplate jdbcTemplate, Long idVehicule,
                                              String raison) {
        try {
            String details = "Attente regroupement - " + raison;
            EvenementVehicule event = new EvenementVehicule(idVehicule, TYPE_ATTENTE, details, null);
            event.save(jdbcTemplate);
            System.out.println("⏳ Événement ATTENTE loggé - Véhicule #" + idVehicule);
        } catch (Exception e) {
            System.err.println("⚠️ Erreur logging événement ATTENTE: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Logger une réassignation dynamique
     */
    public static void logReassignationDynamique(JdbcTemplate jdbcTemplate, Long idVehicule,
                                                 int nombrePassagers, Long idPlanning) {
        try {
            String details = "Réassignation dynamique - " + nombrePassagers + " passagers - Planning #" + idPlanning;
            EvenementVehicule event = new EvenementVehicule(idVehicule, TYPE_REASSIGNATION, details, idPlanning);
            event.save(jdbcTemplate);
            System.out.println("🔄 Événement REASSIGNATION loggé - Véhicule #" + idVehicule);
        } catch (Exception e) {
            System.err.println("⚠️ Erreur logging événement REASSIGNATION: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Supprimer les événements anciens (nettoyage)
     */
    public static int deleteOlderThan(JdbcTemplate jdbcTemplate, int jours) {
        String sql = "DELETE FROM evenements_vehicule WHERE horodatage < NOW() - INTERVAL '" + jours + " days'";
        int deleted = jdbcTemplate.update(sql);
        System.out.println("🗑️ " + deleted + " événements supprimés (>" + jours + " jours)");
        return deleted;
    }

    // -------------------
    // Validation
    // -------------------

    private boolean isValidTypeEvenement(String type) {
        return TYPE_DEPART.equals(type) || TYPE_RETOUR.equals(type) ||
               TYPE_ATTENTE.equals(type) || TYPE_REASSIGNATION.equals(type);
    }

    // -------------------
    // RowMapper
    // -------------------
    private static class EvenementVehiculeRowMapper implements RowMapper<EvenementVehicule> {
        @Override
        public EvenementVehicule mapRow(ResultSet rs, int rowNum) throws SQLException {
            EvenementVehicule e = new EvenementVehicule();
            e.setIdEvenement(rs.getLong("id_evenement"));
            e.setIdVehicule(rs.getLong("id_vehicule"));
            e.setTypeEvenement(rs.getString("type_evenement"));
            e.setHorodatage(rs.getTimestamp("horodatage"));
            e.setDetails(rs.getString("details"));

            long idPlanning = rs.getLong("id_planning_transport");
            if (!rs.wasNull()) {
                e.setIdPlanningTransport(idPlanning);
            }

            return e;
        }
    }

    // -------------------
    // Getters & Setters
    // -------------------

    public Long getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Long idEvenement) { this.idEvenement = idEvenement; }

    public Long getIdVehicule() { return idVehicule; }
    public void setIdVehicule(Long idVehicule) { this.idVehicule = idVehicule; }

    public String getTypeEvenement() { return typeEvenement; }
    public void setTypeEvenement(String typeEvenement) { this.typeEvenement = typeEvenement; }

    public Timestamp getHorodatage() { return horodatage; }
    public void setHorodatage(Timestamp horodatage) { this.horodatage = horodatage; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public Long getIdPlanningTransport() { return idPlanningTransport; }
    public void setIdPlanningTransport(Long idPlanningTransport) { this.idPlanningTransport = idPlanningTransport; }

    @Override
    public String toString() {
        return "EvenementVehicule{" +
                "id=" + idEvenement +
                ", vehicule=" + idVehicule +
                ", type='" + typeEvenement + '\'' +
                ", horodatage=" + horodatage +
                ", details='" + details + '\'' +
                ", planning=" + idPlanningTransport +
                '}';
    }
}
