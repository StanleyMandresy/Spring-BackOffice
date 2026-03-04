<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📅 Planification des Transports</title>
    
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

        /* Floating animation */
        @keyframes floating {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-25px) rotate(10deg); }
        }

        .floating {
            animation: floating 4s ease-in-out infinite;
        }

        /* Calendar pulse */
        @keyframes calendarPulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 20px rgba(135, 152, 106, 0.3); }
            50% { transform: scale(1.05); box-shadow: 0 0 40px rgba(135, 152, 106, 0.6); }
        }

        .calendar-pulse {
            animation: calendarPulse 3s ease-in-out infinite;
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
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(135, 152, 106, 0.6);
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

        /* Input glow */
        .input-glow:focus {
            box-shadow: 0 0 30px rgba(135, 152, 106, 0.5);
            border-color: #87986A !important;
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

        /* Feature card hover */
        .feature-card {
            transition: all 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(135, 152, 106, 0.3);
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <%@ include file="../components/sidebar.jsp" %>
    
    <!-- Main Content with Sidebar -->
    <div class="main-content-with-sidebar">
        <!-- Floating particles -->
    <% for(int i = 0; i < 25; i++) { %>
        <div class="particle" style="left: <%= Math.random() * 100 %>%; animation-delay: <%= Math.random() * 30 %>s; width: <%= 6 + Math.random() * 8 %>px; height: <%= 6 + Math.random() * 8 %>px;"></div>
    <% } %>

    <div class="container mx-auto px-4 py-8 md:py-12">
        <div class="max-w-5xl mx-auto">
            
            <!-- Main Card -->
            <div class="glass-card rounded-3xl shadow-2xl overflow-hidden fade-in-up">
                
                <!-- Header -->
                <div class="bg-gradient-to-br from-[#B5C99A] via-[#97A97C] to-[#87986A] p-8 md:p-12">
                    <div class="text-center fade-in-down">
                        <div class="text-8xl mb-4 floating inline-block">📅</div>
                        <h1 class="text-5xl md:text-6xl font-extrabold text-white mb-3 drop-shadow-2xl">
                            Planification des Transports
                        </h1>
                        <p class="text-white/90 text-xl md:text-2xl font-medium">
                            <i class="bi bi-calendar3"></i>
                            Organisez vos trajets avec précision
                        </p>
                    </div>
                </div>

                <!-- Content Area -->
                <div class="p-8 md:p-12">
                    
                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-error shadow-xl mb-8 fade-in-up">
                            <i class="fas fa-exclamation-triangle text-3xl"></i>
                            <div>
                                <h3 class="font-bold text-lg">Erreur</h3>
                                <div class="text-base">${error}</div>
                            </div>
                        </div>
                    </c:if>

                    <!-- Form Container -->
                    <div class="grid md:grid-cols-2 gap-8">
                        
                        <!-- Left Side - Form -->
                        <div class="fade-in-up" style="animation-delay: 0.1s">
                            <div class="glass-card rounded-2xl p-8 calendar-pulse">
                                <div class="text-center mb-6">
                                    <div class="text-6xl mb-3">🗓️</div>
                                    <h2 class="text-3xl font-extrabold gradient-text mb-2">
                                        Sélectionner la Date
                                    </h2>
                                    <p class="text-gray-600">
                                        Choisissez la date pour visualiser le planning
                                    </p>
                                </div>

                                <form action="${pageContext.request.contextPath}/planification/planifier" method="post" id="planningForm" class="space-y-6">
                                    <div class="form-control">
                                        <label class="label">
                                            <span class="label-text font-bold text-xl" style="color: #718355;">
                                                <i class="fas fa-calendar-alt"></i> Date du Planning
                                            </span>
                                        </label>
                                        <div class="relative">
                                            <span class="absolute left-4 top-1/2 -translate-y-1/2 text-3xl" style="color: #87986A;">
                                                <i class="bi bi-calendar-event"></i>
                                            </span>
                                            <input 
                                                type="date" 
                                                id="date" 
                                                name="date" 
                                                class="input input-bordered w-full pl-16 text-lg font-semibold input-glow"
                                                required
                                                style="border: 3px solid #B5C99A; height: 60px;"
                                            />
                                        </div>
                                        <div class="label">
                                            <span class="label-text-alt">
                                                <i class="fas fa-info-circle"></i>
                                                Format: JJ/MM/AAAA
                                            </span>
                                        </div>
                                    </div>

                                    <button type="submit" class="btn btn-magical btn-lg w-full text-white shine">
                                        <i class="fas fa-calendar-check text-2xl"></i>
                                        <span class="font-bold text-xl">Générer le Planning</span>
                                        <i class="fas fa-arrow-right text-xl"></i>
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Right Side - Features -->
                        <div class="space-y-4 fade-in-up" style="animation-delay: 0.2s">
                            <h3 class="text-2xl font-bold gradient-text mb-6 text-center md:text-left">
                                <i class="fas fa-star"></i> Fonctionnalités
                            </h3>

                            <div class="feature-card glass-card rounded-xl p-6">
                                <div class="flex items-start gap-4">
                                    <div class="text-5xl">🚗</div>
                                    <div>
                                        <h4 class="font-bold text-lg mb-2" style="color: #718355;">Attribution Automatique</h4>
                                        <p class="text-gray-600">Les véhicules sont assignés automatiquement selon la capacité et la disponibilité</p>
                                    </div>
                                </div>
                            </div>

                            <div class="feature-card glass-card rounded-xl p-6">
                                <div class="flex items-start gap-4">
                                    <div class="text-5xl">⏰</div>
                                    <div>
                                        <h4 class="font-bold text-lg mb-2" style="color: #718355;">Horaires Optimisés</h4>
                                        <p class="text-gray-600">Calcul intelligent des heures de départ, arrivée et retour pour chaque trajet</p>
                                    </div>
                                </div>
                            </div>

                            <div class="feature-card glass-card rounded-xl p-6">
                                <div class="flex items-start gap-4">
                                    <div class="text-5xl">📊</div>
                                    <div>
                                        <h4 class="font-bold text-lg mb-2" style="color: #718355;">Vue d'Ensemble</h4>
                                        <p class="text-gray-600">Visualisez toutes les réservations et annulations en un coup d'œil</p>
                                    </div>
                                </div>
                            </div>

                            <div class="feature-card glass-card rounded-xl p-6">
                                <div class="flex items-start gap-4">
                                    <div class="text-5xl">✅</div>
                                    <div>
                                        <h4 class="font-bold text-lg mb-2" style="color: #718355;">Gestion Simplifiée</h4>
                                        <p class="text-gray-600">Interface claire pour gérer efficacement votre flotte de transport</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    <!-- Info Cards -->
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12 fade-in-up" style="animation-delay: 0.3s">
                        <div class="glass-card rounded-2xl p-6 text-center feature-card">
                            <div class="text-5xl mb-3">🎯</div>
                            <h3 class="font-bold text-lg gradient-text mb-2">Précision</h3>
                            <p class="text-gray-600">Planning minutieux au service de vos clients</p>
                        </div>
                        <div class="glass-card rounded-2xl p-6 text-center feature-card">
                            <div class="text-5xl mb-3">⚡</div>
                            <h3 class="font-bold text-lg gradient-text mb-2">Rapidité</h3>
                            <p class="text-gray-600">Génération instantanée du planning</p>
                        </div>
                        <div class="glass-card rounded-2xl p-6 text-center feature-card">
                            <div class="text-5xl mb-3">🔒</div>
                            <h3 class="font-bold text-lg gradient-text mb-2">Fiabilité</h3>
                            <p class="text-gray-600">Système éprouvé et sécurisé</p>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Footer -->
            <div class="mt-8 text-center text-white fade-in-up" style="animation-delay: 0.4s">
                <p class="text-xl font-semibold drop-shadow-lg">
                    <i class="fas fa-clock"></i>
                    Système de planification intelligente
                    <i class="fas fa-route"></i>
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
                easing: 'easeOutExpo'
            });

            // Feature cards entrance
            anime({
                targets: '.feature-card',
                scale: [0.9, 1],
                opacity: [0, 1],
                duration: 800,
                delay: anime.stagger(100),
                easing: 'easeOutElastic(1, .8)'
            });
        });

        // Form submission animation
        document.getElementById('planningForm').addEventListener('submit', function(e) {
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin text-2xl"></i> <span class="font-bold">Génération en cours...</span>';
            
            anime({
                targets: submitBtn,
                scale: [1, 0.95, 1],
                duration: 1000,
                loop: true,
                easing: 'easeInOutQuad'
            });
        });

        // Date input animation
        const dateInput = document.getElementById('date');
        dateInput.addEventListener('change', function() {
            anime({
                targets: this,
                scale: [1, 1.05, 1],
                duration: 400,
                easing: 'easeOutElastic(1, .8)'
            });
        });

        // Set today as min date
        const today = new Date().toISOString().split('T')[0];
        dateInput.setAttribute('min', today);
    </script>
    
    </div><!-- End main-content-with-sidebar -->
</body>
</html>