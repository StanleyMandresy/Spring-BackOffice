package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.ModelView;
import com.myframework.core.JsonResponse;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Hotel;
import com.spring.BackOffice.model.Reservation;

import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour gérer les réservations
 */
@Controller
public class ReservationController {

    private JdbcTemplate jdbcTemplate;

    public ReservationController() {
        this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        if (this.jdbcTemplate == null) {
            System.err.println("⚠️ JdbcTemplate null, reinitialisation...");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    /**
     * GET /reservation/form
     */
    @GetMapping("/reservation/form")
    public ModelView showReservationForm() {
        ModelView mv = new ModelView();
        mv.setView("reservation-form.jsp");

        try {
            List<Hotel> hotels = Hotel.findAll(jdbcTemplate);
            mv.addItem("hotels", hotels);
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors du chargement des hôtels");
        }

        return mv;
    }

    /**
     * POST /reservation/create
     */
    @PostMapping("/reservation/create")
    public ModelView createReservation(
            @RequestParam("idClient") String idClient,
            @RequestParam("idHotel") String idHotelStr,
            @RequestParam("nombrePassagers") String nombrePassagersStr,
            @RequestParam("commentaire") String commentaire,
            @RequestParam("dateArrivee") String dateArriveeStr,
            @RequestParam("heureArrivee") String heureArriveeStr) {

        ModelView mv = new ModelView();
        mv.setView("reservation-confirmation.jsp");

        try {
            if (jdbcTemplate == null) {
                mv.addItem("error", "Base de données non disponible");
                return mv;
            }

            // --------------------
            // Validations
            // --------------------
            Long idHotel = Long.parseLong(idHotelStr);
            Integer nombrePassagers = Integer.parseInt(nombrePassagersStr);

            if (dateArriveeStr == null || heureArriveeStr == null ||
                dateArriveeStr.isEmpty() || heureArriveeStr.isEmpty()) {
                mv.addItem("error", "Date et heure obligatoires");
                return mv;
            }

            // --------------------
            // Fusion date + heure
            // --------------------
            String dateTimeStr = dateArriveeStr + " " + heureArriveeStr + ":00";
            Timestamp dateHeureArrive = Timestamp.valueOf(dateTimeStr);

            // --------------------
            // Création réservation
            // --------------------
            Reservation reservation = new Reservation(
                    idClient,
                    idHotel,
                    nombrePassagers,
                    commentaire,
                    dateHeureArrive
            );

            Long reservationId = reservation.save(jdbcTemplate);

            if (reservationId != null) {
                Reservation saved = Reservation.findById(jdbcTemplate, reservationId);
                mv.addItem("reservation", saved);
                mv.addItem("success", true);
                mv.addItem("message", "Réservation créée avec succès");
            } else {
                mv.addItem("error", "Échec de la création de la réservation");
            }

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur : " + e.getMessage());
        }

        return mv;
    }

    /**
     * GET /reservation/list (JSON)
     */
    @RestAPI
    @GetMapping("/reservation/list")
    public JsonResponse listReservations() {
        try {
            List<Reservation> reservations = Reservation.findAll(jdbcTemplate);

            Map<String, Object> data = new HashMap<>();
            data.put("reservations", reservations);
            data.put("total", reservations.size());

            return JsonResponse.success(data);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorData = new HashMap<>();
            errorData.put("error", "Erreur chargement réservations");
            return JsonResponse.error(500, errorData);
        }
    }
}
