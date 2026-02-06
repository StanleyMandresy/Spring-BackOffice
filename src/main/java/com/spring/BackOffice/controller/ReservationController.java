package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.ModelView;
import com.myframework.core.JsonResponse;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Hotel;
import com.spring.BackOffice.model.Reservation;

import org.springframework.jdbc.core.JdbcTemplate;

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
            System.err.println("⚠️ ATTENTION: JdbcTemplate est null dans ReservationController !");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    /**
     * GET /reservation/form - Afficher le formulaire de réservation
     */
    @GetMapping("/reservation/form")
    public ModelView showReservationForm() {
        ModelView mv = new ModelView();
        mv.setView("reservation-form.jsp");
        
        try {
            if (jdbcTemplate != null) {
                // Récupérer la liste des hôtels pour le menu déroulant
                List<Hotel> hotels = Hotel.findAll(jdbcTemplate);
                mv.addItem("hotels", hotels);
                System.out.println("✅ " + hotels.size() + " hôtels chargés pour le formulaire");
            } else {
                mv.addItem("error", "Base de données non disponible");
            }
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors du chargement des hôtels: " + e.getMessage());
        }
        
        return mv;
    }

    /**
     * POST /reservation/create - Créer une nouvelle réservation
     */
    @PostMapping("/reservation/create")
    public ModelView createReservation(
            @RequestParam("idClient") String idClient,
            @RequestParam("idHotel") String idHotelStr,
            @RequestParam("nombrePassagers") String nombrePassagersStr,
            @RequestParam("commentaire") String commentaire) {
        
        ModelView mv = new ModelView();
        mv.setView("reservation-confirmation.jsp");
        
        try {
            if (jdbcTemplate == null) {
                mv.addItem("error", "Base de données non disponible");
                return mv;
            }

            // Debug logs
            System.out.println("📥 Paramètres reçus:");
            System.out.println("  - idClient: " + idClient);
            System.out.println("  - idHotel: " + idHotelStr);
            System.out.println("  - nombrePassagers: " + nombrePassagersStr);
            System.out.println("  - commentaire: " + commentaire);

            // Conversion et validation
            if (idHotelStr == null || idHotelStr.trim().isEmpty()) {
                mv.addItem("error", "L'hôtel doit être sélectionné");
                return mv;
            }
            if (nombrePassagersStr == null || nombrePassagersStr.trim().isEmpty()) {
                mv.addItem("error", "Le nombre de passagers est obligatoire");
                return mv;
            }

            Long idHotel = Long.parseLong(idHotelStr);
            Integer nombrePassagers = Integer.parseInt(nombrePassagersStr);

            // Créer la réservation
            Reservation reservation = new Reservation(idClient, idHotel, nombrePassagers, commentaire);
            Long reservationId = reservation.save(jdbcTemplate);
            
            if (reservationId != null) {
                // Récupérer la réservation complète avec les infos de l'hôtel
                Reservation savedReservation = Reservation.findById(jdbcTemplate, reservationId);
                mv.addItem("reservation", savedReservation);
                mv.addItem("success", true);
                mv.addItem("message", "Réservation créée avec succès !");
                
                System.out.println("✅ Réservation créée: ID=" + reservationId);
            } else {
                mv.addItem("error", "Erreur lors de la création de la réservation");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors de la création de la réservation: " + e.getMessage());
        }
        
        return mv;
    }

    /**
     * GET /reservation/list - Lister toutes les réservations (JSON)
     */
    @RestAPI
    @GetMapping("/reservation/list")
    public JsonResponse listReservations() {
        try {
            if (jdbcTemplate == null) {
                Map<String, Object> errorData = new HashMap<>();
                errorData.put("error", "Base de données non disponible");
                return JsonResponse.error(500, errorData);
            }

            // Récupérer toutes les réservations
            List<Reservation> reservations = Reservation.findAll(jdbcTemplate);
            
            // Créer la réponse avec les métadonnées
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("reservations", reservations);
            responseData.put("total", reservations.size());
            responseData.put("message", "Liste des réservations récupérée avec succès");
            
            System.out.println("✅ " + reservations.size() + " réservations chargées (JSON)");
            return JsonResponse.success(responseData);
            
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorData = new HashMap<>();
            errorData.put("error", "Erreur lors du chargement des réservations: " + e.getMessage());
            return JsonResponse.error(500, errorData);
        }
    }
}
