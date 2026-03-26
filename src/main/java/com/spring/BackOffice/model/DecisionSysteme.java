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
 * Modèle pour représenter une décision du système de planification dynamique
 * Types de décision: DEPART_IMMEDIAT, ATTENTE_REGROUPEMENT, AUCUNE_ACTION
 */
public class DecisionSysteme {

    // Types de décisions constants
    public static final String DEPART_IMMEDIAT = "DEPART_IMMEDIAT";
    public static final String ATTENTE_REGROUPEMENT = "ATTENTE_REGROUPEMENT";
    public static final String AUCUNE_ACTION = "AUCUNE_ACTION";

    private Long idDecision;
    private Timestamp timestamp;
    private String contexte;  // JSON ou texte structuré
    private String decisionPrise;
    private String resultat;  // JSON ou texte structuré
    private Long idVehicule;

    // -------------------
    // Constructeurs
    // -------------------
    public DecisionSysteme() {
        this.timestamp = Timestamp.valueOf(LocalDateTime.now());
    }

    public DecisionSysteme(String contexte, String decisionPrise, String resultat, Long idVehicule) {
        this.contexte = contexte;
        this.decisionPrise = decisionPrise;
        this.resultat = resultat;
        this.idVehicule = idVehicule;
        this.timestamp = Timestamp.valueOf(LocalDateTime.now());
    }

    // -------------------
    // Méthodes CRUD
    // -------------------

    /**
     * Sauvegarder une décision en base
     */
    public Long save(JdbcTemplate jdbcTemplate) {
        if (contexte == null || contexte.isEmpty())
            throw new IllegalArgumentException("contexte requis");

        if (decisionPrise == null || !isValidDecision(decisionPrise))
            throw new IllegalArgumentException("decisionPrise invalide (DEPART_IMMEDIAT, ATTENTE_REGROUPEMENT, AUCUNE_ACTION)");

        String sql = "INSERT INTO decisions_systeme (timestamp, contexte, decision_prise, resultat, id_vehicule) " +
                     "VALUES (?, ?, ?, ?, ?)";

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id_decision"});
            ps.setTimestamp(1, timestamp);
            ps.setString(2, contexte);
            ps.setString(3, decisionPrise);
            ps.setString(4, resultat);
            if (idVehicule != null) {
                ps.setLong(5, idVehicule);
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            return ps;
        }, keyHolder);

        Long generatedId = keyHolder.getKey() != null ? keyHolder.getKey().longValue() : null;
        if (generatedId != null) {
            this.idDecision = generatedId;
        }
        return generatedId;
    }

    /**
     * Récupérer toutes les décisions
     */
    public static List<DecisionSysteme> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM decisions_systeme ORDER BY timestamp DESC";
        return jdbcTemplate.query(sql, new DecisionSystemeRowMapper());
    }

    /**
     * Récupérer une décision par ID
     */
    public static DecisionSysteme findById(JdbcTemplate jdbcTemplate, Long id) {
        String sql = "SELECT * FROM decisions_systeme WHERE id_decision = ?";
        List<DecisionSysteme> list = jdbcTemplate.query(sql, new Object[]{id}, new DecisionSystemeRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Récupérer les décisions d'un véhicule spécifique
     */
    public static List<DecisionSysteme> findByVehicule(JdbcTemplate jdbcTemplate, Long idVehicule) {
        String sql = "SELECT * FROM decisions_systeme WHERE id_vehicule = ? ORDER BY timestamp DESC";
        return jdbcTemplate.query(sql, new Object[]{idVehicule}, new DecisionSystemeRowMapper());
    }

    /**
     * Récupérer les décisions dans une période
     */
    public static List<DecisionSysteme> findByPeriode(
            JdbcTemplate jdbcTemplate, LocalDateTime debut, LocalDateTime fin) {
        String sql = "SELECT * FROM decisions_systeme " +
                     "WHERE timestamp BETWEEN ? AND ? " +
                     "ORDER BY timestamp DESC";
        return jdbcTemplate.query(sql,
                new Object[]{Timestamp.valueOf(debut), Timestamp.valueOf(fin)},
                new DecisionSystemeRowMapper());
    }

    /**
     * Récupérer les N décisions les plus récentes
     */
    public static List<DecisionSysteme> findRecent(JdbcTemplate jdbcTemplate, int limit) {
        String sql = "SELECT * FROM decisions_systeme ORDER BY timestamp DESC LIMIT ?";
        return jdbcTemplate.query(sql, new Object[]{limit}, new DecisionSystemeRowMapper());
    }

    /**
     * Récupérer les décisions par type
     */
    public static List<DecisionSysteme> findByTypeDecision(JdbcTemplate jdbcTemplate, String typeDecision) {
        String sql = "SELECT * FROM decisions_systeme WHERE decision_prise = ? ORDER BY timestamp DESC";
        return jdbcTemplate.query(sql, new Object[]{typeDecision}, new DecisionSystemeRowMapper());
    }

    // -------------------
    // Méthode de logging statique (helper)
    // -------------------

    /**
     * Logger une décision du système
     * @param contexte Contexte de la décision (état système, réservations en attente, etc.)
     * @param decisionPrise Type de décision (DEPART_IMMEDIAT, ATTENTE_REGROUPEMENT, AUCUNE_ACTION)
     * @param resultat Résultat de la décision (passagers transportés, efficacité, etc.)
     * @param idVehicule ID du véhicule concerné
     */
    public static void logDecision(JdbcTemplate jdbcTemplate, String contexte,
                                   String decisionPrise, String resultat, Long idVehicule) {
        try {
            DecisionSysteme decision = new DecisionSysteme(contexte, decisionPrise, resultat, idVehicule);
            decision.save(jdbcTemplate);

            String emoji = decisionPrise.equals(DEPART_IMMEDIAT) ? "🚀" :
                          decisionPrise.equals(ATTENTE_REGROUPEMENT) ? "⏳" : "⏸️";
            System.out.println(emoji + " Décision loggée: " + decisionPrise + " - Véhicule #" + idVehicule);
        } catch (Exception e) {
            System.err.println("⚠️ Erreur logging décision: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Compter les décisions par type sur une période
     */
    public static long countByTypeAndPeriode(JdbcTemplate jdbcTemplate, String typeDecision,
                                            LocalDateTime debut, LocalDateTime fin) {
        String sql = "SELECT COUNT(*) FROM decisions_systeme " +
                     "WHERE decision_prise = ? AND timestamp BETWEEN ? AND ?";
        return jdbcTemplate.queryForObject(sql,
                new Object[]{typeDecision, Timestamp.valueOf(debut), Timestamp.valueOf(fin)},
                Long.class);
    }

    /**
     * Obtenir les statistiques de décisions sur une période
     */
    public static String getStatistiques(JdbcTemplate jdbcTemplate, LocalDateTime debut, LocalDateTime fin) {
        long totalDecisions = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM decisions_systeme WHERE timestamp BETWEEN ? AND ?",
                new Object[]{Timestamp.valueOf(debut), Timestamp.valueOf(fin)},
                Long.class);

        long departImmediats = countByTypeAndPeriode(jdbcTemplate, DEPART_IMMEDIAT, debut, fin);
        long attentes = countByTypeAndPeriode(jdbcTemplate, ATTENTE_REGROUPEMENT, debut, fin);
        long aucuneActions = countByTypeAndPeriode(jdbcTemplate, AUCUNE_ACTION, debut, fin);

        StringBuilder stats = new StringBuilder();
        stats.append("📊 Statistiques décisions (").append(debut.toLocalDate()).append(" - ").append(fin.toLocalDate()).append("):\n");
        stats.append("  Total: ").append(totalDecisions).append("\n");
        stats.append("  🚀 Départs immédiats: ").append(departImmediats)
             .append(" (").append(totalDecisions > 0 ? (departImmediats * 100 / totalDecisions) : 0).append("%)\n");
        stats.append("  ⏳ Attentes regroupement: ").append(attentes)
             .append(" (").append(totalDecisions > 0 ? (attentes * 100 / totalDecisions) : 0).append("%)\n");
        stats.append("  ⏸️ Aucune action: ").append(aucuneActions)
             .append(" (").append(totalDecisions > 0 ? (aucuneActions * 100 / totalDecisions) : 0).append("%)");

        return stats.toString();
    }

    /**
     * Supprimer les décisions anciennes (nettoyage)
     */
    public static int deleteOlderThan(JdbcTemplate jdbcTemplate, int jours) {
        String sql = "DELETE FROM decisions_systeme WHERE timestamp < NOW() - INTERVAL '" + jours + " days'";
        int deleted = jdbcTemplate.update(sql);
        System.out.println("🗑️ " + deleted + " décisions supprimées (>" + jours + " jours)");
        return deleted;
    }

    // -------------------
    // Validation
    // -------------------

    private boolean isValidDecision(String decision) {
        return DEPART_IMMEDIAT.equals(decision) || ATTENTE_REGROUPEMENT.equals(decision) ||
               AUCUNE_ACTION.equals(decision);
    }

    // -------------------
    // RowMapper
    // -------------------
    private static class DecisionSystemeRowMapper implements RowMapper<DecisionSysteme> {
        @Override
        public DecisionSysteme mapRow(ResultSet rs, int rowNum) throws SQLException {
            DecisionSysteme d = new DecisionSysteme();
            d.setIdDecision(rs.getLong("id_decision"));
            d.setTimestamp(rs.getTimestamp("timestamp"));
            d.setContexte(rs.getString("contexte"));
            d.setDecisionPrise(rs.getString("decision_prise"));
            d.setResultat(rs.getString("resultat"));

            long idVehicule = rs.getLong("id_vehicule");
            if (!rs.wasNull()) {
                d.setIdVehicule(idVehicule);
            }

            return d;
        }
    }

    // -------------------
    // Getters & Setters
    // -------------------

    public Long getIdDecision() { return idDecision; }
    public void setIdDecision(Long idDecision) { this.idDecision = idDecision; }

    public Timestamp getTimestamp() { return timestamp; }
    public void setTimestamp(Timestamp timestamp) { this.timestamp = timestamp; }

    public String getContexte() { return contexte; }
    public void setContexte(String contexte) { this.contexte = contexte; }

    public String getDecisionPrise() { return decisionPrise; }
    public void setDecisionPrise(String decisionPrise) { this.decisionPrise = decisionPrise; }

    public String getResultat() { return resultat; }
    public void setResultat(String resultat) { this.resultat = resultat; }

    public Long getIdVehicule() { return idVehicule; }
    public void setIdVehicule(Long idVehicule) { this.idVehicule = idVehicule; }

    @Override
    public String toString() {
        return "DecisionSysteme{" +
                "id=" + idDecision +
                ", timestamp=" + timestamp +
                ", decision='" + decisionPrise + '\'' +
                ", vehicule=" + idVehicule +
                ", contexte='" + (contexte != null && contexte.length() > 50 ? contexte.substring(0, 50) + "..." : contexte) + '\'' +
                '}';
    }
}
