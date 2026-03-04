<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚗 Fleet Management - Véhicules</title>
    
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
            width: 10px;
            height: 10px;
            background: rgba(255, 255, 255, 0.7);
            border-radius: 50%;
            pointer-events: none;
            animation: float 30s infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0) translateX(0) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(-100vh) translateX(100px) rotate(360deg); opacity: 0; }
        }

        /* Glassmorphism */
        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border: 2px solid rgba(255, 255, 255, 0.6);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }

        /* Fade animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .fade-in-up {
            animation: fadeInUp 0.8s ease-out forwards;
        }

        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .fade-in-down {
            animation: fadeInDown 0.8s ease-out forwards;
        }

        /* 3D Card effect */
        .card-3d {
            transform-style: preserve-3d;
            transition: transform 0.5s ease;
        }

        .card-3d:hover {
            transform: rotateY(5deg) rotateX(5deg) scale(1.02);
        }

        /* Floating animation */
        @keyframes floating {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Pulse glow */
        @keyframes pulseGlow {
            0%, 100% { box-shadow: 0 0 20px rgba(135, 152, 106, 0.5); }
            50% { box-shadow: 0 0 40px rgba(135, 152, 106, 0.8); }
        }

        .pulse-glow {
            animation: pulseGlow 2s ease-in-out infinite;
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
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.5), transparent);
            transition: left 0.6s;
        }

        .shine:hover::before {
            left: 100%;
        }

        /* Vehicle card hover */
        .vehicle-card {
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        .vehicle-card:hover {
            transform: translateY(-15px) scale(1.03);
            box-shadow: 0 25px 50px rgba(135, 152, 106, 0.4);
        }

        /* Badge animations */
        .badge-fuel {
            animation: pulse 3s ease-in-out infinite;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        /* Button magical */
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

        /* Gradient text */
        .gradient-text {
            background: linear-gradient(135deg, #718355 0%, #87986A 50%, #97A97C 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 14px;
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

        /* Modal backdrop */
        .modal-backdrop {
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        /* Stats counter */
        @keyframes countUp {
            from { opacity: 0; transform: scale(0.5); }
            to { opacity: 1; transform: scale(1); }
        }

        .count-animation {
            animation: countUp 0.6s ease-out;
        }

        /* Empty state */
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-30px); }
            60% { transform: translateY(-15px); }
        }

        .bounce {
            animation: bounce 2s ease infinite;
        }

        /* Car icon animation */
        @keyframes carDrive {
            0% { transform: translateX(-100px); opacity: 0; }
            50% { opacity: 1; }
            100% { transform: translateX(100px); opacity: 0; }
        }

        .car-drive {
            animation: carDrive 3s ease-in-out infinite;
        }
    </style>
</head>
<body class="relative">
    <!-- Include Sidebar -->
    <%@ include file="../components/sidebar.jsp" %>
    
    <!-- Main Content with Sidebar -->
    <div class="main-content-with-sidebar">
        <!-- Floating particles -->
    <% for(int i = 0; i < 25; i++) { %>
        <div class="particle" style="left: <%= Math.random() * 100 %>%; animation-delay: <%= Math.random() * 30 %>s; width: <%= 6 + Math.random() * 8 %>px; height: <%= 6 + Math.random() * 8 %>px;"></div>
    <% } %>

    <div class="container mx-auto px-4 py-8 md:py-12">
        <div class="max-w-7xl mx-auto">
            
            <!-- Main Card -->
            <div class="glass-card rounded-3xl shadow-2xl overflow-hidden">
                
                <!-- Header -->
                <div class="bg-gradient-to-br from-[#B5C99A] via-[#97A97C] to-[#87986A] p-8 md:p-12 relative overflow-hidden">
                    <!-- Animated background pattern -->
                    <div class="absolute inset-0 opacity-10">
                        <div class="car-drive text-9xl absolute top-1/2 left-0">🚗</div>
                    </div>
                    
                    <div class="flex flex-col md:flex-row justify-between items-center gap-6 relative z-10">
                        <div class="text-center md:text-left fade-in-down">
                            <div class="text-6xl mb-4 floating inline-block">🚗</div>
                            <h1 class="text-4xl md:text-6xl font-extrabold text-white mb-3 drop-shadow-2xl">
                                Fleet Management
                            </h1>
                            <p class="text-white/90 text-xl font-medium">
                                <i class="bi bi-speedometer2"></i>
                                Gestion complète de votre parc automobile
                            </p>
                        </div>
                        <div class="flex gap-3 fade-in-down" style="animation-delay: 0.2s">
                            <a href="${pageContext.request.contextPath}/vehicule/form" class="btn btn-magical btn-lg text-white shine">
                                <i class="fas fa-plus-circle text-2xl"></i>
                                <span class="font-bold">Ajouter Véhicule</span>
                            </a>
                        </div>
                    </div>

                    <!-- Search Bar -->
                    <div class="mt-8 fade-in-up" style="animation-delay: 0.3s">
                        <div class="relative max-w-2xl mx-auto">
                            <input 
                                type="text" 
                                id="searchInput" 
                                placeholder="🔍 Rechercher par référence, type de carburant..." 
                                class="input input-bordered w-full bg-white/95 backdrop-blur-sm text-gray-800 font-medium text-lg"
                                style="box-shadow: 0 0 30px rgba(255, 255, 255, 0.5);"
                            />
                            <i class="fas fa-search absolute right-5 top-1/2 -translate-y-1/2 text-gray-400 text-2xl"></i>
                        </div>
                    </div>
                </div>

                <!-- Content Area -->
                <div class="p-6 md:p-10">
                    
                    <!-- Messages -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-error shadow-xl mb-8 fade-in-up">
                            <i class="fas fa-exclamation-triangle text-3xl"></i>
                            <div>
                                <h3 class="font-bold text-lg">Erreur</h3>
                                <div class="text-base">${error}</div>
                            </div>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty success}">
                        <div class="alert alert-success shadow-xl mb-8 fade-in-up">
                            <i class="fas fa-check-circle text-3xl"></i>
                            <div>
                                <h3 class="font-bold text-lg">Succès</h3>
                                <div class="text-base">${success}</div>
                            </div>
                        </div>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty vehicules}">
                            <!-- Statistics Bar -->
                            <div class="stats stats-vertical lg:stats-horizontal shadow-2xl w-full mb-10 fade-in-up" style="animation-delay: 0.2s; background: linear-gradient(135deg, #E9F5DB, #CFE1B9);">
                                <div class="stat">
                                    <div class="stat-figure" style="color: #718355;">
                                        <i class="fas fa-car-side text-5xl"></i>
                                    </div>
                                    <div class="stat-title font-bold text-lg" style="color: #718355;">Total Véhicules</div>
                                    <div class="stat-value count-animation gradient-text" id="totalCount">${not empty total ? total : vehicules.size()}</div>
                                    <div class="stat-desc font-semibold" style="color: #87986A;">Dans le parc</div>
                                </div>
                                
                                <div class="stat">
                                    <div class="stat-figure text-yellow-600">
                                        <i class="fas fa-gas-pump text-5xl"></i>
                                    </div>
                                    <div class="stat-title font-bold text-lg text-yellow-800">Diesel</div>
                                    <div class="stat-value text-yellow-600 count-animation" id="dieselCount">
                                        <c:set var="dieselCount" value="0"/>
                                        <c:forEach var="v" items="${vehicules}">
                                            <c:if test="${v.typeCarburant == 'D'}">
                                                <c:set var="dieselCount" value="${dieselCount + 1}"/>
                                            </c:if>
                                        </c:forEach>
                                        ${dieselCount}
                                    </div>
                                    <div class="stat-desc font-semibold text-yellow-700">Véhicules</div>
                                </div>
                                
                                <div class="stat">
                                    <div class="stat-figure text-green-600">
                                        <i class="fas fa-leaf text-5xl"></i>
                                    </div>
                                    <div class="stat-title font-bold text-lg text-green-800">Essence</div>
                                    <div class="stat-value text-green-600 count-animation" id="essenceCount">
                                        <c:set var="essenceCount" value="0"/>
                                        <c:forEach var="v" items="${vehicules}">
                                            <c:if test="${v.typeCarburant == 'ES' || v.typeCarburant == 'S'}">
                                                <c:set var="essenceCount" value="${essenceCount + 1}"/>
                                            </c:if>
                                        </c:forEach>
                                        ${essenceCount}
                                    </div>
                                    <div class="stat-desc font-semibold text-green-700">Véhicules</div>
                                </div>
                                
                                <div class="stat">
                                    <div class="stat-figure text-purple-600">
                                        <i class="fas fa-bolt text-5xl"></i>
                                    </div>
                                    <div class="stat-title font-bold text-lg text-purple-800">Électrique</div>
                                    <div class="stat-value text-purple-600 count-animation" id="electricCount">
                                        <c:set var="electricCount" value="0"/>
                                        <c:forEach var="v" items="${vehicules}">
                                            <c:if test="${v.typeCarburant == 'E'}">
                                                <c:set var="electricCount" value="${electricCount + 1}"/>
                                            </c:if>
                                        </c:forEach>
                                        ${electricCount}
                                    </div>
                                    <div class="stat-desc font-semibold text-purple-700">Véhicules</div>
                                </div>
                            </div>

                            <!-- Vehicle Cards Grid -->
                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="vehicleGrid">
                                <c:forEach var="vehicule" items="${vehicules}" varStatus="status">
                                    <div class="vehicle-card card glass-card shadow-xl fade-in-up vehicle-item" 
                                         style="animation-delay: ${status.index * 0.1}s"
                                         data-reference="${vehicule.reference}" 
                                         data-fuel="${vehicule.typeCarburant}">
                                        
                                        <!-- Card Header with Fuel Badge -->
                                        <div class="relative">
                                            <div class="absolute top-4 right-4 z-10">
                                                <c:choose>
                                                    <c:when test="${vehicule.typeCarburant == 'D'}">
                                                        <div class="badge badge-lg badge-fuel font-bold" style="background: linear-gradient(135deg, #fbbf24, #f59e0b); color: white;">
                                                            <i class="fas fa-gas-pump mr-1"></i> DIESEL
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${vehicule.typeCarburant == 'ES'}">
                                                        <div class="badge badge-lg badge-fuel font-bold" style="background: linear-gradient(135deg, #10b981, #059669); color: white;">
                                                            <i class="fas fa-leaf mr-1"></i> ESSENCE
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${vehicule.typeCarburant == 'S'}">
                                                        <div class="badge badge-lg badge-fuel font-bold" style="background: linear-gradient(135deg, #06b6d4, #0891b2); color: white;">
                                                            <i class="fas fa-star mr-1"></i> SUPER
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${vehicule.typeCarburant == 'E'}">
                                                        <div class="badge badge-lg badge-fuel font-bold" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white;">
                                                            <i class="fas fa-bolt mr-1"></i> ÉLECTRIQUE
                                                        </div>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                            
                                            <!-- Car Icon -->
                                            <div class="p-8 bg-gradient-to-br from-[#E9F5DB] to-[#CFE1B9] flex items-center justify-center">
                                                <div class="text-8xl">🚗</div>
                                            </div>
                                        </div>
                                        
                                        <div class="card-body">
                                            <h2 class="card-title text-2xl font-extrabold gradient-text">
                                                <i class="bi bi-car-front-fill"></i>
                                                ${vehicule.reference}
                                            </h2>
                                            
                                            <div class="divider my-2"></div>
                                            
                                            <div class="space-y-3">
                                                <div class="flex items-center gap-3 p-3 rounded-lg" style="background: rgba(181, 201, 154, 0.1);">
                                                    <div class="text-3xl" style="color: #87986A;">
                                                        <i class="fas fa-hashtag"></i>
                                                    </div>
                                                    <div>
                                                        <p class="text-sm font-semibold text-gray-500">ID</p>
                                                        <p class="text-xl font-bold" style="color: #718355;">${vehicule.id}</p>
                                                    </div>
                                                </div>
                                                
                                                <div class="flex items-center gap-3 p-3 rounded-lg" style="background: rgba(181, 201, 154, 0.1);">
                                                    <div class="text-3xl" style="color: #87986A;">
                                                        <i class="fas fa-users"></i>
                                                    </div>
                                                    <div>
                                                        <p class="text-sm font-semibold text-gray-500">Capacité</p>
                                                        <p class="text-xl font-bold" style="color: #718355;">${vehicule.nbrPlace} places</p>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="card-actions justify-end mt-4 gap-2">
                                                <a href="${pageContext.request.contextPath}/vehicule/edit?id=${vehicule.id}" 
                                                   class="btn btn-sm shine" 
                                                   style="background: #87986A; color: white;">
                                                    <i class="fas fa-edit"></i>
                                                    Modifier
                                                </a>
                                                <button onclick="showDeleteModal(${vehicule.id}, '${vehicule.reference}')" 
                                                        class="btn btn-sm btn-error">
                                                    <i class="fas fa-trash"></i>
                                                    Supprimer
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                        </c:when>
                        <c:otherwise>
                            <!-- Empty State -->
                            <div class="text-center py-20 fade-in-up">
                                <div class="text-9xl mb-8 bounce">🚗</div>
                                <h2 class="text-5xl font-extrabold mb-4 gradient-text">
                                    Aucun véhicule
                                </h2>
                                <p class="text-2xl text-gray-600 mb-8">
                                    Votre parc automobile est vide
                                </p>
                                <a href="${pageContext.request.contextPath}/vehicule/form" class="btn btn-magical btn-lg text-white shine">
                                    <i class="fas fa-plus-circle text-2xl"></i>
                                    <span class="font-bold text-lg">Ajouter le Premier Véhicule</span>
                                    <i class="fas fa-arrow-right text-xl"></i>
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </div>
            </div>

            <!-- Footer -->
            <div class="mt-8 text-center text-white fade-in-up" style="animation-delay: 0.8s">
                <p class="text-xl font-semibold drop-shadow-lg">
                    <i class="fas fa-shield-alt"></i>
                    Système de gestion de flotte automobile
                    <i class="fas fa-cog"></i>
                </p>
            </div>

        </div>
    </div>

    <!-- Delete Modal (DaisyUI) -->
    <input type="checkbox" id="deleteModal" class="modal-toggle" />
    <div class="modal modal-backdrop">
        <div class="modal-box glass-card max-w-md">
            <h3 class="font-bold text-2xl mb-4 gradient-text">
                <i class="fas fa-exclamation-triangle text-red-500"></i>
                Confirmer la suppression
            </h3>
            <p class="text-lg mb-2">
                Êtes-vous sûr de vouloir supprimer le véhicule 
                <span class="font-extrabold" style="color: #718355;" id="vehiculeRef"></span> ?
            </p>
            <p class="text-red-600 font-bold mb-6">
                <i class="fas fa-exclamation-circle"></i>
                Cette action est irréversible !
            </p>
            
            <div class="modal-action">
                <form id="deleteForm" action="${pageContext.request.contextPath}/vehicule/delete" method="post">
                    <input type="hidden" name="id" id="deleteId">
                    <button type="submit" class="btn btn-error btn-lg gap-2">
                        <i class="fas fa-trash"></i>
                        Oui, supprimer
                    </button>
                </form>
                <label for="deleteModal" class="btn btn-outline btn-lg gap-2">
                    <i class="fas fa-times"></i>
                    Annuler
                </label>
            </div>
        </div>
    </div>

    <script>
        // Search functionality
        const searchInput = document.getElementById('searchInput');
        const vehicleCards = document.querySelectorAll('.vehicle-item');

        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                
                vehicleCards.forEach(card => {
                    const reference = card.getAttribute('data-reference').toLowerCase();
                    const fuel = card.getAttribute('data-fuel').toLowerCase();
                    
                    if (reference.includes(searchTerm) || fuel.includes(searchTerm)) {
                        card.style.display = '';
                        anime({
                            targets: card,
                            opacity: [0, 1],
                            scale: [0.8, 1],
                            duration: 400,
                            easing: 'easeOutQuad'
                        });
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        }

        // Delete modal functions
        function showDeleteModal(id, reference) {
            document.getElementById('deleteId').value = id;
            document.getElementById('vehiculeRef').textContent = reference;
            document.getElementById('deleteModal').checked = true;
        }

        // Anime.js animations on load
        window.addEventListener('load', function() {
            // Fade in animations
            anime({
                targets: '.fade-in-up',
                translateY: [60, 0],
                opacity: [0, 1],
                duration: 1000,
                delay: anime.stagger(100),
                easing: 'easeOutExpo'
            });

            anime({
                targets: '.fade-in-down',
                translateY: [-60, 0],
                opacity: [0, 1],
                duration: 1000,
                delay: anime.stagger(100),
                easing: 'easeOutExpo'
            });

            // Counter animation
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

            // Vehicle cards entrance animation
            anime({
                targets: '.vehicle-card',
                scale: [0.8, 1],
                opacity: [0, 1],
                duration: 800,
                delay: anime.stagger(100),
                easing: 'easeOutElastic(1, .8)'
            });
        });

        // Vehicle card 3D tilt effect
        document.querySelectorAll('.vehicle-card').forEach(card => {
            card.addEventListener('mousemove', function(e) {
                const rect = this.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 20;
                const rotateY = (centerX - x) / 20;
                
                this.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.05)`;
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale(1)';
            });
        });

        // Button hover effects
        document.querySelectorAll('.btn-magical').forEach(btn => {
            btn.addEventListener('mouseenter', function() {
                anime({
                    targets: this,
                    scale: 1.05,
                    rotate: '2deg',
                    duration: 200,
                    easing: 'easeOutQuad'
                });
            });

            btn.addEventListener('mouseleave', function() {
                anime({
                    targets: this,
                    scale: 1,
                    rotate: '0deg',
                    duration: 200,
                    easing: 'easeOutQuad'
                });
            });
        });
    </script>
    
    </div><!-- End main-content-with-sidebar -->
</body>
</html>