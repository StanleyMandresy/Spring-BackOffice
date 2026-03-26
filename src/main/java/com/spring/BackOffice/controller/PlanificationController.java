package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.ModelView;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.*;

import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Controller
public class PlanificationController {

    private JdbcTemplate jdbcTemplate;

    public PlanificationController() {
        this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        if (this.jdbcTemplate == null) {
            System.err.println("⚠️ JdbcTemplate null, réinitialisation...");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    /**
     * GET /planification
     * Afficher le formulaire de planification
     */
    @GetMapping("/planification")
    public ModelView showPlanificationForm() {
        ModelView mv = new ModelView();
        mv.setView("Planification/planification-form.jsp");
        return mv;
    }

    /**
     * POST /planification/planifier
     * Planifie les transports pour la date choisie
     */
    @PostMapping("/planification/planifier")
    public ModelView planifierTransports(@RequestParam("date") String date) {
        ModelView mv = new ModelView();

        try {
            LocalDate datePlan = LocalDate.parse(date); // "2026-02-05"

            PlanningTransport.planifierTransports(jdbcTemplate, datePlan);
            List<Reservation> annuleList = Reservation.findByDateAnnuleList(jdbcTemplate, datePlan);
           

            // Après planification, afficher le planning pour la date
            List<PlanningTransport> planningList = PlanningTransport.findByDate(jdbcTemplate, datePlan);
          
            mv.addItem("date", datePlan);
            mv.addItem("planningList", planningList);
            mv.addItem("annuleList", annuleList);
            mv.setView("Planification/planification-details.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors de la planification : " + e.getMessage());
            mv.setView("Planification/planification-form.jsp");
        }

        return mv;
    }

    // ========================================
   // SPRINT 8 : Endpoints de planification dynamique
    // ========================================

    /**
     * POST /planification/retour-vehicule
     * Déclencher l'optimisation dynamique au retour d'un véhicule
     */
    @PostMapping("/planification/retour-vehicule")
    public ModelView traiterRetourVehicule(
            @RequestParam("idVehicule") Long idVehicule,
            @RequestParam("date") String dateStr,
            @RequestParam("heureRetour") String heureRetourStr) {

        ModelView mv = new ModelView();

        try {
            LocalDate date = LocalDate.parse(dateStr);
            LocalDateTime heureRetour = LocalDateTime.parse(heureRetourStr);

            // Appeler le service de planification dynamique
            PlanificationDynamique.optimiserApresRetourVehicule(
                jdbcTemplate, idVehicule, date, heureRetour
            );

            // Retourner le planning mis à jour
            List<PlanningTransport> planningList = PlanningTransport.findByDate(jdbcTemplate, date);
            List<Reservation> reservationsEnAttente =
                Reservation.findNonAssigneesAvecPriorite(jdbcTemplate, date);

            mv.addItem("date", date);
            mv.addItem("planningList", planningList);
            mv.addItem("reservationsEnAttente", reservationsEnAttente);
            mv.addItem("success", "Optimisation dynamique effectuée pour véhicule #" + idVehicule);
            mv.setView("Planification/planification-details.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors de l'optimisation: " + e.getMessage());
            mv.setView("Planification/planification-form.jsp");
        }

        return mv;
    }

    /**
     * POST /planification/optimisation-continue
     * Optimiser tous les véhicules qui devraient être revenus
      */
    @PostMapping("/planification/optimisation-continue")
    public ModelView optimisationContinue(@RequestParam("date") String dateStr) {
        ModelView mv = new ModelView();

        try {
            LocalDate date = LocalDate.parse(dateStr);
            LocalDateTime maintenant = LocalDateTime.now();

            // Trouver tous les véhicules qui devraient être revenus
            List<PlanningTransport> trajetsTermines =
                PlanningTransport.findTrajetsTerminesPourDate(jdbcTemplate, date, maintenant);

            int countOptimisations = 0;

            for (PlanningTransport trajet : trajetsTermines) {
                try {
                    PlanificationDynamique.optimiserApresRetourVehicule(
                        jdbcTemplate,
                        trajet.getVehicule().getId(),
                        date,
                        trajet.getHeureRetour()
                    );
                    countOptimisations++;
                } catch (Exception e) {
                    System.err.println("Erreur optimisation véhicule #" +
                                     trajet.getVehicule().getId() + ": " + e.getMessage());
                }
            }

            // Retourner les résultats
            List<PlanningTransport> planningList = PlanningTransport.findByDate(jdbcTemplate, date);
            List<Reservation> reservationsEnAttente =
                Reservation.findNonAssigneesAvecPriorite(jdbcTemplate, date);

            mv.addItem("date", date);
            mv.addItem("planningList", planningList);
            mv.addItem("reservationsEnAttente", reservationsEnAttente);
            mv.addItem("success", countOptimisations + " optimisation(s) effectuée(s)");
            mv.addItem("trajetsTermines", trajetsTermines.size());
            mv.setView("Planification/planification-details.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors de l'optimisation continue: " + e.getMessage());
            mv.setView("Planification/planification-form.jsp");
        }

        return mv;
    }

    /**
     * GET /planification/evenements
     * Afficher les événements véhicules
     */
    @GetMapping("/planification/evenements")
    public ModelView voirEvenements(@RequestParam("heures") String heuresStr) {
        ModelView mv = new ModelView();

        try {
            int heures = (heuresStr != null && !heuresStr.isEmpty()) ? Integer.parseInt(heuresStr) : 24;
            List<EvenementVehicule> evenements = EvenementVehicule.findRecents(jdbcTemplate, heures);

            mv.addItem("evenements", evenements);
            mv.addItem("heures", heures);
            mv.setView("Planification/evenements.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors du chargement des événements: " + e.getMessage());
            mv.addItem("evenements", List.of());
            mv.setView("Planification/evenements.jsp");
        }

        return mv;
    }

    /**
     * GET /planification/decisions
     * Afficher les décisions système
     */
    @GetMapping("/planification/decisions")
    public ModelView voirDecisions(@RequestParam("limit") String limitStr) {
        ModelView mv = new ModelView();

        try {
            int limit = (limitStr != null && !limitStr.isEmpty()) ? Integer.parseInt(limitStr) : 50;
            List<DecisionSysteme> decisions = DecisionSysteme.findRecent(jdbcTemplate, limit);

            mv.addItem("decisions", decisions);
            mv.addItem("limit", limit);
            mv.setView("Planification/decisions.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors du chargement des décisions: " + e.getMessage());
            mv.addItem("decisions", List.of());
            mv.setView("Planification/decisions.jsp");
        }

        return mv;
    }

    /**
     * GET /planification/statistiques
     * Afficher les statistiques de décisions
     */
    @GetMapping("/planification/statistiques")
    public ModelView voirStatistiques() {
        ModelView mv = new ModelView();

        try {
            LocalDateTime fin = LocalDateTime.now();
            LocalDateTime debut = fin.minusDays(7);

            String stats = DecisionSysteme.getStatistiques(jdbcTemplate, debut, fin);

            mv.addItem("statistiques", stats);
            mv.addItem("debut", debut);
            mv.addItem("fin", fin);
            mv.setView("Planification/statistiques.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors du chargement des statistiques: " + e.getMessage());
            mv.setView("Planification/statistiques.jsp");
        }

        return mv;
    }
}