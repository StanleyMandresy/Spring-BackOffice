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
 * Modèle pour représenter un véhicule
 */
public class Vehicule {

    private Long id;
    private String reference;
    private Integer nbrPlace;
    private String typeCarburant; // D, ES, S, E

  

    // -------------------
    // Constructeurs
    // -------------------
    public Vehicule() {}

    public Vehicule(String reference, Integer nbrPlace, String typeCarburant) {
        this.reference = reference;
        this.nbrPlace = nbrPlace;
       setTypeCarburant(typeCarburant); 
    }

    // -------------------
    // Méthodes CRUD
    // -------------------

    /**
     * Récupérer tous les véhicules
     */
    public static List<Vehicule> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT id, reference, nbrPlace, type_carburant FROM vehicule ORDER BY id";
        return jdbcTemplate.query(sql, new VehiculeRowMapper());
    }

    /**
     * Récupérer un véhicule par ID
     */
    public static Vehicule findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT id, reference, nbrPlace, type_carburant FROM vehicule WHERE id = ?";
        List<Vehicule> list = jdbcTemplate.query(sql, new Object[]{id}, new VehiculeRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Récupérer les véhicules par type de carburant
     */
    public static List<Vehicule> findByTypeCarburant(JdbcTemplate jdbcTemplate, String typeCarburant) {
        String sql = "SELECT id, reference, nbrPlace, type_carburant FROM vehicule WHERE type_carburant = ? ORDER BY id";
        return jdbcTemplate.query(sql, new Object[]{typeCarburant}, new VehiculeRowMapper());
    }

    /**
     * Sauvegarder un véhicule
     */
    public Long save(JdbcTemplate jdbcTemplate) {

        if (reference == null || reference.isEmpty())
            throw new IllegalArgumentException("reference invalide");

        if (nbrPlace == null || nbrPlace <= 0)
            throw new IllegalArgumentException("nombre de places invalide");

        if (typeCarburant == null || !typeCarburant.matches("D|ES|S|E"))
            throw new IllegalArgumentException("type de carburant invalide (D, ES, S, E)");

        String sql = "INSERT INTO vehicule (reference, nbrPlace, type_carburant) VALUES (?, ?, ?)";

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    sql, new String[]{"id"});
            ps.setString(1, reference);
            ps.setInt(2, nbrPlace);
            ps.setString(3, typeCarburant);
            return ps;
        }, keyHolder);

        Long generatedId = keyHolder.getKey() != null ? keyHolder.getKey().longValue() : null;
        if (generatedId != null) {
            this.id = generatedId;
        }
        return generatedId;
    }

    /**
     * Mettre à jour un véhicule
     */
    public void update(JdbcTemplate jdbcTemplate) {
        if (id == null)
            throw new IllegalArgumentException("ID véhicule requis pour la mise à jour");

        if (reference == null || reference.isEmpty())
            throw new IllegalArgumentException("reference invalide");

        if (nbrPlace == null || nbrPlace <= 0)
            throw new IllegalArgumentException("nombre de places invalide");

        if (typeCarburant == null || !typeCarburant.matches("D|ES|S|E"))
            throw new IllegalArgumentException("type de carburant invalide (D, ES, S, E)");

        String sql = "UPDATE vehicule SET reference = ?, nbrPlace = ?, type_carburant = ? WHERE id = ?";
        jdbcTemplate.update(sql, reference, nbrPlace, typeCarburant, id);
    }

    /**
     * Supprimer un véhicule
     */
    public void delete(JdbcTemplate jdbcTemplate) {
        if (id == null)
            throw new IllegalArgumentException("ID véhicule requis pour la suppression");

        String sql = "DELETE FROM vehicule WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }

    /**
     * Supprimer un véhicule par ID (méthode statique)
     */
    public static void deleteById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "DELETE FROM vehicule WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }

    /**
     * Compter le nombre de véhicules
     */
    public static int count(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT COUNT(*) FROM vehicule";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }

    /**
     * Vérifier si un véhicule existe
     */
    public static boolean existsById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT COUNT(*) FROM vehicule WHERE id = ?";
        int count = jdbcTemplate.queryForObject(sql, Integer.class, id);
        return count > 0;
    }

    // -------------------
    // RowMapper
    // -------------------
    private static class VehiculeRowMapper implements RowMapper<Vehicule> {
        @Override
        public Vehicule mapRow(ResultSet rs, int rowNum) throws SQLException {
            Vehicule v = new Vehicule();
            v.setId(rs.getLong("id"));
            v.setReference(rs.getString("reference"));
            v.setNbrPlace(rs.getInt("nbrPlace"));
            String type = rs.getString("type_carburant");
            System.out.println("Type carburant récupéré = [" + type + "]");
            v.setTypeCarburant(type);
            return v;
        }
    }

    // -------------------
    // Getters & Setters
    // -------------------

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }

    public Integer getNbrPlace() { return nbrPlace; }
    public void setNbrPlace(Integer nbrPlace) { this.nbrPlace = nbrPlace; }

    public String getTypeCarburant() { return typeCarburant; }
    public void setTypeCarburant(String typeCarburant) { 
        if (typeCarburant != null && !typeCarburant.matches("D|ES|S|E")) {
            throw new IllegalArgumentException("Type de carburant invalide (D, ES, S, E)");
        }
        this.typeCarburant = typeCarburant; 
    }



    /**
     * Vérifie si le véhicule est libre pour une arrivée donnée.
     * <p>
     * La méthode interroge la table planning_transport pour s'assurer qu'il n'existe
     * pas de trajet planifié couvrant la date/heure demandée. Elle tient également
     * compte de l'attribut temporaire {@code disponibleA} utilisé lors de la
     * planification en mémoire.
     *
     * @param jdbcTemplate template JDBC pour l'accès à la base
     * @param dateHeureArrive date/heure d'arrivée à vérifier
     * @return {@code true} si aucun planning n'empêche l'utilisation du véhicule,
     *         {@code false} sinon
     */
    public boolean isDisponible(JdbcTemplate jdbcTemplate, Timestamp dateHeureArrive) {
        if (dateHeureArrive == null)
            throw new IllegalArgumentException("dateHeureArrive requise");

    

        if (this.id == null)
            return true; // pas encore persisté en base

        String sql = "SELECT COUNT(*) FROM planning_transport " +
                     "WHERE id_vehicule = ? AND ? BETWEEN heure_depart AND heure_retour";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, this.id, dateHeureArrive);
        return count == null || count == 0;
    }

    @Override
    public String toString() {
        return "Vehicule{" +
                "id=" + id +
                ", reference='" + reference + '\'' +
                ", nbrPlace=" + nbrPlace +
                ", typeCarburant='" + typeCarburant + '\'' +
                '}';
    }
}