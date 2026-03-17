package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
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

    List<Reservation> reservations = Reservation.findByDate(jdbcTemplate, date);
    List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);

    Parametre param = Parametre.getLatest(jdbcTemplate);
    double vitesse = param.getVitesseKmh().doubleValue();
    int attenteMax = param.getTempsAttenteMinute(); // fenêtre d'attente

    Hotel aeroport = Hotel.findByNom(jdbcTemplate, "AEROPORT");

    // 🔹 disponibilité véhicules
    Map<Long, LocalDateTime> dispoVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        dispoVehicule.put(v.getId(), LocalDateTime.of(date, LocalTime.MIN));
    }

    // 🔹 suivi nombre de trajets par véhicule
    Map<Long, Integer> nbTrajetsVehicule = new HashMap<>();
    for (Vehicule v : vehicules) {
        nbTrajetsVehicule.put(v.getId(), 0);
    }

    // 🔹 trier les réservations par heure d’arrivée
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

        // 🔹 construire la fenêtre de réservation à traiter
        List<Reservation> fenetre = new ArrayList<>();
        for (Reservation r : reservations) {
            if (traitees.contains(r.getIdReservation())) continue;
            LocalDateTime t = r.getDateHeureArrive().toLocalDateTime();
            if (!t.isBefore(debutFenetre) && !t.isAfter(finFenetre)) {
                fenetre.add(r);
            }
        }

        // 🔹 tri heure asc, puis passagers desc
        fenetre.sort((a, b) -> {
            int cmp = a.getDateHeureArrive().compareTo(b.getDateHeureArrive());
            if (cmp != 0) return cmp;
            return Integer.compare(b.getNombrePassagers(), a.getNombrePassagers());
        });

        // 🔹 traiter chaque réservation comme principale
        for (Reservation principale : fenetre) {

            if (traitees.contains(principale.getIdReservation())) continue;

            int passagers = principale.getNombrePassagers();

            // 🔹 choix du véhicule selon critères hiérarchiques
            Vehicule choisi = null;
            for (Vehicule v : vehicules) {

                if (dispoVehicule.get(v.getId())
                        .isAfter(principale.getDateHeureArrive().toLocalDateTime()))
                    continue;

                int diff = v.getNbrPlace() - passagers;
                if (diff < 0) continue; // capacité insuffisante

                if (choisi == null) {
                    choisi = v;
                    continue;
                }

                int trajetsV = nbTrajetsVehicule.get(v.getId());
                int trajetsChoisi = nbTrajetsVehicule.get(choisi.getId());
                int diffChoisi = choisi.getNbrPlace() - passagers;

                // 1️⃣ moins de trajets prioritaire
                if (trajetsV < trajetsChoisi) {
                    choisi = v;
                }
                // 2️⃣ si égalité → meilleur fit capacité
                else if (trajetsV == trajetsChoisi) {
                    if (diff < diffChoisi) {
                        choisi = v;
                    }
                    // 3️⃣ si encore égalité → diesel prioritaire
                    else if (diff == diffChoisi) {
                        boolean vDiesel = v.getTypeCarburant().equals("D");
                        boolean choisiDiesel = choisi.getTypeCarburant().equals("D");
                        if (vDiesel && !choisiDiesel) {
                            choisi = v;
                        }
                    }
                }
            }

            if (choisi == null) continue;

            int capaciteRestante = choisi.getNbrPlace();
            List<Reservation> groupe = new ArrayList<>();
            groupe.add(principale);
            capaciteRestante -= principale.getNombrePassagers();

            // 🔹 compléter le groupe avec les autres de la fenêtre
            for (Reservation r : fenetre) {
                if (r.getIdReservation() == principale.getIdReservation()) continue;
                if (traitees.contains(r.getIdReservation())) continue;

                if (r.getNombrePassagers() <= capaciteRestante) {
                    groupe.add(r);
                    capaciteRestante -= r.getNombrePassagers();
                }
            }

            // 🔹 heure départ = dernier du groupe
            LocalDateTime heureDepart = groupe.stream()
                    .map(r -> r.getDateHeureArrive().toLocalDateTime())
                    .max(LocalDateTime::compareTo)
                    .orElse(null);

            // 🔹 trier par distance depuis l'aéroport
            groupe.sort((r1, r2) -> {
                Distance d1 = Distance.findByHotels(jdbcTemplate, aeroport.getIdHotel(), r1.getIdHotel());
                Distance d2 = Distance.findByHotels(jdbcTemplate, aeroport.getIdHotel(), r2.getIdHotel());
                return d1.getDistanceKm().compareTo(d2.getDistanceKm());
            });

            LocalDateTime heureCourante = heureDepart;
            Hotel position = aeroport;

            for (int j = 0; j < groupe.size(); j++) {

                Reservation res = groupe.get(j);

                Distance dist = Distance.findByHotels(jdbcTemplate,
                        position.getIdHotel(),
                        res.getIdHotel());

                long duree = Math.round((dist.getDistanceKm().doubleValue() / vitesse) * 60);
                LocalDateTime arrive = heureCourante.plusMinutes(duree);

                LocalDateTime retour = null;

                if (j == groupe.size() - 1) {
                    Distance retourDist = Distance.findByHotels(jdbcTemplate,
                            res.getIdHotel(),
                            aeroport.getIdHotel());

                    long dureeRetour = Math.round((retourDist.getDistanceKm().doubleValue() / vitesse) * 60);
                    retour = arrive.plusMinutes(dureeRetour);

                    dispoVehicule.put(choisi.getId(), retour);

                    // 🔹 incrément nombre de trajets
                    nbTrajetsVehicule.put(
                            choisi.getId(),
                            nbTrajetsVehicule.get(choisi.getId()) + 1
                    );
                }

                PlanningTransport planning = new PlanningTransport(
                        res,
                        choisi,
                        date,
                        heureCourante,
                        arrive,
                        retour
                );
                planning.save(jdbcTemplate);
                Reservation.updateStatut(jdbcTemplate, res.getIdReservation(), "planifie");

                traitees.add(res.getIdReservation());

                heureCourante = arrive;
                position = Hotel.findById(jdbcTemplate, res.getIdHotel());
            }

            break; // un seul groupe traité par fenêtre
        }

        i++;
    }

    // 🔹 annuler les non planifiés
    for (Reservation r : reservations) {
        if (!PlanningTransport.reservationDejaPlanifiee(jdbcTemplate, r.getIdReservation())) {
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