package com.spring.BackOffice.controller;

import com.myframework.core.annotations.*;
import com.myframework.core.ModelView;
import com.myframework.core.JsonResponse;
import com.spring.BackOffice.config.JdbcTemplateProvider;
import com.spring.BackOffice.model.Vehicule;

import org.springframework.jdbc.core.JdbcTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour gérer les véhicules
 */
@Controller
public class VehiculeController {

    private JdbcTemplate jdbcTemplate;

    public VehiculeController() {
        this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        if (this.jdbcTemplate == null) {
            System.err.println("⚠️ JdbcTemplate null, reinitialisation...");
            JdbcTemplateProvider.reinitialize();
            this.jdbcTemplate = JdbcTemplateProvider.getJdbcTemplate();
        }
    }

    /**
     * GET /vehicule/form
     * Afficher le formulaire d'ajout de véhicule
     */
    @GetMapping("/vehicule/form")
    public ModelView showVehiculeForm() {
        ModelView mv = new ModelView();
        mv.setView("Vehicule/vehicule-form.jsp");
        return mv;
    }

    /**
     * GET /vehicule/edit
     * Afficher le formulaire de modification d'un véhicule
     */
    @GetMapping("/vehicule/edit")
    public ModelView showEditForm(@RequestParam("id") String idStr) {
        ModelView mv = new ModelView();
        mv.setView("Vehicule/vehicule-form.jsp");

        try {
            if (jdbcTemplate == null) {
                mv.addItem("error", "Base de données non disponible");
                return mv;
            }

            Long id = Long.parseLong(idStr);
            Vehicule vehicule = Vehicule.findById(jdbcTemplate, id);

            if (vehicule != null) {
                mv.addItem("vehicule", vehicule);
            } else {
                mv.addItem("error", "Véhicule non trouvé");
            }

        } catch (NumberFormatException e) {
            mv.addItem("error", "ID invalide");
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur : " + e.getMessage());
        }

        return mv;
    }

    /**
     * POST /vehicule/save
     * Sauvegarder (ajouter ou modifier) un véhicule et rediriger vers la liste
     */
    @PostMapping("/vehicule/save")
    public ModelView saveVehicule(
            @RequestParam( "id") String idStr,
            @RequestParam("reference") String reference,
            @RequestParam("nbrPlace") String nbrPlaceStr,
            @RequestParam("typeCarburant") String typeCarburant) {

        ModelView mv = new ModelView();
        mv.setView("Vehicule/vehicule-list.jsp");

        try {
            if (jdbcTemplate == null) {
                mv.addItem("error", "Base de données non disponible");
                return mv;
            }

            // Validations communes
            if (reference == null || reference.trim().isEmpty()) {
                mv.addItem("error", "La référence est obligatoire");
                // Recharger la liste avant de retourner
                List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                mv.addItem("vehicules", vehicules);
                mv.addItem("total", vehicules.size());
                return mv;
            }

            Integer nbrPlace;
            try {
                nbrPlace = Integer.parseInt(nbrPlaceStr);
                if (nbrPlace <= 0) {
                    mv.addItem("error", "Le nombre de places doit être supérieur à 0");
                    List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                    mv.addItem("vehicules", vehicules);
                    mv.addItem("total", vehicules.size());
                    return mv;
                }
            } catch (NumberFormatException e) {
                mv.addItem("error", "Nombre de places invalide");
                List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                mv.addItem("vehicules", vehicules);
                mv.addItem("total", vehicules.size());
                return mv;
            }

            if (typeCarburant == null || !typeCarburant.matches("D|ES|S|E")) {
                mv.addItem("error", "Type de carburant invalide (D, ES, S, E)");
                List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                mv.addItem("vehicules", vehicules);
                mv.addItem("total", vehicules.size());
                return mv;
            }

            // Déterminer si c'est une création ou une modification
            if (idStr == null || idStr.isEmpty()) {
                // CRÉATION
                Vehicule vehicule = new Vehicule(reference, nbrPlace, typeCarburant);
                Long vehiculeId = vehicule.save(jdbcTemplate);

                if (vehiculeId != null) {
                    mv.addItem("success", "Véhicule créé avec succès !");
                } else {
                    mv.addItem("error", "Échec de la création du véhicule");
                }
            } else {
                // MODIFICATION
                Long id = Long.parseLong(idStr);
                
                Vehicule existingVehicule = Vehicule.findById(jdbcTemplate, id);
                if (existingVehicule == null) {
                    mv.addItem("error", "Véhicule non trouvé");
                    List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                    mv.addItem("vehicules", vehicules);
                    mv.addItem("total", vehicules.size());
                    return mv;
                }

                existingVehicule.setReference(reference);
                existingVehicule.setNbrPlace(nbrPlace);
                existingVehicule.setTypeCarburant(typeCarburant);
                
                existingVehicule.update(jdbcTemplate);
                mv.addItem("success", "Véhicule mis à jour avec succès !");
            }

            // Recharger la liste des véhicules
            List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
            mv.addItem("vehicules", vehicules);
            mv.addItem("total", vehicules.size());

        } catch (NumberFormatException e) {
            mv.addItem("error", "ID invalide");
            try {
                List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                mv.addItem("vehicules", vehicules);
                mv.addItem("total", vehicules.size());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur : " + e.getMessage());
            try {
                List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                mv.addItem("vehicules", vehicules);
                mv.addItem("total", vehicules.size());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        return mv;
    }

    /**
     * POST /vehicule/delete
     * Supprimer un véhicule et rediriger vers la liste
     */
    @PostMapping("/vehicule/delete")
    public ModelView deleteVehicule(@RequestParam("id") String idStr) {
        ModelView mv = new ModelView();
        mv.setView("Vehicule/vehicule-list.jsp");

        try {
            if (jdbcTemplate == null) {
                mv.addItem("error", "Base de données non disponible");
                return mv;
            }

            Long id = Long.parseLong(idStr);
            
            Vehicule vehicule = Vehicule.findById(jdbcTemplate, id);
            if (vehicule == null) {
                mv.addItem("error", "Véhicule non trouvé");
            } else {
                Vehicule.deleteById(jdbcTemplate, id);
                mv.addItem("success", "Véhicule supprimé avec succès !");
            }

            // Recharger la liste
            List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
            mv.addItem("vehicules", vehicules);
            mv.addItem("total", vehicules.size());

        } catch (NumberFormatException e) {
            mv.addItem("error", "ID invalide");
            try {
                List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
                mv.addItem("vehicules", vehicules);
                mv.addItem("total", vehicules.size());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur : " + e.getMessage());
        }

        return mv;
    }

    /**
     * GET /vehicule/list-view
     * Afficher la liste des véhicules
     */
    @GetMapping("/vehicule/list")
    public ModelView listVehiculesView() {
        ModelView mv = new ModelView();
        mv.setView("Vehicule/vehicule-list.jsp");

        try {
            List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);
            mv.addItem("vehicules", vehicules);
            mv.addItem("total", vehicules.size());
        } catch (Exception e) {
            e.printStackTrace();
            mv.addItem("error", "Erreur lors du chargement des véhicules");
        }

        return mv;
    }

    /**
     * GET /vehicule/list (JSON)
     */
    @RestAPI
    @GetMapping("/api/vehicule/list")
    public JsonResponse listVehicules() {
        try {
            List<Vehicule> vehicules = Vehicule.findAll(jdbcTemplate);

            Map<String, Object> data = new HashMap<>();
            data.put("vehicules", vehicules);
            data.put("total", vehicules.size());

            return JsonResponse.success(data);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorData = new HashMap<>();
            errorData.put("error", "Erreur chargement véhicules");
            return JsonResponse.error(500, errorData);
        }
    }
}