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
    private LocalDateTime heureRetour;
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

    // ==========================
    // UTILE : véhicule libre ?
    // ==========================
    public boolean isTermine() {
        return heureRetour != null;
    }

    private static LocalDateTime getDebutFenetre(LocalDateTime dateTime, int tAMinutes) {
        int splitMinutes = dateTime.getHour() * 60 + dateTime.getMinute();
        int tranche = splitMinutes / tAMinutes;
        int minuteDebut = tranche * tAMinutes;
        return dateTime.toLocalDate().atStartOfDay().plusMinutes(minuteDebut);
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
                "            VALUES (?, ?, ?, ?, ?, ?,?)\n";

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

    Map<Long, LocalDateTime> dispoVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        FenetreDisponibilite f = fenetresDisponibilite.get(v.getId());
        if (f != null) dispoVehicule.put(v.getId(), f.getDebut());
    }

    Map<Long, Integer> nbTrajetsVehicule = new HashMap<>();
    for (Vehicule v : vehicules) nbTrajetsVehicule.put(v.getId(), 0);

    // 🔥 TreeMap pour traiter les fenêtres dans l'ordre chronologique
    TreeMap<LocalDateTime, List<Reservation>> reservationsParFenetre = new TreeMap<>();

    // Trier par heure d'arrivée
    reservations.sort((a, b) -> a.getDateHeureArrive().compareTo(b.getDateHeureArrive()));

    for (Reservation r : reservations) {
        LocalDateTime heure = r.getDateHeureArrive().toLocalDateTime();
        LocalDateTime fenetre = getFenetreFixe(heure, attenteMax);
        reservationsParFenetre.computeIfAbsent(fenetre, k -> new ArrayList<>()).add(r);
    }

    Map<Long, Integer> restantMap = new HashMap<>();
    for (Reservation r : reservations) {
        restantMap.put(r.getIdReservation(), r.getNombrePassagers());
    }

    Set<Long> traitees = new HashSet<>();

    // 🔥 Traiter fenêtre par fenêtre dans l'ordre chronologique
    // On utilise une copie des clés car on peut ajouter des fenêtres dynamiquement
    while (!reservationsParFenetre.isEmpty()) {

        LocalDateTime clesFenetre = reservationsParFenetre.firstKey();
        List<Reservation> resasFenetre = reservationsParFenetre.remove(clesFenetre);

        // Garder uniquement les réservations avec des passagers restants
        resasFenetre.removeIf(r -> restantMap.get(r.getIdReservation()) <= 0);
        if (resasFenetre.isEmpty()) continue;

        // Trier gros groupes d'abord
        resasFenetre.sort((a, b) -> Integer.compare(b.getNombrePassagers(), a.getNombrePassagers()));

        // 🔥 Calculer heureDepart = max(arrivées clients, dispos véhicules) dans cette fenêtre
        LocalDateTime maxDepart = resasFenetre.stream()
                .map(r -> r.getDateHeureArrive().toLocalDateTime())
                .max(LocalDateTime::compareTo)
                .orElse(clesFenetre);

        for (Vehicule v : vehicules) {
            FenetreDisponibilite fenetreDispo = fenetresDisponibilite.get(v.getId());
            if (fenetreDispo == null) continue;

            LocalDateTime dispo = dispoVehicule.get(v.getId());
            if (dispo == null) continue;
            if (dispo.isAfter(fenetreDispo.getFin())) continue;

            // Véhicule dispo dans cette fenêtre ?
            LocalDateTime fenetreVehicule = getFenetreFixe(dispo, attenteMax);
            if (!fenetreVehicule.equals(clesFenetre)) continue;

            if (dispo.isAfter(maxDepart)) {
                maxDepart = dispo;
            }
        }

        final LocalDateTime heureDepart = maxDepart;

        for (Reservation principale : resasFenetre) {

            int restant = restantMap.get(principale.getIdReservation());
            if (restant <= 0) continue;

            // Véhicules disponibles à l'heure de départ de cette fenêtre
            List<Vehicule> vehiculesDispo = new ArrayList<>();
            for (Vehicule v : vehicules) {
                FenetreDisponibilite fenetreDispo = fenetresDisponibilite.get(v.getId());
                if (fenetreDispo == null) continue;

                LocalDateTime dispo = dispoVehicule.get(v.getId());
                if (dispo == null) continue;
                if (dispo.isAfter(fenetreDispo.getFin())) continue;
                if (dispo.isAfter(heureDepart)) continue;

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

                // BEST-FIT
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

                int pris = Math.min(restant, vehiculeChoisi.getNbrPlace());

                allocateToVehicule(
                        principale, vehiculeChoisi, pris,
                        date, heureDepart, positionDepart, aeroport, vitesse, jdbcTemplate,
                        dispoVehicule, nbTrajetsVehicule
                );

                restant -= pris;
                restantMap.put(principale.getIdReservation(), restant);

                int placesLibres = vehiculeChoisi.getNbrPlace() - pris;

                // 🔥 REMPLISSAGE avec autres réservations de la même fenêtre
                if (placesLibres > 0) {

                    List<Reservation> candidats = new ArrayList<>();
                    for (Reservation autre : resasFenetre) {
                        if (autre.getIdReservation() == principale.getIdReservation()) continue;
                        int restantAutre = restantMap.get(autre.getIdReservation());
                        if (restantAutre <= 0) continue;
                        candidats.add(autre);
                    }

                    final int placesRef = placesLibres;
                    candidats.sort((a, b) -> {
                        int rA = restantMap.get(a.getIdReservation());
                        int rB = restantMap.get(b.getIdReservation());
                        return Integer.compare(Math.abs(placesRef - rA), Math.abs(placesRef - rB));
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

            // 🔥 Si encore des passagers restants → reporter dans la fenêtre suivante
            int restantFinal = restantMap.get(principale.getIdReservation());
            if (restantFinal > 0) {
                LocalDateTime prochaineFenetre = clesFenetre.plusMinutes(attenteMax);
                reservationsParFenetre
                        .computeIfAbsent(prochaineFenetre, k -> new ArrayList<>())
                        .add(principale);
                Reservation.updateStatut(jdbcTemplate, principale.getIdReservation(), "partiel");
            } else {
                Reservation.updateStatut(jdbcTemplate, principale.getIdReservation(), "planifie");
                traitees.add(principale.getIdReservation());
            }
        }
    }

    // 🔥 Annuler les réservations encore non complètes
    for (Reservation r : reservations) {
        if (restantMap.get(r.getIdReservation()) > 0) {
            Reservation.updateStatut(jdbcTemplate, r.getIdReservation(), "annule");
        }
    }
}   
 // HELPER METHOD: Alloue une réservation à un véhicule avec calcul de trajets
    private static void allocateToVehicule(
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
private static LocalDateTime getFenetreFixe(LocalDateTime heure, int attenteMax) {
    int minutes = heure.getMinute();

    int bucket = (minutes / attenteMax) * attenteMax;

    return heure.withMinute(bucket).withSecond(0).withNano(0);
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
                            : null,
                    rs.getInt("nombre_passagers_transportes")
                    
            );
            pt.setId(rs.getLong("id"));

            return pt;
        }
    }
}