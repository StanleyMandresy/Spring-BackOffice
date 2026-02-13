package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.ModelView;
import com.myframework.core.JsonResponse;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Hotel;
import com.spring.BackOffice.model.Reservation;
import com.spring.BackOffice.model.Token;

import org.springframework.jdbc.core.JdbcTemplate;

import jakarta.servlet.http.HttpServletRequest;
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
     * Vérifier le token d'API depuis le header Authorization ou paramètre ?token=
     * Retourne null si valide, sinon retourne une JsonResponse d'erreur
     */
    private JsonResponse verifierToken(HttpServletRequest request, String tokenParam) {
        // Essayer de récupérer le token depuis le header Authorization
        String authHeader = request.getHeader("Authorization");
        String tokenValue = null;
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            tokenValue = authHeader.substring(7);
        } else if (tokenParam != null && !tokenParam.trim().isEmpty()) {
            // Sinon utiliser le paramètre ?token=
            tokenValue = tokenParam;
        }
        
        if (tokenValue == null || tokenValue.trim().isEmpty()) {
            Map<String, Object> errorData = new HashMap<>();
            errorData.put("error", "Token d'API requis. Utilisez 'Authorization: Bearer <token>' ou '?token=<token>'");
            return JsonResponse.error(401, errorData);
        }
        
        // Vérifier la validité du token
        if (!Token.isTokenValide(jdbcTemplate, tokenValue)) {
            Map<String, Object> errorData = new HashMap<>();
            errorData.put("error", "Token invalide ou expiré");
            return JsonResponse.error(401, errorData);
        }
        
        return null; // Token valide
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
     * GET /reservation/list - Lister toutes les réservations (Token API requis)
     * 
     * Test curl avec Authorization header:
     * curl "http://localhost:8080/sprint0/reservation/list" -H "Authorization: Bearer <votre_token>"
     * 
     * Test curl avec paramètre:
     * curl "http://localhost:8080/sprint0/reservation/list?token=<votre_token>"
     */
    @RestAPI
    @GetMapping("/reservation/list")
    public JsonResponse listReservations(HttpServletRequest request,
                                        @RequestParam("token") String token) {
        try {
            // Vérifier le token d'API
            JsonResponse tokenError = verifierToken(request, token);
            if (tokenError != null) {
                return tokenError; // Token invalide ou manquant
            }

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
