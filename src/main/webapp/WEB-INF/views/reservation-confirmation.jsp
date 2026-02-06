<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.spring.BackOffice.model.Reservation" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirmation de Réservation</title>
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
        @keyframes confetti {
            0% { transform: translateY(-100vh) rotate(0deg); opacity: 1; }
            100% { transform: translateY(100vh) rotate(720deg); opacity: 0; }
        }
        @keyframes checkmark {
            0% { transform: scale(0) rotate(0deg); }
            50% { transform: scale(1.2) rotate(180deg); }
            100% { transform: scale(1) rotate(360deg); }
        }
        .animate-checkmark {
            animation: checkmark 0.6s ease-out;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-slide-up {
            animation: slideUp 0.5s ease-out forwards;
        }
        .gradient-success {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        .gradient-error {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        .gradient-text {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
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

    <div class="min-h-screen flex items-center justify-center p-6">
        <div class="max-w-3xl w-full">
            <%
                Boolean success = (Boolean) request.getAttribute("success");
                String error = (String) request.getAttribute("error");
                Reservation reservation = (Reservation) request.getAttribute("reservation");
                
                if (success != null && success && reservation != null) {
            %>
                <!-- Success State -->
                <div class="animate-slide-up">
                    <!-- Success Icon -->
                    <div class="text-center mb-8">
                        <div class="inline-block bg-gradient-success rounded-full p-8 mb-6 shadow-2xl animate-checkmark">
                            <i class="fas fa-check-circle text-8xl text-white"></i>
                        </div>
                        <h1 class="text-6xl font-bold mb-3 text-green-600">
                            Succès !
                        </h1>
                        <p class="text-2xl text-gray-600">Votre réservation a été confirmée</p>
                        <div class="flex items-center justify-center gap-2 mt-4">
                            <div class="badge badge-success badge-lg gap-2">
                                <i class="fas fa-shield-check"></i>
                                Réservation Sécurisée
                            </div>
                        </div>
                    </div>

                    <!-- Card principale avec les détails -->
                    <div class="custom-card rounded-3xl shadow-2xl overflow-hidden mb-6">
                        <!-- Header -->
                        <div class="gradient-success p-8 text-white">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h2 class="text-3xl font-bold mb-2">Détails de la Réservation</h2>
                                    <p class="opacity-90">Numéro de confirmation: #<%= reservation.getIdReservation() %></p>
                                </div>
                                <div class="bg-white/20 rounded-2xl p-4 backdrop-blur">
                                    <i class="fas fa-receipt text-5xl"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Détails -->
                        <div class="p-8 space-y-4">
                            <!-- N° Réservation -->
                            <div class="flex items-center justify-between p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-center gap-4">
                                    <div class="bg-purple-100 rounded-full p-3">
                                        <i class="fas fa-hashtag text-2xl text-purple-600"></i>
                                    </div>
                                    <div>
                                        <p class="text-sm text-gray-500 font-semibold">Numéro de Réservation</p>
                                        <p class="text-xl font-bold text-gray-800">#<%= reservation.getIdReservation() %></p>
                                    </div>
                                </div>
                                <button class="btn btn-circle btn-sm btn-ghost" onclick="copyToClipboard('#<%= reservation.getIdReservation() %>')">
                                    <i class="fas fa-copy"></i>
                                </button>
                            </div>

                            <!-- Client -->
                            <div class="flex items-center justify-between p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-center gap-4">
                                    <div class="bg-blue-100 rounded-full p-3">
                                        <i class="fas fa-user text-2xl text-blue-600"></i>
                                    </div>
                                    <div>
                                        <p class="text-sm text-gray-500 font-semibold">Client</p>
                                        <p class="text-xl font-bold text-gray-800"><%= reservation.getIdClient() %></p>
                                    </div>
                                </div>
                            </div>

                            <!-- Hôtel -->
                            <div class="flex items-center justify-between p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-center gap-4">
                                    <div class="bg-green-100 rounded-full p-3">
                                        <i class="fas fa-hotel text-2xl text-green-600"></i>
                                    </div>
                                    <div>
                                        <p class="text-sm text-gray-500 font-semibold">Hôtel Sélectionné</p>
                                        <p class="text-xl font-bold text-gray-800">
                                            <%= reservation.getNomHotel() != null ? reservation.getNomHotel() : "Hôtel #" + reservation.getIdHotel() %>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <!-- Passagers -->
                            <div class="flex items-center justify-between p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-center gap-4">
                                    <div class="bg-orange-100 rounded-full p-3">
                                        <i class="fas fa-users text-2xl text-orange-600"></i>
                                    </div>
                                    <div>
                                        <p class="text-sm text-gray-500 font-semibold">Nombre de Passagers</p>
                                        <p class="text-xl font-bold text-gray-800"><%= reservation.getNombrePassagers() %> personne(s)</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Statut -->
                            <div class="flex items-center justify-between p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-center gap-4">
                                    <div class="bg-green-100 rounded-full p-3">
                                        <i class="fas fa-check-circle text-2xl text-green-600"></i>
                                    </div>
                                    <div>
                                        <p class="text-sm text-gray-500 font-semibold">Statut</p>
                                        <div class="badge badge-success badge-lg gap-2 mt-1">
                                            <i class="fas fa-check"></i>
                                            <%= reservation.getStatut() %>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Commentaire (si existe) -->
                            <% if (reservation.getCommentaire() != null && !reservation.getCommentaire().isEmpty()) { %>
                            <div class="p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-start gap-4">
                                    <div class="bg-yellow-100 rounded-full p-3">
                                        <i class="fas fa-comment-alt text-2xl text-yellow-600"></i>
                                    </div>
                                    <div class="flex-1">
                                        <p class="text-sm text-gray-500 font-semibold mb-2">Commentaire</p>
                                        <p class="text-gray-700 italic">"<%= reservation.getCommentaire() %>"</p>
                                    </div>
                                </div>
                            </div>
                            <% } %>

                            <!-- Date -->
                            <div class="flex items-center justify-between p-5 bg-custom-lighter rounded-xl hover:bg-custom-light transition">
                                <div class="flex items-center gap-4">
                                    <div class="bg-indigo-100 rounded-full p-3">
                                        <i class="fas fa-calendar text-2xl text-indigo-600"></i>
                                    </div>
                                    <div>
                                        <p class="text-sm text-gray-500 font-semibold">Date de Création</p>
                                        <p class="text-xl font-bold text-gray-800"><%= reservation.getDateCreation() %></p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Footer avec actions -->
                        <div class="bg-custom-lighter p-8 border-t border-custom-border">
                            <div class="grid md:grid-cols-2 gap-4">
                                <a href="/sprint0/reservation/form" class="btn btn-primary btn-lg gap-2 bg-gradient-to-r from-purple-600 to-purple-700 border-0 shadow-xl">
                                    <i class="fas fa-plus-circle text-xl"></i>
                                    Nouvelle Réservation
                                </a>
                                <a href="/sprint0/reservation/list" class="btn btn-outline btn-lg gap-2">
                                    <i class="fas fa-list"></i>
                                    Voir Toutes les Réservations
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Actions supplémentaires -->
                    <div class="grid md:grid-cols-3 gap-4">
                        <div class="custom-card rounded-2xl p-6 text-center hover:shadow-xl transition">
                            <i class="fas fa-print text-4xl text-purple-600 mb-3"></i>
                            <h3 class="font-bold text-gray-800">Imprimer</h3>
                            <p class="text-sm text-gray-600 mt-2">Reçu de confirmation</p>
                            <button class="btn btn-sm btn-ghost mt-3" onclick="window.print()">
                                <i class="fas fa-print"></i>
                            </button>
                        </div>
                        <div class="custom-card rounded-2xl p-6 text-center hover:shadow-xl transition">
                            <i class="fas fa-envelope text-4xl text-blue-600 mb-3"></i>
                            <h3 class="font-bold text-gray-800">Email</h3>
                            <p class="text-sm text-gray-600 mt-2">Envoyer par email</p>
                            <button class="btn btn-sm btn-ghost mt-3">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </div>
                        <div class="custom-card rounded-2xl p-6 text-center hover:shadow-xl transition">
                            <i class="fas fa-share-alt text-4xl text-green-600 mb-3"></i>
                            <h3 class="font-bold text-gray-800">Partager</h3>
                            <p class="text-sm text-gray-600 mt-2">Sur les réseaux</p>
                            <button class="btn btn-sm btn-ghost mt-3">
                                <i class="fas fa-share"></i>
                            </button>
                        </div>
                    </div>
                </div>
            <%
                } else {
            %>
                <!-- Error State -->
                <div class="animate-slide-up">
                    <!-- Error Icon -->
                    <div class="text-center mb-8">
                        <div class="inline-block bg-gradient-error rounded-full p-8 mb-6 shadow-2xl animate-checkmark">
                            <i class="fas fa-times-circle text-8xl text-white"></i>
                        </div>
                        <h1 class="text-6xl font-bold mb-3 text-red-600">
                            Erreur
                        </h1>
                        <p class="text-2xl text-gray-600">La réservation n'a pas pu être créée</p>
                    </div>

                    <!-- Error Card -->
                    <div class="custom-card rounded-3xl shadow-2xl overflow-hidden mb-6">
                        <!-- Header -->
                        <div class="gradient-error p-8 text-white">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h2 class="text-3xl font-bold mb-2">Détails de l'Erreur</h2>
                                    <p class="opacity-90">Quelque chose s'est mal passé</p>
                                </div>
                                <div class="bg-white/20 rounded-2xl p-4 backdrop-blur">
                                    <i class="fas fa-exclamation-triangle text-5xl"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Error Message -->
                        <div class="p-8">
                            <div class="alert alert-error shadow-lg border-l-4 border-red-700">
                                <div>
                                    <i class="fas fa-exclamation-circle text-3xl"></i>
                                    <div>
                                        <h3 class="font-bold text-lg">Message d'erreur:</h3>
                                        <div class="text-base mt-2">
                                            <%= error != null ? error : "Une erreur inconnue s'est produite. Veuillez réessayer." %>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Suggestions -->
                            <div class="mt-8 bg-custom-lighter rounded-2xl p-6">
                                <h3 class="font-bold text-lg mb-4 flex items-center gap-2">
                                    <i class="fas fa-lightbulb text-yellow-500"></i>
                                    Suggestions
                                </h3>
                                <ul class="space-y-3">
                                    <li class="flex items-start gap-3">
                                        <i class="fas fa-check-circle text-green-500 mt-1"></i>
                                        <span>Vérifiez que tous les champs obligatoires sont remplis</span>
                                    </li>
                                    <li class="flex items-start gap-3">
                                        <i class="fas fa-check-circle text-green-500 mt-1"></i>
                                        <span>Assurez-vous d'avoir sélectionné un hôtel disponible</span>
                                    </li>
                                    <li class="flex items-start gap-3">
                                        <i class="fas fa-check-circle text-green-500 mt-1"></i>
                                        <span>Vérifiez votre connexion internet</span>
                                    </li>
                                </ul>
                            </div>
                        </div>

                        <!-- Footer -->
                        <div class="bg-custom-lighter p-8 border-t border-custom-border">
                            <div class="grid md:grid-cols-2 gap-4">
                                <a href="/sprint0/reservation/form" class="btn btn-primary btn-lg gap-2 bg-gradient-to-r from-purple-600 to-purple-700 border-0 shadow-xl">
                                    <i class="fas fa-redo"></i>
                                    Réessayer
                                </a>
                                <a href="/sprint0/reservation/list" class="btn btn-outline btn-lg gap-2">
                                    <i class="fas fa-home"></i>
                                    Retour à l'accueil
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Support Card -->
                    <div class="custom-card rounded-2xl p-8 text-center">
                        <i class="fas fa-headset text-5xl text-purple-600 mb-4"></i>
                        <h3 class="text-2xl font-bold text-gray-800 mb-3">Besoin d'aide ?</h3>
                        <p class="text-gray-600 mb-6">Notre équipe support est là pour vous aider 24/7</p>
                        <button class="btn btn-outline btn-lg gap-2">
                            <i class="fas fa-phone"></i>
                            Contacter le Support
                        </button>
                    </div>
                </div>
            <%
                }
            %>
        </div>
    </div>

    <script>
        function copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(function() {
                // Afficher un toast de succès
                const toast = document.createElement('div');
                toast.className = 'toast toast-top toast-center z-50';
                toast.innerHTML = `
                    <div class="alert alert-success shadow-lg">
                        <div>
                            <i class="fas fa-check-circle"></i>
                            <span>Numéro copié dans le presse-papier!</span>
                        </div>
                    </div>
                `;
                document.body.appendChild(toast);
                setTimeout(() => toast.remove(), 3000);
            });
        }

        // Animation au chargement
        window.addEventListener('load', function() {
            // Ajouter des confettis pour le succès
            <% if (success != null && success) { %>
                createConfetti();
            <% } %>
        });

        function createConfetti() {
            const colors = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#8b5cf6'];
            for (let i = 0; i < 50; i++) {
                setTimeout(() => {
                    const confetti = document.createElement('div');
                    confetti.style.position = 'fixed';
                    confetti.style.width = '10px';
                    confetti.style.height = '10px';
                    confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
                    confetti.style.left = Math.random() * 100 + '%';
                    confetti.style.top = '-10px';
                    confetti.style.opacity = '1';
                    confetti.style.animation = 'confetti 3s linear forwards';
                    confetti.style.zIndex = '9999';
                    confetti.style.borderRadius = '50%';
                    document.body.appendChild(confetti);
                    setTimeout(() => confetti.remove(), 3000);
                }, i * 30);
            }
        }
    </script>
</body>
</html>
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
