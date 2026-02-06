<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.spring.BackOffice.model.Reservation" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des Réservations</title>
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
        .table-hover tbody tr {
            transition: all 0.2s ease;
        }
        .table-hover tbody tr:hover {
            background: #f1f4f9;
            transform: scale(1.01);
            box-shadow: 0 4px 12px rgba(208, 215, 225, 0.3);
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in {
            animation: fadeIn 0.5s ease-out;
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
    <!-- Navbar élégante -->
    <div class="navbar bg-white shadow-lg border-b border-custom-border sticky top-0 z-50">
        <div class="navbar-start">
            <a href="/sprint0/" class="btn btn-ghost text-xl gap-2">
                <i class="fas fa-hotel text-purple-600"></i>
                <span class="gradient-text font-bold">Hotel Manager</span>
            </a>
        </div>
        <div class="navbar-center hidden md:flex">
            <ul class="menu menu-horizontal px-1 gap-2">
                <li><a class="active"><i class="fas fa-list"></i> Réservations</a></li>
                <li><a><i class="fas fa-chart-bar"></i> Statistiques</a></li>
            </ul>
        </div>
        <div class="navbar-end gap-2">
            <a href="/sprint0/reservation/form" class="btn btn-primary gap-2 bg-gradient-to-r from-purple-600 to-purple-700 border-0">
                <i class="fas fa-plus-circle"></i>
                Nouvelle Réservation
            </a>
        </div>
    </div>

    <div class="container mx-auto px-4 py-8 max-w-7xl">
        <!-- Header Section -->
        <div class="text-center mb-8 animate-fade-in">
            <div class="inline-block bg-gradient-to-br from-purple-500 to-purple-600 rounded-full p-6 mb-4 shadow-xl">
                <i class="fas fa-clipboard-list text-5xl text-white"></i>
            </div>
            <h1 class="text-5xl font-bold mb-3">
                <span class="gradient-text">Gestion des Réservations</span>
            </h1>
            <p class="text-xl text-gray-600">Vue d'ensemble de toutes vos réservations</p>
        </div>

        <!-- Alert d'erreur -->
        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-error shadow-lg mb-6 border-l-4 border-red-700 animate-fade-in">
                <div>
                    <i class="fas fa-exclamation-circle text-2xl"></i>
                    <div>
                        <h3 class="font-bold">Erreur</h3>
                        <div class="text-sm"><%= error %></div>
                    </div>
                </div>
            </div>
        <% } %>

        <%
            List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
            if (reservations != null && !reservations.isEmpty()) {
                // Calculer les statistiques
                int total = reservations.size();
                long enAttente = reservations.stream().filter(r -> "en_attente".equals(r.getStatut())).count();
                long planifiees = reservations.stream().filter(r -> "planifiee".equals(r.getStatut())).count();
                long enCours = reservations.stream().filter(r -> "en_cours".equals(r.getStatut())).count();
                long terminees = reservations.stream().filter(r -> "terminee".equals(r.getStatut())).count();
        %>
            <!-- Stats Cards -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8 animate-fade-in">
                <!-- Total -->
                <div class="custom-card rounded-2xl p-6 shadow-xl hover:shadow-2xl transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold uppercase">Total</p>
                            <p class="text-4xl font-bold text-purple-600"><%= total %></p>
                            <p class="text-xs text-gray-500 mt-1">Réservations</p>
                        </div>
                        <div class="bg-purple-100 rounded-full p-4">
                            <i class="fas fa-clipboard-list text-3xl text-purple-600"></i>
                        </div>
                    </div>
                    <div class="mt-4 bg-purple-100 h-2 rounded-full overflow-hidden">
                        <div class="bg-purple-600 h-full" style="width: 100%"></div>
                    </div>
                </div>

                <!-- En Attente -->
                <div class="custom-card rounded-2xl p-6 shadow-xl hover:shadow-2xl transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold uppercase">En Attente</p>
                            <p class="text-4xl font-bold text-yellow-600"><%= enAttente %></p>
                            <p class="text-xs text-gray-500 mt-1">À traiter</p>
                        </div>
                        <div class="bg-yellow-100 rounded-full p-4">
                            <i class="fas fa-clock text-3xl text-yellow-600"></i>
                        </div>
                    </div>
                    <div class="mt-4 bg-yellow-100 h-2 rounded-full overflow-hidden">
                        <div class="bg-yellow-600 h-full" style="width: <%= total > 0 ? (enAttente * 100 / total) : 0 %>%"></div>
                    </div>
                </div>

                <!-- Planifiées -->
                <div class="custom-card rounded-2xl p-6 shadow-xl hover:shadow-2xl transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold uppercase">Planifiées</p>
                            <p class="text-4xl font-bold text-blue-600"><%= planifiees %></p>
                            <p class="text-xs text-gray-500 mt-1">Confirmées</p>
                        </div>
                        <div class="bg-blue-100 rounded-full p-4">
                            <i class="fas fa-calendar-check text-3xl text-blue-600"></i>
                        </div>
                    </div>
                    <div class="mt-4 bg-blue-100 h-2 rounded-full overflow-hidden">
                        <div class="bg-blue-600 h-full" style="width: <%= total > 0 ? (planifiees * 100 / total) : 0 %>%"></div>
                    </div>
                </div>

                <!-- Terminées -->
                <div class="custom-card rounded-2xl p-6 shadow-xl hover:shadow-2xl transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 font-semibold uppercase">Terminées</p>
                            <p class="text-4xl font-bold text-green-600"><%= terminees %></p>
                            <p class="text-xs text-gray-500 mt-1">Succès</p>
                        </div>
                        <div class="bg-green-100 rounded-full p-4">
                            <i class="fas fa-check-circle text-3xl text-green-600"></i>
                        </div>
                    </div>
                    <div class="mt-4 bg-green-100 h-2 rounded-full overflow-hidden">
                        <div class="bg-green-600 h-full" style="width: <%= total > 0 ? (terminees * 100 / total) : 0 %>%"></div>
                    </div>
                </div>
            </div>

            <!-- Table des réservations -->
            <div class="custom-card rounded-3xl shadow-2xl overflow-hidden animate-fade-in">
                <div class="gradient-header p-6">
                    <div class="flex items-center justify-between text-white">
                        <div>
                            <h2 class="text-2xl font-bold mb-1">Liste Complète</h2>
                            <p class="opacity-90 text-sm"><%= total %> réservation(s) trouvée(s)</p>
                        </div>
                        <div class="flex gap-2">
                            <button class="btn btn-sm btn-ghost text-white gap-2">
                                <i class="fas fa-filter"></i>
                                Filtrer
                            </button>
                            <button class="btn btn-sm btn-ghost text-white gap-2">
                                <i class="fas fa-download"></i>
                                Export
                            </button>
                        </div>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="table table-hover w-full">
                        <thead class="bg-custom-lighter">
                            <tr>
                                <th class="font-bold text-gray-700">
                                    <i class="fas fa-hashtag text-purple-600"></i> N°
                                </th>
                                <th class="font-bold text-gray-700">
                                    <i class="fas fa-user text-purple-600"></i> Client
                                </th>
                                <th class="font-bold text-gray-700">
                                    <i class="fas fa-hotel text-purple-600"></i> Hôtel
                                </th>
                                <th class="font-bold text-gray-700">
                                    <i class="fas fa-users text-purple-600"></i> Passagers
                                </th>
                                <th class="font-bold text-gray-700">
                                    <i class="fas fa-info-circle text-purple-600"></i> Statut
                                </th>
                                <th class="font-bold text-gray-700">
                                    <i class="fas fa-calendar text-purple-600"></i> Date
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (Reservation res : reservations) {
                                    String badgeClass = "";
                                    String iconClass = "";
                                    
                                    if ("en_attente".equals(res.getStatut())) {
                                        badgeClass = "badge-warning";
                                        iconClass = "fa-clock";
                                    } else if ("planifiee".equals(res.getStatut())) {
                                        badgeClass = "badge-info";
                                        iconClass = "fa-calendar-check";
                                    } else if ("en_cours".equals(res.getStatut())) {
                                        badgeClass = "badge-primary";
                                        iconClass = "fa-spinner";
                                    } else if ("terminee".equals(res.getStatut())) {
                                        badgeClass = "badge-success";
                                        iconClass = "fa-check-circle";
                                    } else if ("annulee".equals(res.getStatut())) {
                                        badgeClass = "badge-error";
                                        iconClass = "fa-times-circle";
                                    }
                            %>
                            <tr class="cursor-pointer">
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="bg-purple-100 rounded-full w-10 h-10 flex items-center justify-center">
                                            <span class="font-bold text-purple-600">#<%= res.getIdReservation() %></span>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-3">
                                        <div class="avatar placeholder">
                                            <div class="bg-blue-100 text-blue-600 rounded-full w-10">
                                                <span class="text-xs font-bold"><%= res.getIdClient().substring(0, Math.min(2, res.getIdClient().length())).toUpperCase() %></span>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="font-bold text-gray-800"><%= res.getIdClient() %></div>
                                            <div class="text-sm text-gray-500">Client</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <i class="fas fa-building text-purple-500"></i>
                                        <span class="font-semibold"><%= res.getNomHotel() != null ? res.getNomHotel() : "Hôtel #" + res.getIdHotel() %></span>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="badge badge-lg gap-2">
                                            <i class="fas fa-user-friends"></i>
                                            <%= res.getNombrePassagers() %>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="badge <%= badgeClass %> badge-lg gap-2 font-semibold">
                                        <i class="fas <%= iconClass %>"></i>
                                        <%= res.getStatut() %>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex flex-col">
                                        <span class="font-semibold text-gray-800">
                                            <%= res.getDateCreation() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(res.getDateCreation()) : "" %>
                                        </span>
                                        <span class="text-xs text-gray-500">
                                            <%= res.getDateCreation() != null ? new java.text.SimpleDateFormat("HH:mm").format(res.getDateCreation()) : "" %>
                                        </span>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <!-- Footer Table -->
                <div class="bg-custom-lighter p-4 flex items-center justify-between border-t border-custom-border">
                    <div class="text-sm text-gray-600">
                        Affichage de <strong><%= total %></strong> réservation(s)
                    </div>
                    <div class="join">
                        <button class="join-item btn btn-sm">«</button>
                        <button class="join-item btn btn-sm btn-active">1</button>
                        <button class="join-item btn btn-sm">»</button>
                    </div>
                </div>
            </div>
        <%
            } else if (error == null) {
        %>
            <!-- Empty State -->
            <div class="custom-card rounded-3xl shadow-2xl p-16 text-center animate-fade-in">
                <div class="mb-8">
                    <i class="fas fa-inbox text-9xl text-gray-300"></i>
                </div>
                <h2 class="text-4xl font-bold text-gray-800 mb-4">Aucune réservation</h2>
                <p class="text-xl text-gray-600 mb-8">Commencez par créer votre première réservation</p>
                <a href="/sprint0/reservation/form" class="btn btn-primary btn-lg gap-3 bg-gradient-to-r from-purple-600 to-purple-700 border-0 shadow-xl">
                    <i class="fas fa-plus-circle text-2xl"></i>
                    Créer ma Première Réservation
                </a>
                
                <!-- Features -->
                <div class="grid md:grid-cols-3 gap-6 mt-12">
                    <div class="p-6 bg-custom-lighter rounded-2xl">
                        <i class="fas fa-bolt text-4xl text-yellow-500 mb-3"></i>
                        <h3 class="font-bold text-gray-800">Rapide</h3>
                        <p class="text-sm text-gray-600 mt-2">Création en quelques clics</p>
                    </div>
                    <div class="p-6 bg-custom-lighter rounded-2xl">
                        <i class="fas fa-shield-alt text-4xl text-blue-500 mb-3"></i>
                        <h3 class="font-bold text-gray-800">Sécurisé</h3>
                        <p class="text-sm text-gray-600 mt-2">Données protégées</p>
                    </div>
                    <div class="p-6 bg-custom-lighter rounded-2xl">
                        <i class="fas fa-chart-line text-4xl text-green-500 mb-3"></i>
                        <h3 class="font-bold text-gray-800">Suivi</h3>
                        <p class="text-sm text-gray-600 mt-2">Statistiques en temps réel</p>
                    </div>
                </div>
            </div>
        <%
            }
        %>
    </div>

    <!-- Footer -->
    <footer class="footer footer-center p-10 bg-white text-base-content rounded shadow-xl mt-12 border-t border-custom-border">
        <div>
            <div class="grid grid-flow-col gap-4">
                <i class="fas fa-hotel text-3xl text-purple-600"></i>
            </div> 
            <p class="font-bold text-lg gradient-text">
                Hotel Manager Pro
            </p> 
            <p class="text-gray-600">Excellence hôtelière depuis 2026</p>
        </div> 
        <div>
            <div class="grid grid-flow-col gap-6">
                <a class="text-2xl text-gray-600 hover:text-purple-600 transition"><i class="fab fa-twitter"></i></a> 
                <a class="text-2xl text-gray-600 hover:text-purple-600 transition"><i class="fab fa-facebook"></i></a> 
                <a class="text-2xl text-gray-600 hover:text-purple-600 transition"><i class="fab fa-instagram"></i></a>
            </div>
        </div>
    </footer>

    <script>
        // Animation au chargement
        document.addEventListener('DOMContentLoaded', function() {
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach((row, index) => {
                row.style.animationDelay = `${index * 0.05}s`;
                row.classList.add('animate-fade-in');
            });
        });

        // Effet de clic sur les lignes
        document.querySelectorAll('tbody tr').forEach(row => {
            row.addEventListener('click', function() {
                this.classList.add('bg-purple-50');
                setTimeout(() => this.classList.remove('bg-purple-50'), 300);
            });
        });
    </script>
</body>
</html>
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
