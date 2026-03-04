<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.spring.BackOffice.model.Reservation" %>
<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>✨ Liste des Réservations</title>
    
    <!-- Tailwind CSS + DaisyUI -->
    <link href="https://cdn.jsdelivr.net/npm/daisyui@4.7.2/dist/full.min.css" rel="stylesheet" type="text/css" />
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <!-- Anime.js for animations -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    
    <!-- Chart.js for stats -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #E9F5DB 0%, #CFE1B9 25%, #B5C99A 50%, #97A97C 75%, #87986A 100%);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        /* Floating particles */
        .particle {
            position: fixed;
            width: 8px;
            height: 8px;
            background: rgba(255, 255, 255, 0.6);
            border-radius: 50%;
            pointer-events: none;
            animation: float 25s infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0) translateX(0) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(-100vh) translateX(50px) rotate(360deg); opacity: 0; }
        }

        /* Glassmorphism */
        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }

        /* Fade in animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .fade-in-up {
            animation: fadeInUp 0.6s ease-out forwards;
        }

        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .fade-in-down {
            animation: fadeInDown 0.6s ease-out forwards;
        }

        /* Floating animation */
        @keyframes floating {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
        }

        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Pulse animation */
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        /* Shine effect */
        .shine {
            position: relative;
            overflow: hidden;
        }

        .shine::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            transition: left 0.5s;
        }

        .shine:hover::before {
            left: 100%;
        }

        /* Table row hover effect */
        .table-row {
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .table-row:hover {
            transform: translateX(10px);
            background: linear-gradient(90deg, rgba(181, 201, 154, 0.15), transparent) !important;
            box-shadow: -4px 0 0 0 #87986A;
        }

        /* Badge animations */
        .badge-custom {
            animation: pulse 2s ease-in-out infinite;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        /* Stats card hover */
        .stat-card-hover {
            transition: all 0.3s ease;
        }

        .stat-card-hover:hover {
            transform: translateY(-10px) scale(1.05);
            box-shadow: 0 20px 40px rgba(135, 152, 106, 0.3);
        }

        /* Gradient text */
        .gradient-text {
            background: linear-gradient(135deg, #718355 0%, #87986A 50%, #97A97C 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 12px;
        }

        ::-webkit-scrollbar-track {
            background: #E9F5DB;
        }

        ::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #87986A, #97A97C);
            border-radius: 10px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(180deg, #718355, #87986A);
        }

        /* Button magical effect */
        .btn-magical {
            position: relative;
            background: linear-gradient(135deg, #87986A 0%, #718355 100%);
            border: none;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .btn-magical::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s;
        }

        .btn-magical:hover::before {
            left: 100%;
        }

        .btn-magical:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(135, 152, 106, 0.6);
        }

        /* Search bar glow */
        .search-glow:focus {
            box-shadow: 0 0 20px rgba(151, 169, 124, 0.5);
        }

        /* Counter animation */
        @keyframes countUp {
            from { opacity: 0; transform: scale(0.5); }
            to { opacity: 1; transform: scale(1); }
        }

        .count-animation {
            animation: countUp 0.5s ease-out;
        }

        /* Empty state animation */
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-30px); }
            60% { transform: translateY(-15px); }
        }

        .bounce {
            animation: bounce 2s ease infinite;
        }
    </style>
</head>
<body class="relative">
    <!-- Include Sidebar -->
    <%@ include file="components/sidebar.jsp" %>
    
    <!-- Main Content with Sidebar -->
    <div class="main-content-with-sidebar">
        <!-- Floating particles -->
    <% for(int i = 0; i < 20; i++) { %>
        <div class="particle" style="left: <%= Math.random() * 100 %>%; animation-delay: <%= Math.random() * 25 %>s;"></div>
    <% } %>

    <div class="container mx-auto px-4 py-8 md:py-12">
        <div class="max-w-7xl mx-auto">
            
            <!-- Main Card -->
            <div class="glass-card rounded-3xl shadow-2xl overflow-hidden">
                
                <!-- Header -->
                <div class="bg-gradient-to-br from-[#B5C99A] via-[#97A97C] to-[#87986A] p-8 md:p-12">
                    <div class="flex flex-col md:flex-row justify-between items-center gap-6">
                        <div class="text-center md:text-left fade-in-down">
                            <div class="text-5xl mb-3 floating inline-block">📋</div>
                            <h1 class="text-4xl md:text-5xl font-extrabold text-white mb-2 drop-shadow-lg">
                                Liste des Réservations
                            </h1>
                            <p class="text-white/90 text-lg">
                                <i class="bi bi-database"></i>
                                Gérez toutes vos réservations en un clin d'œil
                            </p>
                        </div>
                        <div class="flex gap-3 fade-in-down" style="animation-delay: 0.2s">
                            <a href="/sprint0/reservation/form" class="btn btn-magical btn-lg text-white shine">
                                <i class="fas fa-plus-circle text-xl"></i>
                                <span class="font-bold">Nouvelle Réservation</span>
                            </a>
                        </div>
                    </div>

                    <!-- Search and Filter Bar -->
                    <div class="mt-8 flex flex-col md:flex-row gap-4 fade-in-up" style="animation-delay: 0.3s">
                        <div class="flex-1">
                            <div class="relative">
                                <input 
                                    type="text" 
                                    id="searchInput" 
                                    placeholder="🔍 Rechercher par client, hôtel, numéro..." 
                                    class="input input-bordered w-full bg-white/90 backdrop-blur-sm search-glow text-gray-800 font-medium"
                                />
                                <i class="bi bi-search absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 text-xl"></i>
                            </div>
                        </div>
                        <div class="flex gap-2">
                            <select id="statusFilter" class="select select-bordered bg-white/90 backdrop-blur-sm font-medium">
                                <option value="">Tous les statuts</option>
                                <option value="en_attente">En attente</option>
                                <option value="planifiee">Planifiée</option>
                                <option value="en_cours">En cours</option>
                                <option value="terminee">Terminée</option>
                                <option value="annulee">Annulée</option>
                            </select>
                            <button class="btn btn-outline border-white text-white hover:bg-white hover:text-[#87986A]" onclick="resetFilters()">
                                <i class="fas fa-redo"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Content Area -->
                <div class="p-6 md:p-10">
                    
                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null) {
                    %>
                        <div class="alert alert-error shadow-lg mb-8 fade-in-up">
                            <i class="fas fa-exclamation-triangle text-2xl"></i>
                            <div>
                                <h3 class="font-bold">Erreur</h3>
                                <div class="text-sm"><%= error %></div>
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
                        <!-- Statistics Cards -->
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6 mb-10">
                            <!-- Total -->
                            <div class="stat bg-gradient-to-br from-[#E9F5DB] to-[#CFE1B9] rounded-2xl shadow-xl border-2 stat-card-hover fade-in-up" style="border-color: #B5C99A; animation-delay: 0.1s">
                                <div class="stat-figure" style="color: #87986A;">
                                    <i class="fas fa-list-alt text-4xl"></i>
                                </div>
                                <div class="stat-title font-bold" style="color: #718355;">Total</div>
                                <div class="stat-value count-animation gradient-text"><%= total %></div>
                                <div class="stat-desc font-semibold" style="color: #87986A;">Réservations</div>
                            </div>

                            <!-- En Attente -->
                            <div class="stat bg-gradient-to-br from-yellow-50 to-yellow-100 rounded-2xl shadow-xl border-2 border-yellow-300 stat-card-hover fade-in-up" style="animation-delay: 0.2s">
                                <div class="stat-figure text-yellow-600">
                                    <i class="fas fa-clock text-4xl"></i>
                                </div>
                                <div class="stat-title font-bold text-yellow-800">En Attente</div>
                                <div class="stat-value text-yellow-600 count-animation"><%= enAttente %></div>
                                <div class="stat-desc font-semibold text-yellow-700">À traiter</div>
                            </div>

                            <!-- Planifiées -->
                            <div class="stat bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl shadow-xl border-2 border-blue-300 stat-card-hover fade-in-up" style="animation-delay: 0.3s">
                                <div class="stat-figure text-blue-600">
                                    <i class="fas fa-calendar-check text-4xl"></i>
                                </div>
                                <div class="stat-title font-bold text-blue-800">Planifiées</div>
                                <div class="stat-value text-blue-600 count-animation"><%= planifiees %></div>
                                <div class="stat-desc font-semibold text-blue-700">Confirmées</div>
                            </div>

                            <!-- Terminées -->
                            <div class="stat bg-gradient-to-br from-[#CFE1B9] to-[#B5C99A] rounded-2xl shadow-xl border-2 stat-card-hover fade-in-up" style="border-color: #97A97C; animation-delay: 0.4s">
                                <div class="stat-figure" style="color: #718355;">
                                    <i class="fas fa-check-double text-4xl"></i>
                                </div>
                                <div class="stat-title font-bold" style="color: #718355;">Terminées</div>
                                <div class="stat-value count-animation" style="color: #718355;"><%= terminees %></div>
                                <div class="stat-desc font-semibold" style="color: #87986A;">Complétées</div>
                            </div>
                        </div>

                        <!-- Table Container -->
                        <div class="overflow-x-auto rounded-2xl shadow-2xl fade-in-up" style="animation-delay: 0.5s">
                            <table class="table table-zebra w-full">
                                <thead class="bg-gradient-to-r from-[#B5C99A] to-[#97A97C]">
                                    <tr class="text-white">
                                        <th class="text-base">
                                            <i class="bi bi-hash"></i> N°
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-person"></i> Client
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-building"></i> Hôtel
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-people"></i> Passagers
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-flag"></i> Statut
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-calendar3"></i> Date
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-gear"></i> Actions
                                        </th>
                                    </tr>
                                </thead>
                                <tbody id="reservationsTable">
                                    <%
                                        int rowIndex = 0;
                                        for (Reservation res : reservations) {
                                            String badgeClass = "badge-warning";
                                            String badgeIcon = "fa-clock";
                                            if ("planifiee".equals(res.getStatut())) {
                                                badgeClass = "badge-info";
                                                badgeIcon = "fa-calendar-check";
                                            } else if ("en_cours".equals(res.getStatut())) {
                                                badgeClass = "badge-primary";
                                                badgeIcon = "fa-spinner fa-spin";
                                            } else if ("terminee".equals(res.getStatut())) {
                                                badgeClass = "badge-success";
                                                badgeIcon = "fa-check-circle";
                                            } else if ("annulee".equals(res.getStatut())) {
                                                badgeClass = "badge-error";
                                                badgeIcon = "fa-times-circle";
                                            }
                                    %>
                                    <tr class="table-row hover" data-status="<%= res.getStatut() %>" style="animation-delay: <%= (rowIndex * 0.05) %>s">
                                        <td class="font-bold text-lg" style="color: #718355;">
                                            #<%= res.getIdReservation() %>
                                        </td>
                                        <td>
                                            <div class="flex items-center gap-3">
                                                <div class="avatar placeholder">
                                                    <div class="bg-gradient-to-br from-[#B5C99A] to-[#97A97C] text-white rounded-full w-12 h-12 flex items-center justify-center">
                                                        <span class="text-xl font-bold"><%= res.getIdClient().substring(0, 1).toUpperCase() %></span>
                                                    </div>
                                                </div>
                                                <div>
                                                    <div class="font-bold text-gray-800"><%= res.getIdClient() %></div>
                                                    <div class="text-sm text-gray-500">
                                                        <i class="bi bi-person-badge"></i> Client
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="font-semibold text-gray-800">
                                                <i class="fas fa-hotel" style="color: #87986A;"></i>
                                                <%= res.getNomHotel() != null ? res.getNomHotel() : "Hôtel #" + res.getIdHotel() %>
                                            </div>
                                            <div class="text-sm text-gray-500">
                                                <i class="bi bi-geo-alt"></i> Établissement
                                            </div>
                                        </td>
                                        <td>
                                            <div class="flex items-center gap-2">
                                                <div class="badge badge-lg" style="background: #E9F5DB; color: #718355; border: 2px solid #B5C99A;">
                                                    <i class="bi bi-people-fill mr-1"></i>
                                                    <%= res.getNombrePassagers() %> pers.
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge <%= badgeClass %> badge-lg gap-2 badge-custom">
                                                <i class="fas <%= badgeIcon %>"></i>
                                                <%= res.getStatut() %>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="text-gray-800 font-semibold">
                                                <i class="bi bi-calendar3"></i>
                                                <%= res.getDateCreation() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(res.getDateCreation()) : "" %>
                                            </div>
                                            <div class="text-sm text-gray-500">
                                                <i class="bi bi-clock"></i>
                                                <%= res.getDateCreation() != null ? new java.text.SimpleDateFormat("HH:mm").format(res.getDateCreation()) : "" %>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="flex gap-2">
                                                <button class="btn btn-sm btn-circle" style="background: #87986A; color: white;" title="Voir détails">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button class="btn btn-sm btn-circle btn-outline" style="border-color: #87986A; color: #87986A;" title="Modifier">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <button class="btn btn-sm btn-circle btn-error btn-outline" title="Supprimer">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                            rowIndex++;
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        <div class="flex justify-center mt-8 fade-in-up" style="animation-delay: 0.6s">
                            <div class="btn-group">
                                <button class="btn" style="background: #E9F5DB; color: #718355; border-color: #B5C99A;">«</button>
                                <button class="btn" style="background: #87986A; color: white;">1</button>
                                <button class="btn" style="background: #E9F5DB; color: #718355; border-color: #B5C99A;">2</button>
                                <button class="btn" style="background: #E9F5DB; color: #718355; border-color: #B5C99A;">3</button>
                                <button class="btn" style="background: #E9F5DB; color: #718355; border-color: #B5C99A;">»</button>
                            </div>
                        </div>

                    <%
                        } else if (error == null) {
                    %>
                        <!-- Empty State -->
                        <div class="text-center py-20 fade-in-up">
                            <div class="text-9xl mb-8 bounce">📭</div>
                            <h2 class="text-4xl font-extrabold mb-4 gradient-text">
                                Aucune réservation
                            </h2>
                            <p class="text-xl text-gray-600 mb-8">
                                Commencez par créer votre première réservation
                            </p>
                            <a href="/sprint0/reservation/form" class="btn btn-magical btn-lg text-white shine">
                                <i class="fas fa-plus-circle text-2xl"></i>
                                <span class="font-bold text-lg">Créer une Réservation</span>
                                <i class="fas fa-arrow-right text-xl"></i>
                            </a>
                        </div>
                    <%
                        }
                    %>

                </div>
            </div>

            <!-- Quick Stats Footer -->
            <div class="mt-8 text-center text-white fade-in-up" style="animation-delay: 0.7s">
                <p class="text-lg font-semibold drop-shadow-lg">
                    <i class="fas fa-database"></i>
                    Système de gestion des réservations
                    <i class="fas fa-shield-alt"></i>
                </p>
            </div>

        </div>
    </div>

    <script>
        // Search functionality
        const searchInput = document.getElementById('searchInput');
        const statusFilter = document.getElementById('statusFilter');
        const tableRows = document.querySelectorAll('#reservationsTable tr');

        function filterTable() {
            const searchTerm = searchInput.value.toLowerCase();
            const statusValue = statusFilter.value.toLowerCase();

            tableRows.forEach(row => {
                const text = row.textContent.toLowerCase();
                const status = row.getAttribute('data-status');
                
                const matchesSearch = text.includes(searchTerm);
                const matchesStatus = !statusValue || status === statusValue;

                if (matchesSearch && matchesStatus) {
                    row.style.display = '';
                    anime({
                        targets: row,
                        opacity: [0, 1],
                        translateX: [-20, 0],
                        duration: 400,
                        easing: 'easeOutQuad'
                    });
                } else {
                    row.style.display = 'none';
                }
            });
        }

        searchInput.addEventListener('input', filterTable);
        statusFilter.addEventListener('change', filterTable);

        function resetFilters() {
            searchInput.value = '';
            statusFilter.value = '';
            filterTable();
        }

        // Anime.js animations on load
        window.addEventListener('load', function() {
            // Fade in animations
            anime({
                targets: '.fade-in-up',
                translateY: [50, 0],
                opacity: [0, 1],
                duration: 1000,
                delay: anime.stagger(100),
                easing: 'easeOutExpo'
            });

            anime({
                targets: '.fade-in-down',
                translateY: [-50, 0],
                opacity: [0, 1],
                duration: 1000,
                delay: anime.stagger(100),
                easing: 'easeOutExpo'
            });

            // Table rows animation
            anime({
                targets: '.table-row',
                translateX: [-50, 0],
                opacity: [0, 1],
                duration: 800,
                delay: anime.stagger(50),
                easing: 'easeOutQuad'
            });

            // Counter animation
            document.querySelectorAll('.stat-value').forEach(counter => {
                const target = parseInt(counter.textContent);
                let current = 0;
                const increment = target / 30;
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= target) {
                        counter.textContent = target;
                        clearInterval(timer);
                    } else {
                        counter.textContent = Math.floor(current);
                    }
                }, 30);
            });
        });

        // Row click animation
        document.querySelectorAll('.table-row').forEach(row => {
            row.addEventListener('click', function(e) {
                if (!e.target.closest('button')) {
                    anime({
                        targets: this,
                        scale: [1, 1.02, 1],
                        duration: 400,
                        easing: 'easeInOutQuad'
                    });
                }
            });
        });

        // Button hover effects
        document.querySelectorAll('.btn-magical').forEach(btn => {
            btn.addEventListener('mouseenter', function() {
                anime({
                    targets: this,
                    scale: 1.05,
                    duration: 200,
                    easing: 'easeOutQuad'
                });
            });

            btn.addEventListener('mouseleave', function() {
                anime({
                    targets: this,
                    scale: 1,
                    duration: 200,
                    easing: 'easeOutQuad'
                });
            });
        });

        // Stat cards hover animation
        document.querySelectorAll('.stat-card-hover').forEach(card => {
            card.addEventListener('mouseenter', function() {
                anime({
                    targets: this.querySelector('.stat-figure'),
                    rotate: [0, 360],
                    duration: 600,
                    easing: 'easeInOutQuad'
                });
            });
        });
    </script>
    
    </div><!-- End main-content-with-sidebar -->
</body>
</html>
