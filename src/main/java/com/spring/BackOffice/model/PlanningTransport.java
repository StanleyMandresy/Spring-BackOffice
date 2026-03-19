package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

public class PlanningTransport {

    private static class FenetreDisponibilite {
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
    private LocalDateTime heureRetour; // null sauf dernier client
 



    private int nombrePassagersTransportes;

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
        this.nombrePassagersTransportes=nombrePassagersTransportes;
    }

 

    // ==========================
    // GETTERS
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

    // ==========================
    // UTILE : véhicule libre ?
    // ==========================

    public boolean isTermine() {
        return heureRetour != null;
    }

    private static Map<Long, FenetreDisponibilite> chargerDisponibilitesVehicules(JdbcTemplate jdbcTemplate, LocalDate date) {
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
                "             heure_depart, heure_arrive, heure_retour, nombre_passagers_transportes)\n" +
                "            VALUES (?, ?, ?, ?, ?, ?,?)\n" +
                "        ";

        jdbcTemplate.update(
                sql,
                reservation != null ? reservation.getIdReservation() : null,
                vehicule.getId(),
                date,
                heureDepart,
                heureArrive,
                heureRetour,
                nombrePassagersTransportes
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

    // 🔹 disponibilité véhicules
    Map<Long, LocalDateTime> dispoVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        FenetreDisponibilite fenetre = fenetresDisponibilite.get(v.getId());
        if (fenetre != null) {
            dispoVehicule.put(v.getId(), fenetre.getDebut());
        }
    }

    // 🔹 nombre de trajets par véhicule
    Map<Long, Integer> nbTrajetsVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        nbTrajetsVehicule.put(v.getId(), 0);
    }

    // 🔹 tri initial par heure
    reservations.sort(Comparator.comparing(Reservation::getDateHeureArrive));

    Set<Long> traitees = new HashSet<>();
    int i = 0;

    while (i < reservations.size()) {

        Reservation base = reservations.get(i);
        if (traitees.contains(base.getIdReservation())) {
            i++;
            continue;
        }

        LocalDateTime debutFenetre = base.getDateHeureArrive().toLocalDateTime();
        LocalDateTime finFenetre = debutFenetre.plusMinutes(attenteMax);

        // 🔹 construire la fenêtre
        List<Reservation> fenetre = new ArrayList<>();
        for (Reservation r : reservations) {
            if (traitees.contains(r.getIdReservation())) continue;

            LocalDateTime t = r.getDateHeureArrive().toLocalDateTime();
            if (!t.isBefore(debutFenetre) && !t.isAfter(finFenetre)) {
                fenetre.add(r);
            }
        }

        // 🔥 TRI : uniquement par nombre de passagers DESC
        fenetre.sort((a, b) ->
                Integer.compare(b.getNombrePassagers(), a.getNombrePassagers())
        );

        boolean splitDansFenetre = false;

        // 🔥 TRAITEMENT
        for (Reservation principale : fenetre) {

            if (traitees.contains(principale.getIdReservation())) continue;

            int restant = principale.getNombrePassagers();

            // 🔹 véhicules disponibles
            List<Vehicule> vehiculesDispo = new ArrayList<>();
            for (Vehicule v : vehicules) {
                if (!dispoVehicule.get(v.getId())
                        .isAfter(principale.getDateHeureArrive().toLocalDateTime())) {
                    vehiculesDispo.add(v);
                }
            }

            // 🔹 tri véhicules (priorité logique existante)
            vehiculesDispo.sort((v1, v2) -> {
                int t1 = nbTrajetsVehicule.get(v1.getId());
                int t2 = nbTrajetsVehicule.get(v2.getId());

                if (t1 != t2) return Integer.compare(t1, t2);

                int capDiff = v2.getNbrPlace() - v1.getNbrPlace();
                if (capDiff != 0) return capDiff;

                boolean d1 = v1.getTypeCarburant().equals("D");
                boolean d2 = v2.getTypeCarburant().equals("D");

                return Boolean.compare(d2, d1);
            });

            if (vehiculesDispo.isEmpty()) continue;

            LocalDateTime heureDepart = principale.getDateHeureArrive().toLocalDateTime();
            Hotel positionDepart = aeroport;

            int nbVehiculesUtilises = 0;

            for (Vehicule v : vehiculesDispo) {

                if (restant <= 0) break;

                int pris = Math.min(restant, v.getNbrPlace());

                // 🔹 trajet aller
                Distance dist = Distance.findByHotels(
                        jdbcTemplate,
                        positionDepart.getIdHotel(),
                        principale.getIdHotel()
                );

                long duree = Math.round((dist.getDistanceKm().doubleValue() / vitesse) * 60);
                LocalDateTime arrive = heureDepart.plusMinutes(duree);

                // 🔹 retour
                Distance retourDist = Distance.findByHotels(
                        jdbcTemplate,
                        principale.getIdHotel(),
                        aeroport.getIdHotel()
                );

                long dureeRetour = Math.round((retourDist.getDistanceKm().doubleValue() / vitesse) * 60);
                LocalDateTime retour = arrive.plusMinutes(dureeRetour);

                // 🔥 création planning (SPLIT)
                PlanningTransport pt = new PlanningTransport(
                        principale,
                        v,
                        date,
                        heureDepart,
                        arrive,
                        retour
                );

                pt.setNombrePassagersTransportes(pris);
                pt.save(jdbcTemplate);

                // 🔹 update véhicule
                dispoVehicule.put(v.getId(), retour);
                nbTrajetsVehicule.put(v.getId(), nbTrajetsVehicule.get(v.getId()) + 1);

                restant -= pris;
                nbVehiculesUtilises++;
            }

            // 🔥 DETECTION SPLIT
            if (nbVehiculesUtilises > 1) {
                splitDansFenetre = true;
            }

            // 🔹 statut
            if (restant == 0) {
                Reservation.updateStatut(jdbcTemplate, principale.getIdReservation(), "planifie");
            } else {
                Reservation.updateStatut(jdbcTemplate, principale.getIdReservation(), "partiel");
            }

            traitees.add(principale.getIdReservation());

            // 🔥 SI SPLIT → on stop la fenêtre
            if (splitDansFenetre) {
                break;
            }
        }

        i++;
    }

    // 🔹 annuler non traitées
    for (Reservation r : reservations) {
        if (!traitees.contains(r.getIdReservation())) {
            Reservation.updateStatut(jdbcTemplate, r.getIdReservation(), "annule");
        }
    }
}

public static List<PlanningTransport> findByDate(JdbcTemplate jdbcTemplate, LocalDate date) {
    String sql = "SELECT pt.*, r.id_client, r.id_hotel, h.nom_hotel, r.nombre_passagers, r.commentaire, r.date_heure_arrive, h.nom_hotel, v.reference " +
                 "FROM planning_transport pt " +
                 "JOIN reservation r ON pt.id_reservation = r.id_reservation " +
                 "JOIN hotel h ON r.id_hotel = h.id_hotel " +
                 "JOIN vehicule v ON pt.id_vehicule = v.id " +
                 "WHERE pt.date_transport = ? " +
                 "ORDER BY v.reference, pt.heure_depart";
    return jdbcTemplate.query(sql, new Object[]{date}, new PlanningTransportRowMapper());
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
        v.setId(rs.getLong("id_vehicule"));       // <-- utiliser id_vehicule, pas pt.id
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
        pt.setId(rs.getLong("id")); // id du planning_transport

        return pt;
    }
}
}