<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.spring.BackOffice.model.Reservation" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirmation de Réservation</title>
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
            max-width: 600px;
            margin: 40px auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }

        .header.error {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }

        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }

        .header p {
            opacity: 0.9;
            font-size: 16px;
        }

        .content {
            padding: 40px;
        }

        .success-icon {
            text-align: center;
            font-size: 80px;
            margin-bottom: 20px;
            animation: bounce 1s ease;
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-30px); }
            60% { transform: translateY(-15px); }
        }

        .info-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: #666;
        }

        .info-value {
            color: #333;
            font-weight: 500;
        }

        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-success {
            background: #d1fae5;
            color: #059669;
        }

        .btn-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            transition: transform 0.2s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-secondary {
            background: #f3f4f6;
            color: #333;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .error-message {
            background: #fee;
            color: #c33;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #c33;
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            Boolean success = (Boolean) request.getAttribute("success");
            String error = (String) request.getAttribute("error");
            Reservation reservation = (Reservation) request.getAttribute("reservation");
            
            if (success != null && success && reservation != null) {
        %>
            <div class="header">
                <div class="success-icon">✅</div>
                <h1>Réservation Confirmée !</h1>
                <p>Votre réservation a été enregistrée avec succès</p>
            </div>

            <div class="content">
                <div class="info-card">
                    <div class="info-row">
                        <span class="info-label">N° de Réservation</span>
                        <span class="info-value">#<%= reservation.getIdReservation() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Client</span>
                        <span class="info-value"><%= reservation.getIdClient() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Hôtel</span>
                        <span class="info-value">
                            <%= reservation.getNomHotel() != null ? reservation.getNomHotel() : "Hôtel #" + reservation.getIdHotel() %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Nombre de Passagers</span>
                        <span class="info-value"><%= reservation.getNombrePassagers() %> personne(s)</span>
                    </div>
                    <% if (reservation.getDateArrivee() != null) { %>
                    <div class="info-row">
                        <span class="info-label">Date d'Arrivée</span>
                        <span class="info-value"><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(reservation.getDateArrivee()) %></span>
                    </div>
                    <% } %>
                    <% if (reservation.getHeureArrivee() != null) { %>
                    <div class="info-row">
                        <span class="info-label">Heure d'Arrivée</span>
                        <span class="info-value"><%= reservation.getHeureArrivee() %></span>
                    </div>
                    <% } %>
                    <div class="info-row">
                        <span class="info-label">Statut</span>
                        <span class="info-value">
                            <span class="badge badge-success"><%= reservation.getStatut() %></span>
                        </span>
                    </div>
                    <% if (reservation.getCommentaire() != null && !reservation.getCommentaire().isEmpty()) { %>
                    <div class="info-row">
                        <span class="info-label">Commentaire</span>
                        <span class="info-value"><%= reservation.getCommentaire() %></span>
                    </div>
                    <% } %>
                    <div class="info-row">
                        <span class="info-label">Date de Création</span>
                        <span class="info-value"><%= reservation.getDateCreation() %></span>
                    </div>
                </div>

                <div class="btn-group">
                    <a href="/sprint0/reservation/form" class="btn btn-primary">
                        ➕ Nouvelle Réservation
                    </a>
                    <a href="/sprint0/reservation/list" class="btn btn-secondary">
                        📋 Voir Toutes
                    </a>
                </div>
            </div>
        <%
            } else {
        %>
            <div class="header error">
                <div class="success-icon">❌</div>
                <h1>Erreur</h1>
                <p>La réservation n'a pas pu être créée</p>
            </div>

            <div class="content">
                <div class="error-message">
                    <strong>⚠️ Erreur:</strong><br>
                    <%= error != null ? error : "Une erreur inconnue s'est produite" %>
                </div>

                <div class="btn-group">
                    <a href="/sprint0/reservation/form" class="btn btn-primary">
                        🔙 Retour au Formulaire
                    </a>
                </div>
            </div>
        <%
            }
        %>
    </div>
</body>
</html>
