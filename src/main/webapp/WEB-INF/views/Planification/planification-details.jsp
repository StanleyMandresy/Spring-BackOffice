<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 Planning du ${date}</title>
    
    <!-- Tailwind CSS + DaisyUI -->
    <link href="https://cdn.jsdelivr.net/npm/daisyui@4.7.2/dist/full.min.css" rel="stylesheet" type="text/css" />
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <!-- Anime.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #F6FAFD 0%, #B3CFE5 25%, #4A7FA7 50%, #4A7FA7 75%, #1A3D63 100%);
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

        /* Fade animations */
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

        /* Floating animation */
        @keyframes floating {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
        }

        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Timeline animation */
        @keyframes timelineSlide {
            from { width: 0; opacity: 0; }
            to { width: 100%; opacity: 1; }
        }

        .timeline-animate {
            animation: timelineSlide 1s ease-out forwards;
        }

        /* Table row hover */
        .table-row {
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .table-row:hover {
            transform: translateX(10px);
            background: linear-gradient(90deg, rgba(181, 201, 154, 0.15), transparent) !important;
            box-shadow: -4px 0 0 0 #1A3D63;
        }

        /* Button magical */
        .btn-magical {
            position: relative;
            background: linear-gradient(135deg, #1A3D63 0%, #1A3D63 100%);
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

        /* Gradient text */
        .gradient-text {
            background: linear-gradient(135deg, #1A3D63 0%, #1A3D63 50%, #4A7FA7 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 12px;
        }

        ::-webkit-scrollbar-track {
            background: #F6FAFD;
        }

        ::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #1A3D63, #4A7FA7);
            border-radius: 10px;
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

        /* Pulse animation */
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        /* Badge animations */
        .badge-custom {
            animation: pulse 2s ease-in-out infinite;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body class="relative">
    <!-- Include Sidebar -->
  
    
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
                <div class="bg-gradient-to-br from-[#4A7FA7] via-[#4A7FA7] to-[#1A3D63] p-8 md:p-12">
                    <div class="flex flex-col md:flex-row justify-between items-center gap-6">
                        <div class="text-center md:text-left fade-in-down">
                            <div class="text-5xl mb-3 floating inline-block">🗓️</div>
                            <h1 class="text-4xl md:text-5xl font-extrabold text-white mb-2 drop-shadow-lg">
                                Planning des Transports
                            </h1>
                            <p class="text-white/90 text-xl font-medium">
                                <i class="bi bi-calendar-check"></i>
                                Date : <span class="font-bold">${date}</span>
                            </p>
                        </div>
                        <div class="flex gap-3 fade-in-down" style="animation-delay: 0.2s">
                            <a href="${pageContext.request.contextPath}/planification/planification" class="btn btn-magical btn-lg text-white shine">
                                <i class="fas fa-arrow-left text-xl"></i>
                                <span class="font-bold">Retour</span>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Content Area -->
                <div class="p-6 md:p-10">
                    
                    <!-- Statistics -->
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10 fade-in-up" style="animation-delay: 0.1s">
                        <div class="stat bg-gradient-to-br from-[#F6FAFD] to-[#B3CFE5] rounded-2xl shadow-xl border-2" style="border-color: #4A7FA7;">
                            <div class="stat-figure" style="color: #1A3D63;">
                                <i class="fas fa-car text-4xl"></i>
                            </div>
                            <div class="stat-title font-bold" style="color: #1A3D63;">Véhicules</div>
                            <div class="stat-value gradient-text">
                                <c:set var="vehicleCount" value="0"/>
                                <c:forEach var="p" items="${planningList}">
                                    <c:set var="vehicleCount" value="${vehicleCount + 1}"/>
                                </c:forEach>
                                ${vehicleCount}
                            </div>
                        </div>

                        <div class="stat bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl shadow-xl border-2 border-blue-300">
                            <div class="stat-figure text-blue-600">
                                <i class="fas fa-tasks text-4xl"></i>
                            </div>
                            <div class="stat-title font-bold text-blue-800">Trajets</div>
                            <div class="stat-value text-blue-600">
                                <c:set var="activeCount" value="0"/>
                                <c:forEach var="p" items="${planningList}">
                                    <c:if test="${p.reservation != null}">
                                        <c:set var="activeCount" value="${activeCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${activeCount}
                            </div>
                        </div>

                        <div class="stat bg-gradient-to-br from-yellow-50 to-yellow-100 rounded-2xl shadow-xl border-2 border-yellow-300">
                            <div class="stat-figure text-yellow-600">
                                <i class="fas fa-ban text-4xl"></i>
                            </div>
                            <div class="stat-title font-bold text-yellow-800">Annulées</div>
                            <div class="stat-value text-yellow-600">
                                ${not empty annuleList ? annuleList.size() : 0}
                            </div>
                        </div>

                        <div class="stat bg-gradient-to-br from-purple-50 to-purple-100 rounded-2xl shadow-xl border-2 border-purple-300">
                            <div class="stat-figure text-purple-600">
                                <i class="fas fa-users text-4xl"></i>
                            </div>
                            <div class="stat-title font-bold text-purple-800">Passagers</div>
                            <div class="stat-value text-purple-600">
                                <c:set var="totalPassengers" value="0"/>
                                <c:forEach var="p" items="${planningList}">
                                    <c:if test="${p.reservation != null}">
                                        <c:set var="totalPassengers" value="${totalPassengers + p.reservation.nombrePassagers}"/>
                                    </c:if>
                                </c:forEach>
                                ${totalPassengers}
                            </div>
                        </div>
                    </div>

                    <!-- Main Planning Section -->
                    <div class="mb-10">
                        <h2 class="text-3xl font-extrabold gradient-text mb-6 text-center fade-in-up" style="animation-delay: 0.2s">
                            <i class="fas fa-route"></i> Planning des Trajets
                        </h2>

                        <div class="overflow-x-auto rounded-2xl shadow-2xl fade-in-up" style="animation-delay: 0.3s">
                            <table class="table table-zebra w-full">
                                <thead class="bg-gradient-to-r from-[#4A7FA7] to-[#4A7FA7]">
                                    <tr class="text-white">
                                        <th class="text-base">
                                            <i class="bi bi-car-front"></i> Véhicule
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-bookmark"></i> Réservation
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-play-circle"></i> Départ
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-building"></i> Arrivée Hôtel
                                        </th>
                                        <th class="text-base">
                                            <i class="bi bi-arrow-return-left"></i> Retour Aéroport
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="p" items="${planningList}" varStatus="status">
                                        <tr class="table-row hover" style="animation-delay: ${status.index * 0.05}s">
                                            <td>
                                                <div class="flex items-center gap-3">
                                                    <div class="text-3xl" style="color: #1A3D63;">
                                                        🚗
                                                    </div>
                                                    <div>
                                                        <div class="font-bold text-lg" style="color: #1A3D63;">${p.vehicule.reference}</div>
                                                        <div class="text-sm text-gray-500">
                                                            <i class="bi bi-people-fill"></i> ${p.vehicule.nbrPlace} places
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${p.reservation != null}">
                                                        <div class="flex flex-col gap-1">
                                                            <div class="font-semibold text-gray-800">
                                                                <i class="fas fa-user" style="color: #1A3D63;"></i>
                                                                ${p.reservation.idClient}
                                                            </div>
                                                            <div class="text-sm text-gray-600">
                                                                <i class="fas fa-hotel"></i> Hôtel ${p.reservation.idHotel} 
                                                            </div>
                                                            <div class="badge badge-sm" style="background: #F6FAFD; color: #1A3D63; border: 2px solid #4A7FA7;">
                                                                <i class="bi bi-people"></i> ${p.reservation.nombrePassagers} passagers
                                                            </div>
                                                            <div class="badge badge-sm" style="background: #F6FAFD; color: #1A3D63; border: 2px solid #4A7FA7;">
                                                                <i class="bi bi-people"></i> ${p.nombrePassagersTransportes} passagers transportés
                                                            </div>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-gray-400 italic">---</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                 <div class="badge badge-lg" style="background: #4A7FA7; color: white;">
                                                <i class=""></i>
                                                ${p.heureDepart.hour < 10 ? '0' : ''}${p.heureDepart.hour}:
                                                ${p.heureDepart.minute < 10 ? '0' : ''}${p.heureDepart.minute}
                                            </div>
                                            </td>
                                            <td>
                                              <div class="badge badge-lg" style="background: #4A7FA7; color: white;">
                                                <i class=""></i>
                                                ${p.heureArrive.hour < 10 ? '0' : ''}${p.heureArrive.hour}:
                                                ${p.heureArrive.minute < 10 ? '0' : ''}${p.heureArrive.minute}
                                            </div>
                                                                                        </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${p.heureRetour != null}">
                                                        
                                                           <div class="badge badge-lg" style="background: #4A7FA7; color: white;">
                                                        <i class=""></i>
                                                        ${p.heureRetour.hour < 10 ? '0' : ''}${p.heureRetour.hour}:
                                                        ${p.heureRetour.minute < 10 ? '0' : ''}${p.heureRetour.minute}
                                                    </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-gray-400 italic">---</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Cancelled Reservations Section -->
                    <c:if test="${not empty annuleList}">
                        <div class="fade-in-up" style="animation-delay: 0.4s">
                            <div class="divider"></div>
                            <h2 class="text-3xl font-extrabold text-center mb-6" style="color: #dc2626;">
                                <i class="fas fa-times-circle"></i> Réservations Annulées
                            </h2>

                            <div class="overflow-x-auto rounded-2xl shadow-2xl">
                                <table class="table table-zebra w-full">
                                    <thead class="bg-gradient-to-r from-red-400 to-red-500">
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
                                                <i class="bi bi-chat-left-text"></i> Commentaire
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="res" items="${annuleList}" varStatus="status">
                                            <tr class="table-row hover" style="animation-delay: ${status.index * 0.05}s">
                                                <td class="font-bold text-lg text-red-600">
                                                    #${res.idReservation}
                                                </td>
                                                <td>
                                                    <div class="flex items-center gap-3">
                                                        <div class="avatar placeholder">
                                                            <div class="bg-red-200 text-red-800 rounded-full w-12 h-12 flex items-center justify-center">
                                                                <span class="text-xl font-bold">${res.idClient.substring(0, 1).toUpperCase()}</span>
                                                            </div>
                                                        </div>
                                                        <div class="font-semibold text-gray-800">${res.idClient}</div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="font-semibold text-gray-800">
                                                        <i class="fas fa-hotel text-red-500"></i>
                                                        ${res.nomHotel != null ? res.nomHotel : 'Hôtel #'.concat(res.idHotel)}
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="badge badge-lg badge-error">
                                                        <i class="bi bi-people-fill"></i>
                                                        ${res.nombrePassagers} pers.
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-sm text-gray-600 italic">
                                                        ${res.commentaire != null ? res.commentaire : 'Aucun commentaire'}
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${empty annuleList}">
                        <div class="text-center py-10 fade-in-up" style="animation-delay: 0.4s">
                            <div class="text-6xl mb-4">✅</div>
                            <h3 class="text-2xl font-bold gradient-text">Aucune Annulation</h3>
                            <p class="text-gray-600 text-lg mt-2">Toutes les réservations sont actives pour cette date</p>
                        </div>
                    </c:if>

                </div>
            </div>

            <!-- Footer -->
            <div class="mt-8 text-center text-white fade-in-up" style="animation-delay: 0.5s">
                <p class="text-lg font-semibold drop-shadow-lg">
                    <i class="fas fa-chart-line"></i>
                    Planning généré automatiquement
                    <i class="fas fa-check-double"></i>
                </p>
            </div>

        </div>
    </div>

    <script>
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

            // Stats counter animation
            document.querySelectorAll('.stat-value').forEach(counter => {
                const textContent = counter.textContent.trim();
                const target = parseInt(textContent);
                if (!isNaN(target)) {
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
                }
            });
        });

        // Row click animation
        document.querySelectorAll('.table-row').forEach(row => {
            row.addEventListener('click', function(e) {
                anime({
                    targets: this,
                    scale: [1, 1.02, 1],
                    duration: 400,
                    easing: 'easeInOutQuad'
                });
            });
        });
    </script>
    
    </div><!-- End main-content-with-sidebar -->
</body>
</html>