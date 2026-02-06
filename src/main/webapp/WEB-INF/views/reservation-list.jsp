<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.spring.BackOffice.model.Reservation" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des Réservations</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 28px;
        }

        .btn-new {
            background: white;
            color: #667eea;
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: transform 0.2s ease;
        }

        .btn-new:hover {
            transform: translateY(-2px);
        }

        .content {
            padding: 40px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        thead {
            background: #f8f9fa;
        }

        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #e0e0e0;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
        }

        tr:hover {
            background: #f8f9fa;
        }

        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-waiting {
            background: #fef3c7;
            color: #d97706;
        }

        .badge-planned {
            background: #dbeafe;
            color: #2563eb;
        }

        .badge-ongoing {
            background: #ccfbf1;
            color: #0891b2;
        }

        .badge-completed {
            background: #d1fae5;
            color: #059669;
        }

        .badge-cancelled {
            background: #fee2e2;
            color: #dc2626;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }

        .empty-state h2 {
            font-size: 24px;
            margin-bottom: 10px;
        }

        .error-message {
            background: #fee;
            color: #c33;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #c33;
        }

        .stats {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            flex: 1;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }

        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }

        .stat-label {
            color: #666;
            font-size: 14px;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Liste des Réservations</h1>
            <a href="/sprint0/reservation/form" class="btn-new">➕ Nouvelle Réservation</a>
        </div>

        <div class="content">
            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <div class="error-message">
                    ⚠️ <strong>Erreur:</strong> <%= error %>
                </div>
            <% } %>

            <%
                List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
                if (reservations != null && !reservations.isEmpty()) {
                    // Calculer les statistiques
                    int total = reservations.size();
                    long enAttente = reservations.stream().filter(r -> "en_attente".equals(r.getStatut())).count();
                    long planifiees = reservations.stream().filter(r -> "planifiee".equals(r.getStatut())).count();
            %>
                <div class="stats">
                    <div class="stat-card">
                        <div class="stat-value"><%= total %></div>
                        <div class="stat-label">Total Réservations</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= enAttente %></div>
                        <div class="stat-label">En Attente</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= planifiees %></div>
                        <div class="stat-label">Planifiées</div>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>Client</th>
                            <th>Hôtel</th>
                            <th>Passagers</th>
                            <th>Statut</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Reservation res : reservations) {
                                String badgeClass = "badge-waiting";
                                if ("planifiee".equals(res.getStatut())) badgeClass = "badge-planned";
                                else if ("en_cours".equals(res.getStatut())) badgeClass = "badge-ongoing";
                                else if ("terminee".equals(res.getStatut())) badgeClass = "badge-completed";
                                else if ("annulee".equals(res.getStatut())) badgeClass = "badge-cancelled";
                        %>
                        <tr>
                            <td><strong>#<%= res.getIdReservation() %></strong></td>
                            <td><%= res.getIdClient() %></td>
                            <td><%= res.getNomHotel() != null ? res.getNomHotel() : "Hôtel #" + res.getIdHotel() %></td>
                            <td><%= res.getNombrePassagers() %> pers.</td>
                            <td><span class="badge <%= badgeClass %>"><%= res.getStatut() %></span></td>
                            <td><%= res.getDateCreation() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(res.getDateCreation()) : "" %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            <%
                } else if (error == null) {
            %>
                <div class="empty-state">
                    <div style="font-size: 64px; margin-bottom: 20px;">📭</div>
                    <h2>Aucune réservation</h2>
                    <p>Commencez par créer votre première réservation</p>
                    <br>
                    <a href="/sprint0/reservation/form" class="btn-new">➕ Créer une Réservation</a>
                </div>
            <%
                }
            %>
        </div>
    </div>
</body>
</html>
