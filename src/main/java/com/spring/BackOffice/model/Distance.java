package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

/**
 * Modèle représentant une distance entre deux hôtels
 */
public class Distance {

    private Long id;
    private Hotel fromDepart;
    private Hotel toArrive;
    private BigDecimal distanceKm;

    // Constructeurs
    public Distance() {}

    public Distance(Hotel fromDepart, Hotel toArrive, BigDecimal distanceKm) {
        this.fromDepart = fromDepart;
        this.toArrive = toArrive;
        this.distanceKm = distanceKm;
    }

    // -------------------
    // Méthodes statiques
    // -------------------

    public static List<Distance> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM distance";
        return jdbcTemplate.query(sql, new DistanceRowMapper(jdbcTemplate));
    }



    public static Distance findByHotels(JdbcTemplate jdbcTemplate, long fromHotelId, long toHotelId) {

        // 1️⃣ Récupérer toutes les distances (graphe)
        String sql = "SELECT from_depart, to_arrive, distance_km FROM distance";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql);

        // construire le graphe
        Map<Long, Map<Long, Double>> graphe = new HashMap<>();
        for (Map<String, Object> row : rows) {
            long from = ((Number) row.get("from_depart")).longValue();
            long to = ((Number) row.get("to_arrive")).longValue();
            double km = ((BigDecimal) row.get("distance_km")).doubleValue();

            graphe.computeIfAbsent(from, k -> new HashMap<>()).put(to, km);
        }

        // 2️⃣ Initialisation Dijkstra
        Set<Long> visited = new HashSet<>();
        Map<Long, Double> distances = new HashMap<>();
        for (Long hotelId : graphe.keySet()) distances.put(hotelId, Double.MAX_VALUE);
        distances.put(fromHotelId, 0.0);

        Map<Long, Long> previous = new HashMap<>(); // pour reconstruire le chemin
        PriorityQueue<long[]> queue = new PriorityQueue<>(Comparator.comparingDouble(a -> a[1]));
        queue.add(new long[]{fromHotelId, 0});

        // 3️⃣ Boucle principale
        while (!queue.isEmpty()) {
            long[] current = queue.poll();
            long currentHotel = current[0];
            double currentDist = current[1];

            if (!visited.add(currentHotel)) continue;

            if (currentHotel == toHotelId) break;

            Map<Long, Double> voisins = graphe.getOrDefault(currentHotel, Collections.emptyMap());
            for (Map.Entry<Long, Double> entry : voisins.entrySet()) {
                long voisin = entry.getKey();
                double km = entry.getValue();
                if (!visited.contains(voisin)) {
                    double newDist = currentDist + km;
                    if (newDist < distances.getOrDefault(voisin, Double.MAX_VALUE)) {
                        distances.put(voisin, newDist);
                        previous.put(voisin, currentHotel);
                        queue.add(new long[]{voisin, (long) newDist});
                    }
                }
            }
        }

        // 4️⃣ Vérifier si chemin trouvé
        if (!distances.containsKey(toHotelId) || distances.get(toHotelId) == Double.MAX_VALUE) {
            throw new RuntimeException("Aucun chemin trouvé entre " + fromHotelId + " et " + toHotelId);
        }

        // 5️⃣ Retourner un objet Distance “factice”
        Distance result = new Distance();
        result.setFromDepart(Hotel.findById(jdbcTemplate, fromHotelId));
        result.setToArrive(Hotel.findById(jdbcTemplate, toHotelId));
        result.setDistanceKm(BigDecimal.valueOf(distances.get(toHotelId)));

        return result;
    }


    public void save(JdbcTemplate jdbcTemplate) {
        String sql = "INSERT INTO distance (from_depart, to_arrive, distance_km) VALUES (?, ?, ?)";
        jdbcTemplate.update(sql,
                this.fromDepart.getIdHotel(),
                this.toArrive.getIdHotel(),
                this.distanceKm);
    }

    // -------------------
    // RowMapper
    // -------------------

    private static class DistanceRowMapper implements RowMapper<Distance> {

        private final JdbcTemplate jdbcTemplate;

        public DistanceRowMapper(JdbcTemplate jdbcTemplate) {
            this.jdbcTemplate = jdbcTemplate;
        }

        @Override
        public Distance mapRow(ResultSet rs, int rowNum) throws SQLException {

            Hotel from = Hotel.findById(jdbcTemplate, rs.getLong("from_depart"));
            Hotel to = Hotel.findById(jdbcTemplate, rs.getLong("to_arrive"));

            Distance d = new Distance();
            d.setId(rs.getLong("id"));
            d.setFromDepart(from);
            d.setToArrive(to);
            d.setDistanceKm(rs.getBigDecimal("distance_km"));

            return d;
        }
    }

    // -------------------
    // Getters / Setters
    // -------------------

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Hotel getFromDepart() { return fromDepart; }
    public void setFromDepart(Hotel fromDepart) { this.fromDepart = fromDepart; }

    public Hotel getToArrive() { return toArrive; }
    public void setToArrive(Hotel toArrive) { this.toArrive = toArrive; }

    public BigDecimal getDistanceKm() { return distanceKm; }
    public void setDistanceKm(BigDecimal distanceKm) { this.distanceKm = distanceKm; }

    @Override
    public String toString() {
        return "Distance{id=" + id +
                ", from=" + fromDepart.getNomHotel() +
                ", to=" + toArrive.getNomHotel() +
                ", km=" + distanceKm + "}";
    }

}
