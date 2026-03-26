package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

/**
 * SPRINT 8 : Service de planification dynamique
 *
 * Gère la ré-optimisation des véhicules quand ils reviennent à l'aéroport.
 * Décide intelligemment : partir immédiatement avec passagers disponibles
 * ou attendre un meilleur regroupement.
 */
public class PlanificationDynamique {

    // Seuils de décision pour le taux de remplissage
    private static final double SEUIL_DEPART_IMMEDIAT = 0.80;  // 80% remplissage → partir
    private static final double SEUIL_ATTENTE = 0.50;         // <50% → attendre

    /**
     * Point d'entrée principal : optimiser après le retour d'un véhicule
     *
     * @param jdbcTemplate Template JDBC
     * @param idVehicule ID du véhicule qui vient de revenir
     * @param date Date de la planification
     * @param heureRetour Heure de retour du véhicule
     */
    public static void optimiserApresRetourVehicule(
            JdbcTemplate jdbcTemplate,
            Long idVehicule,
            LocalDate date,
            LocalDateTime heureRetour) {

        System.out.println("\n🔄 ===== OPTIMISATION DYNAMIQUE =====");
        System.out.println("📍 Véhicule #" + idVehicule + " retourné à " + heureRetour);

        try {
            // 1. Logger l'événement de retour
            EvenementVehicule.logRetourVehicule(jdbcTemplate, idVehicule, heureRetour, null);

            // 2. Charger le véhicule
            Vehicule vehicule = Vehicule.findById(jdbcTemplate, idVehicule);
            if (vehicule == null) {
                System.err.println("❌ Véhicule #" + idVehicule + " introuvable");
                return;
            }

            // 3. Charger les paramètres système
            Parametre params = Parametre.getLatest(jdbcTemplate);
            if (params == null) {
                System.err.println("❌ Paramètres système introuvables");
                return;
            }

            // 4. Trouver les réservations non assignées (avec priorité)
            List<Reservation> reservationsEnAttente =
                Reservation.findNonAssigneesAvecPriorite(jdbcTemplate, date);

            System.out.println("📋 " + reservationsEnAttente.size() + " réservations en attente");

            // 5. Vérifier disponibilité du véhicule
            Map<Long, PlanningTransport.FenetreDisponibilite> fenetres =
                PlanningTransport.chargerDisponibilitesVehicules(jdbcTemplate, date);

            PlanningTransport.FenetreDisponibilite fenetre = fenetres.get(idVehicule);
            if (fenetre == null) {
                System.out.println("⚠️ Véhicule #" + idVehicule + " n'a pas de fenêtre de disponibilité pour " + date);
                loggerDecision(jdbcTemplate, vehicule, reservationsEnAttente,
                              DecisionSysteme.AUCUNE_ACTION, "Pas de fenêtre disponibilité", params);
                return;
            }

            // Vérifier si le véhicule peut encore travailler
            if (heureRetour.isAfter(fenetre.getFin())) {
                System.out.println("⏰ Véhicule #" + idVehicule + " a dépassé sa fenêtre de disponibilité");
                loggerDecision(jdbcTemplate, vehicule, reservationsEnAttente,
                              DecisionSysteme.AUCUNE_ACTION, "Fenêtre expirée", params);
                return;
            }

            // 6. Prendre la décision : partir ou attendre ?
            String decision = prendreDecision(
                vehicule,
                reservationsEnAttente,
                heureRetour,
                params
            );

            System.out.println("🎯 Décision: " + decision);

            // 7. Exécuter la décision
            switch (decision) {
                case DecisionSysteme.DEPART_IMMEDIAT:
                    executerDepartImmediatMaxPassagers(
                        jdbcTemplate,
                        vehicule,
                        reservationsEnAttente,
                        date,
                        heureRetour,
                        params,
                        fenetre
                    );
                    break;

                case DecisionSysteme.ATTENTE_REGROUPEMENT:
                    String raison = "Taux de remplissage faible, attente meilleur regroupement";
                    EvenementVehicule.logAttenteRegroupement(jdbcTemplate, idVehicule, raison);
                    loggerDecision(jdbcTemplate, vehicule, reservationsEnAttente, decision, raison, params);
                    System.out.println("⏳ Véhicule #" + idVehicule + " attend un meilleur regroupement");
                    break;

                case DecisionSysteme.AUCUNE_ACTION:
                    loggerDecision(jdbcTemplate, vehicule, reservationsEnAttente, decision,
                                  "Aucun passager disponible", params);
                    System.out.println("⏸️ Aucune action nécessaire");
                    break;
            }

            System.out.println("✅ Optimisation terminée\n");

        } catch (Exception e) {
            System.err.println("❌ Erreur lors de l'optimisation dynamique: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Logique de décision : partir maintenant ou attendre ?
     *
     * Algorithme:
     * 1. Calculer passagers disponibles dans fenêtre attenteMax
     * 2. Calculer taux de remplissage = min(passagers, capacité) / capacité
     * 3. Si taux >= 80% → DEPART_IMMEDIAT
     * 4. Si taux < 50% → ATTENTE_REGROUPEMENT
     * 5. Si 0 passagers → AUCUNE_ACTION
     *
     * @return Type de décision (DEPART_IMMEDIAT, ATTENTE_REGROUPEMENT, AUCUNE_ACTION)
     */
    private static String prendreDecision(
            Vehicule vehicule,
            List<Reservation> reservationsEnAttente,
            LocalDateTime maintenant,
            Parametre params) {

        if (reservationsEnAttente == null || reservationsEnAttente.isEmpty()) {
            return DecisionSysteme.AUCUNE_ACTION;
        }

        int attenteMax = params.getTempsAttenteMinute();
        int capaciteVehicule = vehicule.getNbrPlace();

        // Calculer le nombre de passagers disponibles dans la fenêtre d'attente
        int passagersDisponibles = 0;
        List<Reservation> candidats = new ArrayList<>();

        for (Reservation r : reservationsEnAttente) {
            LocalDateTime heureArrivee = r.getDateHeureArrive().toLocalDateTime();
            long minutesEcart = Duration.between(maintenant, heureArrivee).toMinutes();

            // Réservation dans la fenêtre d'attente (passée ou future jusqu'à attenteMax)
            if (minutesEcart >= -attenteMax && minutesEcart <= attenteMax) {
                // Calculer passagers restants pour cette réservation
                int passagersRestants = r.getNombrePassagers();

                // Si réservation partielle, calculer vraiment ce qui reste
                if ("partiel".equals(r.getStatut())) {
                    // Note: on pourrait appeler Reservation.getPassagersRestants() mais
                    // pour éviter trop d'appels DB, on utilise le total pour estimation
                    passagersRestants = r.getNombrePassagers(); // Estimation conservatrice
                }

                passagersDisponibles += passagersRestants;
                candidats.add(r);
            }
        }

        if (passagersDisponibles == 0) {
            return DecisionSysteme.AUCUNE_ACTION;
        }

        // Calculer le taux de remplissage potentiel
        int passagersATransporter = Math.min(passagersDisponibles, capaciteVehicule);
        double tauxRemplissage = (double) passagersATransporter / capaciteVehicule;

        System.out.println("📊 Analyse:");
        System.out.println("   Capacité véhicule: " + capaciteVehicule + " places");
        System.out.println("   Passagers disponibles: " + passagersDisponibles);
        System.out.println("   Passagers à transporter: " + passagersATransporter);
        System.out.println("   Taux remplissage: " + String.format("%.0f%%", tauxRemplissage * 100));

        // Décision basée sur le taux de remplissage
        if (tauxRemplissage >= SEUIL_DEPART_IMMEDIAT) {
            System.out.println("   → Bon taux de remplissage (>= 80%)");
            return DecisionSysteme.DEPART_IMMEDIAT;
        }

        if (tauxRemplissage < SEUIL_ATTENTE) {
            System.out.println("   → Faible taux de remplissage (< 50%)");
            return DecisionSysteme.ATTENTE_REGROUPEMENT;
        }

        // Entre 50% et 80% : vérifier s'il y a des réservations imminentes
        boolean reservationsImminentes = false;
        for (Reservation r : reservationsEnAttente) {
            if (!candidats.contains(r)) {
                LocalDateTime heureArrivee = r.getDateHeureArrive().toLocalDateTime();
                long minutesEcart = Duration.between(maintenant, heureArrivee).toMinutes();

                // Réservation arrive dans les 2x attenteMax minutes
                if (minutesEcart > attenteMax && minutesEcart <= (attenteMax * 2)) {
                    reservationsImminentes = true;
                    break;
                }
            }
        }

        if (reservationsImminentes) {
            System.out.println("   → Taux moyen mais réservations imminentes → attendre");
            return DecisionSysteme.ATTENTE_REGROUPEMENT;
        }

        System.out.println("   → Taux acceptable → partir");
        return DecisionSysteme.DEPART_IMMEDIAT;
    }

    /**
     * Exécution d'un départ immédiat avec maximum de passagers
     *
     * Priorité de remplissage:
     * 1. Réservations partielles (déjà commencées)
     * 2. Réservations anciennes (FIFO)
     * 3. Réservations qui remplissent le mieux le véhicule
     */
    private static void executerDepartImmediatMaxPassagers(
            JdbcTemplate jdbcTemplate,
            Vehicule vehicule,
            List<Reservation> reservationsEnAttente,
            LocalDate date,
            LocalDateTime heureDepart,
            Parametre params,
            PlanningTransport.FenetreDisponibilite fenetre) {

        System.out.println("🚀 Départ immédiat - Remplissage maximal");

        try {
            // Charger l'aéroport comme point de départ
            Hotel aeroport = Hotel.findByNom(jdbcTemplate, "AEROPORT");
            if (aeroport == null) {
                System.err.println("❌ Hôtel AEROPORT introuvable");
                return;
            }

            double vitesse = params.getVitesseKmh().doubleValue();
            int attenteMax = params.getTempsAttenteMinute();

            // Filtrer les réservations dans la fenêtre d'attente
            List<Reservation> candidats = new ArrayList<>();
            for (Reservation r : reservationsEnAttente) {
                LocalDateTime heureArrivee = r.getDateHeureArrive().toLocalDateTime();
                long minutesEcart = Duration.between(heureDepart, heureArrivee).toMinutes();

                if (Math.abs(minutesEcart) <= attenteMax) {
                    candidats.add(r);
                }
            }

            if (candidats.isEmpty()) {
                System.out.println("⚠️ Aucun candidat dans fenêtre d'attente");
                return;
            }

            // Trier par priorité (déjà fait par findNonAssigneesAvecPriorite, mais on re-confirme)
            candidats.sort((a, b) -> {
                // 1. Partielles en premier
                boolean aPartiel = "partiel".equals(a.getStatut());
                boolean bPartiel = "partiel".equals(b.getStatut());
                if (aPartiel != bPartiel) {
                    return aPartiel ? -1 : 1;
                }
                // 2. Plus anciennes en premier
                return a.getDateCreation().compareTo(b.getDateCreation());
            });

            // Remplir le véhicule
            int placesRestantes = vehicule.getNbrPlace();
            int totalPassagersTransportes = 0;
            List<String> reservationsTraitees = new ArrayList<>();

            Map<Long, LocalDateTime> dispoVehicule = new HashMap<>();
            dispoVehicule.put(vehicule.getId(), heureDepart);

            Map<Long, Integer> nbTrajetsVehicule = new HashMap<>();
            nbTrajetsVehicule.put(vehicule.getId(), 0);

            for (Reservation reservation : candidats) {
                if (placesRestantes <= 0) {
                    break;
                }

                int passagersRestants = Reservation.getPassagersRestants(jdbcTemplate, reservation.getIdReservation());
                if (passagersRestants <= 0) {
                    continue;  // Déjà complètement transportée
                }

                int aPrendre = Math.min(passagersRestants, placesRestantes);

                // Allouer au véhicule
                Hotel positionDepart = aeroport;  // Véhicule est à l'aéroport

                PlanningTransport.allocateToVehicule(
                    reservation,
                    vehicule,
                    aPrendre,
                    date,
                    heureDepart,
                    positionDepart,
                    aeroport,
                    vitesse,
                    jdbcTemplate,
                    dispoVehicule,
                    nbTrajetsVehicule
                );

                // Marquer comme regroupement DYNAMIQUE
                // Note: allocateToVehicule() sauvegarde mais avec type PLANIFIE par défaut
                // On doit mettre à jour après coup
                jdbcTemplate.update(
                    "UPDATE planning_transport SET type_regroupement = 'DYNAMIQUE' " +
                    "WHERE id_vehicule = ? AND heure_depart = ? ORDER BY id DESC LIMIT 1",
                    vehicule.getId(), heureDepart
                );

                // Logger l'événement de réassignation
                EvenementVehicule.logReassignationDynamique(jdbcTemplate, vehicule.getId(), aPrendre, null);

                placesRestantes -= aPrendre;
                totalPassagersTransportes += aPrendre;

                // Mettre à jour le statut de la réservation
                int nouveauRestant = passagersRestants - aPrendre;
                String nouveauStatut = (nouveauRestant == 0) ? "planifie" : "partiel";
                Reservation.updateStatut(jdbcTemplate, reservation.getIdReservation(), nouveauStatut);

                reservationsTraitees.add("Rés #" + reservation.getIdReservation() +
                                        " (" + aPrendre + "/" + reservation.getNombrePassagers() + " passagers)");

                System.out.println("   ✓ Ajouté réservation #" + reservation.getIdReservation() +
                                 ": " + aPrendre + " passagers");
            }

            // Logger la décision avec résultat
            String contexte = buildContexte(vehicule, candidats, params);
            String resultat = buildResultat(totalPassagersTransportes, vehicule.getNbrPlace(), reservationsTraitees);
            DecisionSysteme.logDecision(jdbcTemplate, contexte, DecisionSysteme.DEPART_IMMEDIAT,
                                       resultat, vehicule.getId());

            System.out.println("✅ Départ avec " + totalPassagersTransportes + " passagers " +
                             "(" + reservationsTraitees.size() + " réservations)");

        } catch (Exception e) {
            System.err.println("❌ Erreur lors du départ immédiat: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Logger une décision du système
     */
    private static void loggerDecision(
            JdbcTemplate jdbcTemplate,
            Vehicule vehicule,
            List<Reservation> reservations,
            String decision,
            String raison,
            Parametre params) {

        String contexte = buildContexte(vehicule, reservations, params);
        String resultat = "Raison: " + raison;

        DecisionSysteme.logDecision(jdbcTemplate, contexte, decision, resultat, vehicule.getId());
    }

    /**
     * Construire le contexte de décision pour logging
     */
    private static String buildContexte(Vehicule vehicule, List<Reservation> reservations, Parametre params) {
        StringBuilder ctx = new StringBuilder();
        ctx.append("Véhicule: #").append(vehicule.getId())
           .append(" (").append(vehicule.getReference()).append("), ")
           .append("Capacité: ").append(vehicule.getNbrPlace()).append(", ")
           .append("Réservations en attente: ").append(reservations.size()).append(", ")
           .append("Attente max: ").append(params.getTempsAttenteMinute()).append(" min, ")
           .append("Vitesse: ").append(params.getVitesseKmh()).append(" km/h");
        return ctx.toString();
    }

    /**
     * Construire le résultat de décision pour logging
     */
    private static String buildResultat(int passagersTransportes, int capacite, List<String> reservations) {
        StringBuilder res = new StringBuilder();
        res.append("Passagers transportés: ").append(passagersTransportes).append("/").append(capacite)
           .append(" (").append(String.format("%.0f%%", (double)passagersTransportes/capacite*100)).append("), ")
           .append("Réservations: ").append(String.join(", ", reservations));
        return res.toString();
    }
}
