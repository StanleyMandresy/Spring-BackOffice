<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.spring.BackOffice.model.Hotel" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvelle Réservation</title>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@4.6.0/dist/full.min.css" rel="stylesheet" type="text/css" />
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #f2f5fa 0%, #ecedf5 100%);
            min-height: 100vh;
        }
        .custom-card {
            background: #ffffff;
            border: 1px solid #d0d7e1;
        }
        .gradient-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .custom-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .hotel-card {
            transition: all 0.3s ease;
        }
        .hotel-card:hover {
            background: #f1f4f9;
            transform: scale(1.02);
        }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'custom-bg': '#f2f5fa',
                        'custom-white': '#ffffff',
                        'custom-border': '#d0d7e1',
                        'custom-light': '#f1f4f9',
                        'custom-lighter': '#ecedf5'
                    }
                }
            }
        }
    </script>
</head>
<body class="font-sans">
    <!-- Navbar -->
    <div class="navbar bg-white shadow-lg border-b border-custom-border">
        <div class="navbar-start">
            <a href="/sprint0/" class="btn btn-ghost text-xl gap-2">
                <i class="fas fa-hotel text-purple-600"></i>
                <span class="gradient-text font-bold">Hotel Manager</span>
            </a>
        </div>
        <div class="navbar-end gap-2">
            <a href="/sprint0/reservation/list" class="btn btn-ghost gap-2">
                <i class="fas fa-list"></i>
                Liste
            </a>
        </div>
    </div>

    <div class="container mx-auto px-4 py-8 max-w-4xl">
        <!-- Header avec icône -->
        <div class="text-center mb-8">
            <div class="inline-block bg-gradient-to-br from-purple-500 to-purple-600 rounded-full p-6 mb-4 shadow-xl">
                <i class="fas fa-calendar-plus text-5xl text-white"></i>
            </div>
            <h1 class="text-5xl font-bold mb-3">
                <span class="gradient-text">Nouvelle Réservation</span>
            </h1>
            <p class="text-xl text-gray-600">Réservez votre séjour en quelques clics</p>
        </div>

        <!-- Alert d'erreur -->
        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-error shadow-lg mb-6 border-l-4 border-red-700">
                <div>
                    <i class="fas fa-exclamation-circle text-2xl"></i>
                    <div>
                        <h3 class="font-bold">Erreur</h3>
                        <div class="text-sm"><%= error %></div>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Formulaire principal -->
        <div class="custom-card rounded-3xl shadow-2xl overflow-hidden">
            <!-- En-tête du formulaire -->
            <div class="gradient-header p-8 text-white">
                <div class="flex items-center justify-between">
                    <div>
                        <h2 class="text-3xl font-bold mb-2">Informations de réservation</h2>
                        <p class="opacity-90">Remplissez tous les champs requis</p>
                    </div>
                    <div class="bg-white/20 rounded-2xl p-4 backdrop-blur">
                        <i class="fas fa-clipboard-list text-4xl"></i>
                    </div>
                </div>
            </div>

            <!-- Corps du formulaire -->
            <div class="p-8">
                <!-- Info box -->
                <div class="alert alert-info shadow-sm mb-8 border-l-4 border-blue-500">
                    <i class="fas fa-info-circle text-2xl"></i>
                    <div>
                        <p class="text-sm">Les champs marqués d'un <span class="text-red-500 font-bold">*</span> sont obligatoires</p>
                    </div>
                </div>

                <form action="/sprint0/reservation/create" method="POST" class="space-y-6">
                    <!-- Identifiant Client -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text text-lg font-bold flex items-center gap-2">
                                <i class="fas fa-user text-purple-600"></i>
                                Identifiant Client
                                <span class="text-red-500">*</span>
                            </span>
                        </label>
                        <div class="relative">
                            <input 
                                type="text" 
                                id="idClient" 
                                name="idClient" 
                                placeholder="Ex: CLIENT123" 
                                required 
                                maxlength="50"
                                class="input input-bordered input-lg w-full pl-12 custom-input bg-custom-light focus:bg-white"
                            />
                            <i class="fas fa-id-card absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        </div>
                        <label class="label">
                            <span class="label-text-alt">Votre identifiant unique de client</span>
                        </label>
                    </div>

                    <!-- Sélection Hôtel -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text text-lg font-bold flex items-center gap-2">
                                <i class="fas fa-hotel text-purple-600"></i>
                                Sélectionner un Hôtel
                                <span class="text-red-500">*</span>
                            </span>
                        </label>
                        <select id="idHotel" name="idHotel" required class="select select-bordered select-lg w-full custom-input bg-custom-light focus:bg-white">
                            <option value="">-- Choisissez votre hôtel --</option>
                            <%
                                List<Hotel> hotels = (List<Hotel>) request.getAttribute("hotels");
                                if (hotels != null && !hotels.isEmpty()) {
                                    for (Hotel hotel : hotels) {
                                        String etoiles = "⭐".repeat(hotel.getNombreEtoiles());
                            %>
                                <option value="<%= hotel.getIdHotel() %>">
                                    <%= hotel.getNomHotel() %> - <%= hotel.getVille() %> 
                                    (<%= etoiles %> <%= String.format("%.2f", hotel.getPrixNuit()) %>€/nuit)
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
                        <label class="label">
                            <span class="label-text-alt">Choisissez parmi nos hôtels partenaires</span>
                        </label>
                    </div>

                    <!-- Hôtels disponibles (si liste) -->
                    <%
                        if (hotels != null && !hotels.isEmpty()) {
                    %>
                        <div class="bg-custom-lighter rounded-2xl p-6 border border-custom-border">
                            <h3 class="font-bold text-lg mb-4 flex items-center gap-2">
                                <i class="fas fa-building text-purple-600"></i>
                                Nos Hôtels Disponibles
                            </h3>
                            <div class="grid md:grid-cols-2 gap-4">
                                <%
                                    for (Hotel hotel : hotels) {
                                        String etoiles = "⭐".repeat(hotel.getNombreEtoiles());
                                %>
                                    <div class="hotel-card bg-white p-4 rounded-xl shadow-sm cursor-pointer border border-custom-border">
                                        <div class="flex items-start gap-3">
                                            <div class="bg-purple-100 rounded-lg p-3">
                                                <i class="fas fa-hotel text-2xl text-purple-600"></i>
                                            </div>
                                            <div class="flex-1">
                                                <h4 class="font-bold text-gray-800"><%= hotel.getNomHotel() %></h4>
                                                <p class="text-sm text-gray-600">
                                                    <i class="fas fa-map-marker-alt text-red-500"></i> <%= hotel.getVille() %>
                                                </p>
                                                <div class="flex items-center justify-between mt-2">
                                                    <span class="text-xs"><%= etoiles %></span>
                                                    <span class="badge badge-lg badge-primary">
                                                        <%= String.format("%.2f", hotel.getPrixNuit()) %>€/nuit
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    <%
                        }
                    %>

                    <!-- Nombre de Passagers -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text text-lg font-bold flex items-center gap-2">
                                <i class="fas fa-users text-purple-600"></i>
                                Nombre de Passagers
                                <span class="text-red-500">*</span>
                            </span>
                        </label>
                        <div class="relative">
                            <input 
                                type="number" 
                                id="nombrePassagers" 
                                name="nombrePassagers" 
                                placeholder="Ex: 2" 
                                min="1" 
                                max="10" 
                                required
                                class="input input-bordered input-lg w-full pl-12 custom-input bg-custom-light focus:bg-white"
                            />
                            <i class="fas fa-user-friends absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        </div>
                        <label class="label">
                            <span class="label-text-alt">Entre 1 et 10 personnes</span>
                            <span class="label-text-alt">
                                <i class="fas fa-info-circle"></i> Maximum 10 personnes
                            </span>
                        </label>
                    </div>

                    <!-- Commentaire -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text text-lg font-bold flex items-center gap-2">
                                <i class="fas fa-comment-alt text-purple-600"></i>
                                Commentaires ou Demandes Spéciales
                            </span>
                        </label>
                        <textarea 
                            id="commentaire" 
                            name="commentaire" 
                            placeholder="Ex: Chambre vue mer, arrivée tardive, allergies alimentaires..."
                            class="textarea textarea-bordered textarea-lg h-32 custom-input bg-custom-light focus:bg-white"
                        ></textarea>
                        <label class="label">
                            <span class="label-text-alt">Facultatif - Vos demandes particulières</span>
                        </label>
                    </div>

                    <!-- Boutons d'action -->
                    <div class="divider"></div>
                    
                    <div class="grid md:grid-cols-2 gap-4">
                        <button type="submit" class="btn btn-primary btn-lg gap-2 shadow-xl bg-gradient-to-r from-purple-600 to-purple-700 border-0 hover:scale-105 transition">
                            <i class="fas fa-check-circle text-xl"></i>
                            Confirmer la Réservation
                        </button>
                        <a href="/sprint0/reservation/list" class="btn btn-outline btn-lg gap-2 hover:bg-custom-light">
                            <i class="fas fa-arrow-left"></i>
                            Retour à la liste
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Stats rapides -->
        <div class="mt-8 stats stats-vertical md:stats-horizontal shadow-xl w-full bg-white border border-custom-border">
            <div class="stat">
                <div class="stat-figure text-purple-600">
                    <i class="fas fa-clock text-3xl"></i>
                </div>
                <div class="stat-title">Temps de traitement</div>
                <div class="stat-value text-purple-600">Instant</div>
                <div class="stat-desc">Confirmation immédiate</div>
            </div>
            <div class="stat">
                <div class="stat-figure text-blue-600">
                    <i class="fas fa-shield-alt text-3xl"></i>
                </div>
                <div class="stat-title">Sécurité</div>
                <div class="stat-value text-blue-600">100%</div>
                <div class="stat-desc">Données protégées</div>
            </div>
            <div class="stat">
                <div class="stat-figure text-green-600">
                    <i class="fas fa-check-double text-3xl"></i>
                </div>
                <div class="stat-title">Confirmations</div>
                <div class="stat-value text-green-600">24/7</div>
                <div class="stat-desc">Service continu</div>
            </div>
        </div>
    </div>

    <script>
        // Validation côté client avec feedback visuel
        document.querySelector('form').addEventListener('submit', function(e) {
            const idClient = document.getElementById('idClient').value.trim();
            const idHotel = document.getElementById('idHotel').value;
            const nombrePassagers = parseInt(document.getElementById('nombrePassagers').value);

            if (!idClient) {
                e.preventDefault();
                showAlert('Veuillez saisir un identifiant client', 'error');
                document.getElementById('idClient').focus();
                return;
            }

            if (!idHotel) {
                e.preventDefault();
                showAlert('Veuillez sélectionner un hôtel', 'error');
                document.getElementById('idHotel').focus();
                return;
            }

            if (!nombrePassagers || nombrePassagers < 1) {
                e.preventDefault();
                showAlert('Le nombre de passagers doit être au moins 1', 'error');
                document.getElementById('nombrePassagers').focus();
                return;
            }

            // Animation de chargement
            const btn = e.target.querySelector('button[type="submit"]');
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Traitement en cours...';
            btn.disabled = true;
        });

        function showAlert(message, type) {
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-${type} shadow-lg mb-4 animate-pulse`;
            alertDiv.innerHTML = `
                <div>
                    <i class="fas fa-exclamation-triangle text-2xl"></i>
                    <span>${message}</span>
                </div>
            `;
            document.querySelector('.p-8').insertBefore(alertDiv, document.querySelector('form'));
            setTimeout(() => alertDiv.remove(), 3000);
        }

        // Animation pour les cartes d'hôtel
        document.querySelectorAll('.hotel-card').forEach(card => {
            card.addEventListener('click', function() {
                const hotelName = this.querySelector('h4').textContent;
                const selectElement = document.getElementById('idHotel');
                
                for (let option of selectElement.options) {
                    if (option.text.includes(hotelName)) {
                        selectElement.value = option.value;
                        this.classList.add('ring-4', 'ring-purple-500');
                        setTimeout(() => this.classList.remove('ring-4', 'ring-purple-500'), 1000);
                        break;
                    }
                }
            });
        });
    </script>
</body>
</html>
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
