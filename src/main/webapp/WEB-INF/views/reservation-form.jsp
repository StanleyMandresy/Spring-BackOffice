<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.spring.BackOffice.model.Hotel" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Formulaire de Réservation</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .header p {
            opacity: 0.9;
            font-size: 14px;
        }

        .form-container {
            padding: 40px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }

        input[type="text"],
        input[type="number"],
        select,
        textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
            font-family: inherit;
        }

        input:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        textarea {
            resize: vertical;
            min-height: 100px;
        }

        .hotel-option {
            padding: 10px;
        }

        .btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn:active {
            transform: translateY(0);
        }

        .error-message {
            background: #fee;
            color: #c33;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #c33;
        }

        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #1976d2;
        }

        .required {
            color: #e74c3c;
        }

        .back-link {
            text-align: center;
            margin-top: 20px;
        }

        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }

        .back-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏨 Formulaire de Réservation</h1>
            <p>Réservez votre séjour dans nos hôtels partenaires</p>
        </div>

        <div class="form-container">
            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <div class="error-message">
                    ⚠️ <strong>Erreur:</strong> <%= error %>
                </div>
            <% } %>

            <div class="info-box">
                ℹ️ Tous les champs marqués d'un <span class="required">*</span> sont obligatoires
            </div>

            <form action="/sprint0/reservation/create" method="POST">
                <div class="form-group">
                    <label for="idClient">
                        Identifiant Client <span class="required">*</span>
                    </label>
                    <input 
                        type="text" 
                        id="idClient" 
                        name="idClient" 
                        placeholder="Ex: CLIENT123" 
                        required 
                        maxlength="50"
                    />
                </div>

                <div class="form-group">
                    <label for="idHotel">
                        Hôtel <span class="required">*</span>
                    </label>
                    <select id="idHotel" name="idHotel" required>
                        <option value="">-- Sélectionnez un hôtel --</option>
                        <%
                            List<Hotel> hotels = (List<Hotel>) request.getAttribute("hotels");
                            if (hotels != null && !hotels.isEmpty()) {
                                for (Hotel hotel : hotels) {
                                    String etoiles = "★".repeat(hotel.getNombreEtoiles());
                        %>
                            <option value="<%= hotel.getIdHotel() %>" class="hotel-option">
                                <%= hotel.getNomHotel() %> - <%= hotel.getVille() %> 
                                (<%= etoiles %> - <%= String.format("%.2f", hotel.getPrixNuit()) %>€/nuit)
                            </option>
                        <%
                                }
                            } else {
                        %>
                            <option value="">Aucun hôtel disponible</option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="nombrePassagers">
                        Nombre de Passagers <span class="required">*</span>
                    </label>
                    <input 
                        type="number" 
                        id="nombrePassagers" 
                        name="nombrePassagers" 
                        placeholder="Ex: 2" 
                        min="1" 
                        max="10" 
                        required
                    />
                </div>

                <div class="form-group">
                    <label for="dateArrivee">
                        Date d'Arrivée <span class="required">*</span>
                    </label>
                    <input 
                        type="date" 
                        id="dateArrivee" 
                        name="dateArrivee" 
                        required
                    />
                </div>

                <div class="form-group">
                    <label for="heureArrivee">
                        Heure d'Arrivée <span class="required">*</span>
                    </label>
                    <input 
                        type="time" 
                        id="heureArrivee" 
                        name="heureArrivee" 
                        required
                    />
                </div>

                <div class="form-group">
                    <label for="commentaire">
                        Commentaire / Demandes spéciales
                    </label>
                    <textarea 
                        id="commentaire" 
                        name="commentaire" 
                        placeholder="Ex: Préférence pour une chambre vue mer, arrivée tardive..."
                    ></textarea>
                </div>

                <button type="submit" class="btn">
                    ✅ Confirmer la Réservation
                </button>
            </form>

            <div class="back-link">
                <a href="/sprint0/reservation/list">📋 Voir toutes les réservations</a>
            </div>
        </div>
    </div>

    <script>
        // Validation côté client
        document.querySelector('form').addEventListener('submit', function(e) {
            const idClient = document.getElementById('idClient').value.trim();
            const idHotel = document.getElementById('idHotel').value;
            const nombrePassagers = parseInt(document.getElementById('nombrePassagers').value);

            if (!idClient) {
                alert('Veuillez saisir un identifiant client');
                e.preventDefault();
                return;
            }

            if (!idHotel) {
                alert('Veuillez sélectionner un hôtel');
                e.preventDefault();
                return;
            }

            if (!nombrePassagers || nombrePassagers < 1) {
                alert('Le nombre de passagers doit être au moins 1');
                e.preventDefault();
                return;
            }
        });
    </script>
</body>
</html>
