package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.ModelView;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.PlanningTransport;
import com.spring.BackOffice.model.Reservation;

import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDate;
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
}