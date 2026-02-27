package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

public class PlanningTransport {



    private Long id;

    private Reservation reservation;
    private Vehicule vehicule;
    private LocalDate date;

    private LocalDateTime heureDepart;
    private LocalDateTime heureArrive;
    private LocalDateTime heureRetour; // null sauf dernier client

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

    // ==========================
    // UTILE : véhicule libre ?
    // ==========================

    public boolean isTermine() {
        return heureRetour != null;
    }

     public void save(JdbcTemplate jdbcTemplate) {

        String sql = "INSERT INTO planning_transport\n" +
                "            (id_reservation, id_vehicule, date_transport,\n" +
                "             heure_depart, heure_arrive, heure_retour)\n" +
                "            VALUES (?, ?, ?, ?, ?, ?)\n" +
                "        ";

        jdbcTemplate.update(
                sql,
                reservation != null ? reservation.getIdReservation() : null,
                vehicule.getId(),
                date,
                heureDepart,
                heureArrive,
                heureRetour
        );
    }

public static void planifierTransports(JdbcTemplate jdbcTemplate, LocalDate date) {

    // 🔹 Récupérer toutes les réservations du jour
    List<Reservation> reservations = Reservation.findByDate(jdbcTemplate, date);

    // 🔹 Charger tous les véhicules
    List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);

    // 🔹 Paramètres
    Parametre param = Parametre.getLatest(jdbcTemplate);
    double vitesse = param.getVitesseKmh().doubleValue();

    Hotel aeroport = Hotel.findByNom(jdbcTemplate, "AEROPORT");

    // 🔹 Trier les réservations par nombre de passagers décroissant
    reservations.sort((r1, r2) -> Integer.compare(r2.getNombrePassagers(), r1.getNombrePassagers()));

    // 🔹 Carte pour suivre la disponibilité des véhicules
    Map<Long, LocalDateTime> dispoVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        dispoVehicule.put(v.getId(), LocalDateTime.of(date, java.time.LocalTime.MIN));
    }

    // 🔹 Boucle sur les véhicules
    for (Vehicule vehicule : vehicules) {

        int capaciteRestante = vehicule.getNbrPlace();
        List<Reservation> groupe = new ArrayList<>();

        // 🔹 Former le groupe en fonction de la capacité
        for (Reservation res : reservations) {

            if (PlanningTransport.reservationDejaPlanifiee(jdbcTemplate, res.getIdReservation())) continue;

            if (res.getNombrePassagers() <= capaciteRestante) {
                groupe.add(res);
                capaciteRestante -= res.getNombrePassagers();
                Reservation.updateStatut(jdbcTemplate,  res.getIdReservation(),  "planifie");
            }
        }

        if (groupe.isEmpty()) continue;

        // 🔹 Heure de départ = dernier client embarqué
        LocalDateTime heureDepart = groupe.stream()
            .map(res -> res.getDateHeureArrive().toLocalDateTime())
            .max(LocalDateTime::compareTo)
            .orElse(LocalDateTime.now());

        // 🔹 Trier le groupe par distance depuis l'aéroport
        groupe.sort((r1, r2) -> {
            Distance d1 = Distance.findByHotels(jdbcTemplate, aeroport.getIdHotel(), r1.getIdHotel());
            Distance d2 = Distance.findByHotels(jdbcTemplate, aeroport.getIdHotel(), r2.getIdHotel());
            return d1.getDistanceKm().compareTo(d2.getDistanceKm());
        });

        // 🔹 Boucle sur le groupe pour calculer heures et sauver planning
        LocalDateTime heureCourante = heureDepart;
        Hotel positionActuelle = aeroport;

        for (int i = 0; i < groupe.size(); i++) {
            Reservation res = groupe.get(i);

            Distance dist = Distance.findByHotels(jdbcTemplate, positionActuelle.getIdHotel(), res.getIdHotel());
            double km = dist.getDistanceKm().doubleValue();
            long duree = Math.round((km / vitesse) * 60);

            LocalDateTime heureArrive = heureCourante.plusMinutes(duree);
            LocalDateTime heureRetour = null;

            // 🔹 Si dernier client → retour à l'aéroport
            if (i == groupe.size() - 1) {
                Distance retour = Distance.findByHotels(jdbcTemplate, res.getIdHotel(), aeroport.getIdHotel());
                long dureeRetour = Math.round((retour.getDistanceKm().doubleValue() / vitesse) * 60);
                heureRetour = heureArrive.plusMinutes(dureeRetour);

                // 🕒 Mise à jour disponibilité véhicule
                dispoVehicule.put(vehicule.getId(), heureRetour);
            }

            PlanningTransport planning = new PlanningTransport(
                res,
                vehicule,
                date,
                heureCourante,
                heureArrive,
                heureRetour
            );

            planning.save(jdbcTemplate);

            // 🔹 Mise à jour position pour le client suivant
            heureCourante = heureArrive;
            positionActuelle = Hotel.findById(jdbcTemplate, res.getIdHotel());
        }
    }
}
public static List<PlanningTransport> findByDate(JdbcTemplate jdbcTemplate, LocalDate date) {
        String sql = "SELECT pt.*, r.id_client, r.id_hotel, r.nombre_passagers, r.commentaire, r.date_heure_arrive, h.nom_hotel, v.reference " +
                     "FROM planning_transport pt " +
                     "JOIN reservation r ON pt.id_reservation = r.id_reservation " +
                     "JOIN hotel h ON r.id_hotel = h.id_hotel " +
                     "JOIN vehicule v ON pt.id_vehicule = v.id " +
                     "WHERE pt.date_transport = ? " +
                     "ORDER BY pt.heure_depart";
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