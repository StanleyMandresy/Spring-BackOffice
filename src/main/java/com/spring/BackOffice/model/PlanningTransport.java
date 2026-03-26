package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

public class PlanningTransport {

    // SPRINT 8: Rendu public pour réutilisation par PlanificationDynamique
    public static class FenetreDisponibilite {
        private final LocalDateTime debut;
        private final LocalDateTime fin;

        FenetreDisponibilite(LocalDateTime debut, LocalDateTime fin) {
            this.debut = debut;
            this.fin = fin;
        }

        public LocalDateTime getDebut() {
            return debut;
        }

        public LocalDateTime getFin() {
            return fin;
        }
    }

    private Long id;
    private Reservation reservation;
    private Vehicule vehicule;
    private LocalDate date;
    private LocalDateTime heureDepart;
    private LocalDateTime heureArrive;
    private LocalDateTime heureRetour;
    private int nombrePassagersTransportes;
    private String typeRegroupement = "PLANIFIE";  // SPRINT 8: PLANIFIE ou DYNAMIQUE

    public PlanningTransport(
            Reservation reservation,
            Vehicule vehicule,
            LocalDate date,
            LocalDateTime heureDepart,
            LocalDateTime heureArrive,
            LocalDateTime heureRetour) {

        this.reservation = reservation;
        this.vehicule = vehicule;
        this.date = date;
        this.heureDepart = heureDepart;
        this.heureArrive = heureArrive;
        this.heureRetour = heureRetour;
    }

    public PlanningTransport(
            Reservation reservation,
            Vehicule vehicule,
            LocalDate date,
            LocalDateTime heureDepart,
            LocalDateTime heureArrive,
            LocalDateTime heureRetour,
            int nombrePassagersTransportes) {

        this.reservation = reservation;
        this.vehicule = vehicule;
        this.date = date;
        this.heureDepart = heureDepart;
        this.heureArrive = heureArrive;
        this.heureRetour = heureRetour;
        this.nombrePassagersTransportes = nombrePassagersTransportes;
    }

    // ==========================
    // GETTERS & SETTERS
    // ==========================
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Reservation getReservation() {
        return reservation;
    }

    public Vehicule getVehicule() {
        return vehicule;
    }

    public LocalDate getDate() {
        return date;
    }

    public LocalDateTime getHeureDepart() {
        return heureDepart;
    }

    public LocalDateTime getHeureArrive() {
        return heureArrive;
    }

    public LocalDateTime getHeureRetour() {
        return heureRetour;
    }

    public int getNombrePassagersTransportes() {
        return nombrePassagersTransportes;
    }

    public void setNombrePassagersTransportes(int nombrePassagersTransportes) {
        this.nombrePassagersTransportes = nombrePassagersTransportes;
    }

    // SPRINT 8: Getter/Setter pour type de regroupement
    public String getTypeRegroupement() {
        return typeRegroupement;
    }

    public void setTypeRegroupement(String typeRegroupement) {
        this.typeRegroupement = typeRegroupement;
    }

    // ==========================
    // UTILE : véhicule libre ?
    // ==========================
    public boolean isTermine() {
        return heureRetour != null;
    }

    // SPRINT 8: Rendu public pour réutilisation par PlanificationDynamique
    public static Map<Long, FenetreDisponibilite> chargerDisponibilitesVehicules(JdbcTemplate jdbcTemplate, LocalDate date) {
        String sql = "SELECT id_vehicule, date_heure_disponible_debut, date_heure_disponible_fin " +
                     "FROM voiture_disponible " +
                     "WHERE date_heure_disponible_debut::date <= ? AND date_heure_disponible_fin::date >= ?";

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, date, date);

        Map<Long, FenetreDisponibilite> disponibilites = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Long idVehicule = ((Number) row.get("id_vehicule")).longValue();
            java.sql.Timestamp debutTs = (java.sql.Timestamp) row.get("date_heure_disponible_debut");
            java.sql.Timestamp finTs = (java.sql.Timestamp) row.get("date_heure_disponible_fin");

            if (debutTs == null || finTs == null) {
                continue;
            }

            LocalDateTime debut = debutTs.toLocalDateTime();
            LocalDateTime fin = finTs.toLocalDateTime();

            FenetreDisponibilite existante = disponibilites.get(idVehicule);
            if (existante == null) {
                disponibilites.put(idVehicule, new FenetreDisponibilite(debut, fin));
            } else {
                LocalDateTime nouveauDebut = debut.isBefore(existante.getDebut()) ? debut : existante.getDebut();
                LocalDateTime nouveauFin = fin.isAfter(existante.getFin()) ? fin : existante.getFin();
                disponibilites.put(idVehicule, new FenetreDisponibilite(nouveauDebut, nouveauFin));
            }
        }

        return disponibilites;
    }

    public void save(JdbcTemplate jdbcTemplate) {
        String sql = "INSERT INTO planning_transport\n" +
                "            (id_reservation, id_vehicule, date_transport,\n" +
                "             heure_depart, heure_arrive, heure_retour, nombre_passagers_transportes, type_regroupement)\n" +
                "            VALUES (?, ?, ?, ?, ?, ?, ?, ?)\n";

        jdbcTemplate.update(
                sql,
                reservation != null ? reservation.getIdReservation() : null,
                vehicule.getId(),
                date,
                heureDepart,
                heureArrive,
                heureRetour,
                nombrePassagersTransportes,
                typeRegroupement
        );
    }

public static void planifierTransports(JdbcTemplate jdbcTemplate, LocalDate date) {

    List<Reservation> reservations = Reservation.findByDate(jdbcTemplate, date);
    List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);

    Parametre param = Parametre.getLatest(jdbcTemplate);
    double vitesse = param.getVitesseKmh().doubleValue();
    int attenteMax = param.getTempsAttenteMinute();

    Hotel aeroport = Hotel.findByNom(jdbcTemplate, "AEROPORT");

    Map<Long, FenetreDisponibilite> fenetresDisponibilite = chargerDisponibilitesVehicules(jdbcTemplate, date);

    Map<Long, LocalDateTime> dispoVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        FenetreDisponibilite fenetre = fenetresDisponibilite.get(v.getId());
        if (fenetre != null) {
            dispoVehicule.put(v.getId(), fenetre.getDebut());
        }
    }

    Map<Long, Integer> nbTrajetsVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        nbTrajetsVehicule.put(v.getId(), 0);
    }

    // 🔥 Suivi des passagers restants
    Map<Long, Integer> restantMap = new HashMap<>();
    for (Reservation r : reservations) {
        restantMap.put(r.getIdReservation(), r.getNombrePassagers());
    }

    // Tri gros groupes d'abord
    reservations.sort((a, b) ->
            Integer.compare(b.getNombrePassagers(), a.getNombrePassagers())
    );

    Set<Long> traitees = new HashSet<>();

    for (Reservation principale : reservations) {

        int restant = restantMap.get(principale.getIdReservation());
        if (restant <= 0) continue;

        List<Vehicule> vehiculesDispo = new ArrayList<>();

        for (Vehicule v : vehicules) {
            FenetreDisponibilite fenetreDispo = fenetresDisponibilite.get(v.getId());
            if (fenetreDispo == null) continue;

            LocalDateTime dispo = dispoVehicule.get(v.getId());
            if (dispo.isAfter(fenetreDispo.getFin())) continue;

            vehiculesDispo.add(v);
        }

        vehiculesDispo.sort((v1, v2) -> {
            int t1 = nbTrajetsVehicule.get(v1.getId());
            int t2 = nbTrajetsVehicule.get(v2.getId());

            if (t1 != t2) return Integer.compare(t1, t2);

            return Integer.compare(v2.getNbrPlace(), v1.getNbrPlace());
        });

        Hotel positionDepart = aeroport;

        while (restant > 0 && !vehiculesDispo.isEmpty()) {

            Vehicule vehiculeChoisi = null;

            // 🔥 BEST-FIT
            int meilleureCapacite = Integer.MAX_VALUE;
            for (Vehicule v : vehiculesDispo) {
                if (v.getNbrPlace() >= restant && v.getNbrPlace() < meilleureCapacite) {
                    vehiculeChoisi = v;
                    meilleureCapacite = v.getNbrPlace();
                }
            }

            if (vehiculeChoisi == null) {
                for (Vehicule v : vehiculesDispo) {
                    if (vehiculeChoisi == null || v.getNbrPlace() > vehiculeChoisi.getNbrPlace()) {
                        vehiculeChoisi = v;
                    }
                }
            }

            LocalDateTime dispo = dispoVehicule.get(vehiculeChoisi.getId());
            LocalDateTime arriveeClient = principale.getDateHeureArrive().toLocalDateTime();

            LocalDateTime heureBase = dispo.isAfter(arriveeClient) ? dispo : arriveeClient;

            // 🔥 ATTENTE INTELLIGENTE
            LocalDateTime meilleureHeure = heureBase;
            int meilleurRemplissage = Math.min(restant, vehiculeChoisi.getNbrPlace());

            for (Reservation autre : reservations) {

                if (autre.getIdReservation() == principale.getIdReservation())
                    continue;

                int restantAutre = restantMap.get(autre.getIdReservation());
                if (restantAutre <= 0) continue;

                LocalDateTime heureAutre = autre.getDateHeureArrive().toLocalDateTime();

                long diff = Duration.between(heureBase, heureAutre).toMinutes();

                if (diff > 0 && diff <= attenteMax) {

                    int potentiel = Math.min(
                            vehiculeChoisi.getNbrPlace(),
                            restant + restantAutre
                    );

                    if (potentiel > meilleurRemplissage) {
                        meilleurRemplissage = potentiel;
                        meilleureHeure = heureAutre;
                    }
                }
            }

            LocalDateTime heureDepart = meilleureHeure;

            int pris = Math.min(restant, vehiculeChoisi.getNbrPlace());

            allocateToVehicule(
                    principale, vehiculeChoisi, pris,
                    date, heureDepart, positionDepart, aeroport, vitesse, jdbcTemplate,
                    dispoVehicule, nbTrajetsVehicule
            );

            restant -= pris;
            restantMap.put(principale.getIdReservation(), restant);

            int placesLibres = vehiculeChoisi.getNbrPlace() - pris;

            // 🔥 REMPLISSAGE
            if (placesLibres > 0) {

                List<Reservation> candidats = new ArrayList<>();

                for (Reservation autre : reservations) {

                    if (autre.getIdReservation() == principale.getIdReservation())
                        continue;

                    int restantAutre = restantMap.get(autre.getIdReservation());
                    if (restantAutre <= 0) continue;

                    LocalDateTime heureAutre = autre.getDateHeureArrive().toLocalDateTime();

                    long diff = Math.abs(Duration.between(heureDepart, heureAutre).toMinutes());

                    if (diff > attenteMax) continue;

                    candidats.add(autre);
                }

                final int placesRef = placesLibres;

                candidats.sort((a, b) -> {
                    int rA = restantMap.get(a.getIdReservation());
                    int rB = restantMap.get(b.getIdReservation());

                    return Integer.compare(
                            Math.abs(placesRef - rA),
                            Math.abs(placesRef - rB)
                    );
                });

                for (Reservation autre : candidats) {

                    int restantAutre = restantMap.get(autre.getIdReservation());
                    if (restantAutre <= 0) continue;

                    int aPrendre = Math.min(placesLibres, restantAutre);

                    allocateToVehicule(
                            autre, vehiculeChoisi, aPrendre,
                            date, heureDepart, positionDepart, aeroport, vitesse, jdbcTemplate,
                            dispoVehicule, nbTrajetsVehicule
                    );

                    restantAutre -= aPrendre;
                    restantMap.put(autre.getIdReservation(), restantAutre);

                    placesLibres -= aPrendre;

                    if (restantAutre == 0) {
                        Reservation.updateStatut(jdbcTemplate, autre.getIdReservation(), "planifie");
                        traitees.add(autre.getIdReservation());
                    } else {
                        Reservation.updateStatut(jdbcTemplate, autre.getIdReservation(), "partiel");
                    }

                    if (placesLibres == 0) break;
                }
            }

            vehiculesDispo.remove(vehiculeChoisi);
        }

        if (restant == 0) {
            Reservation.updateStatut(jdbcTemplate, principale.getIdReservation(), "planifie");
        } else {
            Reservation.updateStatut(jdbcTemplate, principale.getIdReservation(), "partiel");
        }

        traitees.add(principale.getIdReservation());
    }

    for (Reservation r : reservations) {
        if (restantMap.get(r.getIdReservation()) > 0) {
            Reservation.updateStatut(jdbcTemplate, r.getIdReservation(), "annule");
        }
    }
}
    // HELPER METHOD: Alloue une réservation à un véhicule avec calcul de trajets
    // SPRINT 8: Rendu public pour réutilisation par PlanificationDynamique
    public static void allocateToVehicule(
            Reservation principale,
            Vehicule vehicule,
            int nombrePassagers,
            LocalDate date,
            LocalDateTime heureDepart,
            Hotel positionDepart,
            Hotel aeroport,
            double vitesse,
            JdbcTemplate jdbcTemplate,
            Map<Long, LocalDateTime> dispoVehicule,
            Map<Long, Integer> nbTrajetsVehicule) {

        // trajet aller
        Distance dist = Distance.findByHotels(
                jdbcTemplate,
                positionDepart.getIdHotel(),
                principale.getIdHotel()
        );

        long duree = Math.round((dist.getDistanceKm().doubleValue() / vitesse) * 60);
        LocalDateTime arrive = heureDepart.plusMinutes(duree);

        // retour
        Distance retourDist = Distance.findByHotels(
                jdbcTemplate,
                principale.getIdHotel(),
                aeroport.getIdHotel()
        );

        long dureeRetour = Math.round((retourDist.getDistanceKm().doubleValue() / vitesse) * 60);
        LocalDateTime retour = arrive.plusMinutes(dureeRetour);

        // création planning
        PlanningTransport pt = new PlanningTransport(
                principale,
                vehicule,
                date,
                heureDepart,
                arrive,
                retour
        );

        pt.setNombrePassagersTransportes(nombrePassagers);
        pt.save(jdbcTemplate);

        // update véhicule
        dispoVehicule.put(vehicule.getId(), retour);
        nbTrajetsVehicule.put(vehicule.getId(), nbTrajetsVehicule.get(vehicule.getId()) + 1);
    }

    public static List<PlanningTransport> findByDate(JdbcTemplate jdbcTemplate, LocalDate date) {
        String sql = "SELECT pt.*, r.id_client, r.id_hotel, h.nom_hotel, r.nombre_passagers, r.commentaire, r.date_heure_arrive, v.reference " +
                     "FROM planning_transport pt " +
                     "JOIN reservation r ON pt.id_reservation = r.id_reservation " +
                     "JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "JOIN vehicule v ON pt.id_vehicule = v.id " +
                     "WHERE pt.date_transport = ? " +
                     "ORDER BY v.reference, pt.heure_depart";
        return jdbcTemplate.query(sql, new Object[]{date}, new PlanningTransportRowMapper());
    }

    /**
     * SPRINT 8: Trouve les trajets terminés pour une date donnée
     * (véhicules qui devraient être revenus avant l'heure actuelle)
     */
    public static List<PlanningTransport> findTrajetsTerminesPourDate(
            JdbcTemplate jdbcTemplate, LocalDate date, LocalDateTime maintenant) {
        String sql = "SELECT pt.*, r.id_client, r.id_hotel, h.nom_hotel, r.nombre_passagers, r.commentaire, r.date_heure_arrive, v.reference " +
                     "FROM planning_transport pt " +
                     "JOIN reservation r ON pt.id_reservation = r.id_reservation " +
                     "JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "JOIN vehicule v ON pt.id_vehicule = v.id " +
                     "WHERE pt.date_transport = ? " +
                     "AND pt.heure_retour <= ? " +
                     "ORDER BY pt.heure_retour";
        return jdbcTemplate.query(sql, new Object[]{date, maintenant}, new PlanningTransportRowMapper());
    }

    public static boolean reservationDejaPlanifiee(JdbcTemplate jdbcTemplate, Long idReservation) {
        String sql = "SELECT COUNT(*) FROM planning_transport WHERE id_reservation = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, idReservation);
        return count != null && count > 0;
    }

    private static class PlanningTransportRowMapper implements RowMapper<PlanningTransport> {
        @Override
        public PlanningTransport mapRow(ResultSet rs, int rowNum) throws SQLException {
            // Réservation
            Reservation r = new Reservation();
            r.setIdReservation(rs.getLong("id_reservation"));
            r.setIdClient(rs.getString("id_client"));
            r.setIdHotel(rs.getLong("id_hotel"));
            r.setNombrePassagers(rs.getInt("nombre_passagers"));
            r.setCommentaire(rs.getString("commentaire"));
            r.setDateHeureArrive(rs.getTimestamp("date_heure_arrive"));

            // Véhicule
            Vehicule v = new Vehicule();
            v.setId(rs.getLong("id_vehicule"));
            v.setReference(rs.getString("reference"));

            // Transport
            PlanningTransport pt = new PlanningTransport(
                    r,
                    v,
                    rs.getDate("date_transport").toLocalDate(),
                    rs.getTimestamp("heure_depart").toLocalDateTime(),
                    rs.getTimestamp("heure_arrive").toLocalDateTime(),
                    rs.getTimestamp("heure_retour") != null
                            ? rs.getTimestamp("heure_retour").toLocalDateTime()
                            : null
            );
            pt.setId(rs.getLong("id"));

            // SPRINT 8: Lecture des nouveaux champs
            try {
                pt.setNombrePassagersTransportes(rs.getInt("nombre_passagers_transportes"));
            } catch (SQLException ignored) {
                // Colonne peut ne pas exister dans anciennes données
            }

            try {
                String typeReg = rs.getString("type_regroupement");
                if (typeReg != null) {
                    pt.setTypeRegroupement(typeReg);
                }
            } catch (SQLException ignored) {
                // Colonne peut ne pas exister dans anciennes données
            }

            return pt;
        }
    }
}