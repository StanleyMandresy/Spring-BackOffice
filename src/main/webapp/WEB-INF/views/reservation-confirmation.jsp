<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.spring.BackOffice.model.Reservation" %>
<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>✨ Confirmation de Réservation</title>
    
    <!-- Tailwind CSS + DaisyUI -->
    <link href="https://cdn.jsdelivr.net/npm/daisyui@4.7.2/dist/full.min.css" rel="stylesheet" type="text/css" />
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Canvas Confetti -->
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.9.2/dist/confetti.browser.min.js"></script>
    
    <!-- Anime.js for animations -->
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

        /* Floating particles background */
        .particle {
            position: fixed;
            width: 10px;
            height: 10px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 50%;
            pointer-events: none;
            animation: float 20s infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0) translateX(0) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(-100vh) translateX(100px) rotate(360deg); opacity: 0; }
        }

        /* Glassmorphism effect */
        .glass-card {
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }

        .glass-card-solid {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.5);
        }

        /* Success icon animation */
        .success-checkmark {
            width: 100px;
            height: 100px;
            margin: 0 auto;
            position: relative;
        }

        .success-checkmark .check-icon {
            width: 100px;
            height: 100px;
            position: relative;
            border-radius: 50%;
            box-sizing: content-box;
            border: 4px solid #87986A;
            background: linear-gradient(135deg, #E9F5DB 0%, #CFE1B9 100%);
        }

        .success-checkmark .check-icon::before {
            top: 3px;
            left: -2px;
            width: 30px;
            transform-origin: 100% 50%;
            border-radius: 100px 0 0 100px;
        }

        .success-checkmark .check-icon::after {
            top: 0;
            left: 30px;
            width: 60px;
            transform-origin: 0 50%;
            border-radius: 0 100px 100px 0;
            animation: rotateCircle 4.25s ease-in;
        }

        .success-checkmark .check-icon .icon-line {
            height: 5px;
            background-color: #87986A;
            display: block;
            border-radius: 2px;
            position: absolute;
            z-index: 10;
        }

        .success-checkmark .check-icon .icon-line.line-tip {
            top: 46px;
            left: 14px;
            width: 25px;
            transform: rotate(45deg);
            animation: iconLineTip 0.75s;
        }

        .success-checkmark .check-icon .icon-line.line-long {
            top: 38px;
            right: 8px;
            width: 47px;
            transform: rotate(-45deg);
            animation: iconLineLong 0.75s;
        }

        @keyframes iconLineTip {
            0% { width: 0; left: 1px; top: 19px; }
            54% { width: 0; left: 1px; top: 19px; }
            70% { width: 50px; left: -8px; top: 37px; }
            84% { width: 17px; left: 21px; top: 48px; }
            100% { width: 25px; left: 14px; top: 45px; }
        }

        @keyframes iconLineLong {
            0% { width: 0; right: 46px; top: 54px; }
            65% { width: 0; right: 46px; top: 54px; }
            84% { width: 55px; right: 0px; top: 35px; }
            100% { width: 47px; right: 8px; top: 38px; }
        }

        /* Pulse animation */
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        /* Fade in up animation */
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

        /* Info card hover effect */
        .info-item {
            transition: all 0.3s ease;
            position: relative;
        }

        .info-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 4px;
            height: 0;
            background: linear-gradient(180deg, #87986A, #97A97C);
            transition: height 0.3s ease;
            border-radius: 2px;
        }

        .info-item:hover::before {
            height: 80%;
        }

        .info-item:hover {
            transform: translateX(8px);
            background: rgba(135, 152, 106, 0.12);
        }

        /* Floating animation */
        @keyframes floating {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Ripple effect */
        .ripple {
            position: relative;
            overflow: hidden;
        }

        .ripple::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .ripple:hover::after {
            width: 300px;
            height: 300px;
        }

        /* Custom badge styles */
        .custom-badge {
            background: linear-gradient(135deg, #87986A 0%, #97A97C 100%);
            color: white;
            padding: 8px 20px;
            border-radius: 50px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            box-shadow: 0 4px 15px rgba(135, 152, 106, 0.5);
            animation: pulse 2s ease-in-out infinite;
        }

        /* Glowing text */
        .glow-text {
            text-shadow: 0 0 10px rgba(151, 169, 124, 0.6),
                         0 0 20px rgba(151, 169, 124, 0.4),
                         0 0 30px rgba(151, 169, 124, 0.3);
        }

        /* 3D Card effect */
        .card-3d {
            transform-style: preserve-3d;
            transition: transform 0.6s;
        }

        .card-3d:hover {
            transform: rotateY(5deg) rotateX(5deg);
        }

        /* Gradient text */
        .gradient-text {
            background: linear-gradient(135deg, #718355 0%, #87986A 50%, #97A97C 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Button hover effects */
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
            box-shadow: 0 10px 25px rgba(135, 152, 106, 0.6);
        }

        /* Celebration stars */
        .star {
            position: fixed;
            font-size: 20px;
            animation: starFall 3s linear infinite;
            pointer-events: none;
            z-index: 9999;
        }

        @keyframes starFall {
            0% { top: -10%; transform: rotate(0deg); opacity: 1; }
            100% { top: 110%; transform: rotate(360deg); opacity: 0; }
        }
    </style>
</head>
<body class="relative">
    <!-- Floating particles -->
    <% for(int i = 0; i < 15; i++) { %>
        <div class="particle" style="left: <%= Math.random() * 100 %>%; animation-delay: <%= Math.random() * 20 %>s;"></div>
    <% } %>

    <div class="container mx-auto px-4 py-8 md:py-16">
        <%
            Boolean success = (Boolean) request.getAttribute("success");
            String error = (String) request.getAttribute("error");
            Reservation reservation = (Reservation) request.getAttribute("reservation");
            
            if (success != null && success && reservation != null) {
        %>
            <!-- SUCCESS PAGE -->
            <div class="max-w-4xl mx-auto">
                <!-- Main Card -->
                <div class="glass-card-solid rounded-3xl shadow-2xl overflow-hidden card-3d fade-in-up" style="animation-delay: 0.1s">
                    
                    <!-- Header with animated success icon -->
                    <div class="bg-gradient-to-br from-[#B5C99A] via-[#97A97C] to-[#87986A] p-12 text-center relative overflow-hidden">
                        <!-- Animated background circles -->
                        <div class="absolute top-0 left-0 w-72 h-72 bg-white opacity-10 rounded-full -translate-x-1/2 -translate-y-1/2"></div>
                        <div class="absolute bottom-0 right-0 w-96 h-96 bg-white opacity-10 rounded-full translate-x-1/3 translate-y-1/3"></div>
                        
                        <div class="relative z-10">
                            <div class="success-checkmark floating mb-6">
                                <div class="check-icon">
                                    <span class="icon-line line-tip"></span>
                                    <span class="icon-line line-long"></span>
                                </div>
                            </div>
                            
                            <h1 class="text-5xl md:text-6xl font-extrabold text-white mb-4 glow-text">
                                <i class="fas fa-party-horn"></i> Félicitations !
                            </h1>
                            <p class="text-xl md:text-2xl text-white/90 font-medium">
                                <i class="bi bi-check-circle-fill"></i> Votre réservation a été confirmée avec succès
                            </p>
                            <div class="mt-6 flex items-center justify-center gap-3">
                                <span class="badge badge-lg bg-white/20 border-white/40 text-white backdrop-blur-sm">
                                    <i class="fas fa-calendar-check"></i> Confirmée
                                </span>
                                <span class="badge badge-lg bg-white/20 border-white/40 text-white backdrop-blur-sm">
                                    <i class="fas fa-clock"></i> Instantané
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Content Area -->
                    <div class="p-8 md:p-12">
                        
                        <!-- Reservation Number - Highlighted -->
                        <div class="text-center mb-10 fade-in-up" style="animation-delay: 0.2s">
                            <div class="inline-block bg-gradient-to-r from-[#E9F5DB] to-[#CFE1B9] px-8 py-4 rounded-2xl border-2 shadow-lg" style="border-color: #B5C99A;">
                                <p class="text-sm text-gray-600 font-medium mb-1">
                                    <i class="bi bi-hash"></i> Numéro de Réservation
                                </p>
                                <p class="text-4xl font-extrabold gradient-text">
                                    #<%= reservation.getIdReservation() %>
                                </p>
                            </div>
                        </div>

                        <!-- Details Cards Grid -->
                        <div class="grid md:grid-cols-2 gap-6 mb-8">
                            
                            <!-- Client Info Card -->
                            <div class="card bg-gradient-to-br from-[#E9F5DB] to-[#CFE1B9] shadow-xl border-2 fade-in-up shine" style="border-color: #B5C99A; animation-delay: 0.3s">
                                <div class="card-body">
                                    <h3 class="card-title" style="color: #718355;">
                                        <i class="fas fa-user-circle text-2xl"></i>
                                        Informations Client
                                    </h3>
                                    <div class="space-y-3 mt-4">
                                        <div class="info-item flex items-center gap-3 p-3 rounded-lg">
                                            <i class="bi bi-person-badge text-xl" style="color: #87986A;"></i>
                                            <div>
                                                <p class="text-xs text-gray-600 font-medium">Identifiant</p>
                                                <p class="text-lg font-bold text-gray-800"><%= reservation.getIdClient() %></p>
                                            </div>
                                        </div>
                                        <div class="info-item flex items-center gap-3 p-3 rounded-lg">
                                            <i class="bi bi-people-fill text-xl" style="color: #87986A;"></i>
                                            <div>
                                                <p class="text-xs text-gray-600 font-medium">Passagers</p>
                                                <p class="text-lg font-bold text-gray-800"><%= reservation.getNombrePassagers() %> personne(s)</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Hotel Info Card -->
                            <div class="card bg-gradient-to-br from-[#CFE1B9] to-[#B5C99A] shadow-xl border-2 fade-in-up shine" style="border-color: #97A97C; animation-delay: 0.4s">
                                <div class="card-body">
                                    <h3 class="card-title" style="color: #718355;">
                                        <i class="fas fa-hotel text-2xl"></i>
                                        Hôtel Sélectionné
                                    </h3>
                                    <div class="space-y-3 mt-4">
                                        <div class="info-item flex items-center gap-3 p-3 rounded-lg">
                                            <i class="bi bi-building text-xl" style="color: #87986A;"></i>
                                            <div>
                                                <p class="text-xs text-gray-600 font-medium">Établissement</p>
                                                <p class="text-lg font-bold text-gray-800">
                                                    <%= reservation.getNomHotel() != null ? reservation.getNomHotel() : "Hôtel #" + reservation.getIdHotel() %>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="info-item flex items-center gap-3 p-3 rounded-lg">
                                            <i class="bi bi-star-fill text-yellow-500 text-xl"></i>
                                            <div>
                                                <p class="text-xs text-gray-600 font-medium">Classification</p>
                                                <p class="text-lg font-bold text-gray-800">
                                                    <i class="fas fa-star text-yellow-400"></i>
                                                    <i class="fas fa-star text-yellow-400"></i>
                                                    <i class="fas fa-star text-yellow-400"></i>
                                                    <i class="fas fa-star text-yellow-400"></i>
                                                    Premium
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Arrival Information -->
                        <% if (reservation.getDateHeureArrive() != null) { %>
                        <div class="alert bg-gradient-to-r from-[#E9F5DB] to-[#CFE1B9] border-2 shadow-lg mb-8 fade-in-up" style="border-color: #B5C99A; animation-delay: 0.5s">
                            <i class="fas fa-calendar-alt text-3xl" style="color: #87986A;"></i>
                            <div>
                                <h4 class="font-bold text-lg" style="color: #718355;">
                                    <i class="bi bi-clock-history"></i> Date et Heure d'Arrivée
                                </h4>
                                <p class="text-2xl font-extrabold mt-1" style="color: #718355;">
                                    <%= new java.text.SimpleDateFormat("EEEE dd MMMM yyyy 'à' HH:mm", new java.util.Locale("fr", "FR"))
                                        .format(reservation.getDateHeureArrive()) %>
                                </p>
                            </div>
                        </div>
                        <% } %>

                        <!-- Status & Comments -->
                        <div class="grid md:grid-cols-2 gap-6 mb-8">
                            <!-- Status -->
                            <div class="card bg-base-100 shadow-xl border-2 border-gray-200 fade-in-up" style="animation-delay: 0.6s">
                                <div class="card-body items-center text-center">
                                    <i class="fas fa-check-double text-5xl mb-3" style="color: #87986A;"></i>
                                    <h4 class="card-title text-gray-700">Statut de la Réservation</h4>
                                    <span class="custom-badge text-lg mt-2">
                                        <i class="bi bi-shield-check"></i> <%= reservation.getStatut() %>
                                    </span>
                                </div>
                            </div>

                            <!-- Date Creation -->
                            <div class="card bg-base-100 shadow-xl border-2 border-gray-200 fade-in-up" style="animation-delay: 0.7s">
                                <div class="card-body items-center text-center">
                                    <i class="fas fa-calendar-plus text-5xl text-blue-500 mb-3"></i>
                                    <h4 class="card-title text-gray-700">Date de Création</h4>
                                    <p class="text-xl font-bold text-gray-800 mt-2">
                                        <i class="bi bi-calendar3"></i> <%= reservation.getDateCreation() %>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Comments Section -->
                        <% if (reservation.getCommentaire() != null && !reservation.getCommentaire().isEmpty()) { %>
                        <div class="card bg-gradient-to-br from-purple-50 to-pink-50 border-2 border-purple-200 shadow-xl mb-8 fade-in-up" style="animation-delay: 0.8s">
                            <div class="card-body">
                                <h3 class="card-title" style="color: #718355;">
                                    <i class="fas fa-comment-dots text-2xl"></i>
                                    Commentaire / Demandes Spéciales
                                </h3>
                                <div class="bg-white p-4 rounded-lg mt-3 border-l-4 border-purple-400">
                                    <p class="text-gray-700 italic text-lg">
                                        "<%= reservation.getCommentaire() %>"
                                    </p>
                                </div>
                            </div>
                        </div>
                        <% } %>

                        <!-- Action Buttons -->
                        <div class="grid md:grid-cols-2 gap-4 mt-10 fade-in-up" style="animation-delay: 0.9s">
                            <a href="/sprint0/reservation/form" class="btn btn-magical btn-lg text-white ripple shine">
                                <i class="fas fa-plus-circle text-xl"></i>
                                <span class="font-bold">Nouvelle Réservation</span>
                                <i class="fas fa-arrow-right"></i>
                            </a>
                            <a href="/sprint0/reservation/list" class="btn btn-outline btn-lg border-2 ripple shine" style="border-color: #87986A; color: #718355;" onmouseover="this.style.backgroundColor='#87986A'; this.style.color='white'; this.style.borderColor='#718355';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#718355'; this.style.borderColor='#87986A';">
                                <i class="bi bi-list-ul text-xl"></i>
                                <span class="font-bold">Voir Toutes les Réservations</span>
                                <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>

                        <!-- Additional Info -->
                        <div class="mt-10 text-center fade-in-up" style="animation-delay: 1s">
                            <div class="divider">Informations Utiles</div>
                            <div class="flex flex-wrap justify-center gap-4 mt-6">
                                <div class="stat bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl shadow-lg border-2 border-blue-200">
                                    <div class="stat-figure text-blue-500">
                                        <i class="fas fa-envelope text-3xl"></i>
                                    </div>
                                    <div class="stat-title text-blue-800">Confirmation par email</div>
                                    <div class="stat-value text-blue-600 text-2xl">Envoyée</div>
                                </div>
                                
                                <div class="stat bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl shadow-lg border-2 border-green-200">
                                    <div class="stat-figure text-green-500">
                                        <i class="fas fa-mobile-alt text-3xl"></i>
                                    </div>
                                    <div class="stat-title text-green-800">SMS de rappel</div>
                                    <div class="stat-value text-green-600 text-2xl">Activé</div>
                                </div>
                                
                                <div class="stat bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl shadow-lg border-2 border-purple-200">
                                    <div class="stat-figure text-purple-500">
                                        <i class="fas fa-headset text-3xl"></i>
                                    </div>
                                    <div class="stat-title text-purple-800">Support 24/7</div>
                                    <div class="stat-value text-purple-600 text-2xl">Disponible</div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <!-- Thank you message -->
                <div class="text-center mt-8 fade-in-up" style="animation-delay: 1.1s">
                    <p class="text-white text-xl font-semibold drop-shadow-lg">
                        <i class="fas fa-heart text-red-400"></i>
                        Merci de votre confiance ! Bon séjour !
                        <i class="fas fa-sparkles text-yellow-300"></i>
                    </p>
                </div>
            </div>

        <%
            } else {
        %>
            <!-- ERROR PAGE -->
            <div class="max-w-3xl mx-auto">
                <div class="glass-card-solid rounded-3xl shadow-2xl overflow-hidden fade-in-up">
                    
                    <!-- Error Header -->
                    <div class="bg-gradient-to-br from-red-400 via-rose-400 to-pink-400 p-12 text-center relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-72 h-72 bg-white opacity-10 rounded-full -translate-x-1/2 -translate-y-1/2"></div>
                        <div class="absolute bottom-0 right-0 w-96 h-96 bg-white opacity-10 rounded-full translate-x-1/3 translate-y-1/3"></div>
                        
                        <div class="relative z-10">
                            <div class="text-8xl mb-6 floating">
                                <i class="fas fa-exclamation-triangle text-white"></i>
                            </div>
                            <h1 class="text-5xl md:text-6xl font-extrabold text-white mb-4">
                                Oups ! Une Erreur
                            </h1>
                            <p class="text-xl text-white/90">
                                La réservation n'a pas pu être créée
                            </p>
                        </div>
                    </div>

                    <!-- Error Content -->
                    <div class="p-12">
                        <div class="alert alert-error shadow-lg mb-8">
                            <i class="fas fa-times-circle text-3xl"></i>
                            <div>
                                <h3 class="font-bold text-lg">Erreur de traitement</h3>
                                <div class="text-sm"><%= error != null ? error : "Une erreur inconnue s'est produite" %></div>
                            </div>
                        </div>

                        <div class="text-center mb-8">
                            <p class="text-gray-600 text-lg">
                                <i class="bi bi-info-circle"></i>
                                Ne vous inquiétez pas, vous pouvez réessayer !
                            </p>
                        </div>

                        <a href="/sprint0/reservation/form" class="btn btn-magical btn-lg btn-block text-white">
                            <i class="fas fa-redo-alt text-xl"></i>
                            <span class="font-bold">Retour au Formulaire</span>
                            <i class="fas fa-arrow-right"></i>
                        </a>

                        <div class="mt-8 text-center">
                            <p class="text-gray-500">
                                Besoin d'aide ? 
                                <a href="#" class="text-emerald-600 font-bold hover:underline">
                                    <i class="fas fa-headset"></i> Contactez le support
                                </a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        <%
            }
        %>
    </div>

    <script>
        // Confetti celebration on success
        <% if (success != null && success) { %>
        window.addEventListener('load', function() {
            // Initial confetti burst
            confetti({
                particleCount: 150,
                spread: 70,
                origin: { y: 0.6 },
                colors: ['#718355', '#87986A', '#97A97C', '#B5C99A', '#CFE1B9']
            });

            // Second burst
            setTimeout(() => {
                confetti({
                    particleCount: 100,
                    angle: 60,
                    spread: 55,
                    origin: { x: 0 },
                    colors: ['#718355', '#87986A', '#97A97C']
                });
            }, 300);

            setTimeout(() => {
                confetti({
                    particleCount: 100,
                    angle: 120,
                    spread: 55,
                    origin: { x: 1 },
                    colors: ['#718355', '#87986A', '#97A97C']
                });
            }, 600);

            // Falling stars
            function createStar() {
                const star = document.createElement('div');
                star.className = 'star';
                star.innerHTML = ['⭐', '✨', '💚', '🌟'][Math.floor(Math.random() * 4)];
                star.style.left = Math.random() * 100 + '%';
                star.style.animationDuration = (Math.random() * 2 + 2) + 's';
                star.style.animationDelay = Math.random() * 2 + 's';
                document.body.appendChild(star);
                
                setTimeout(() => star.remove(), 5000);
            }

            // Create stars periodically
            for(let i = 0; i < 10; i++) {
                setTimeout(createStar, i * 500);
            }

            // Anime.js animations for cards
            anime({
                targets: '.fade-in-up',
                translateY: [50, 0],
                opacity: [0, 1],
                duration: 1000,
                delay: anime.stagger(100),
                easing: 'easeOutExpo'
            });

            // Pulse effect on badge
            anime({
                targets: '.custom-badge',
                scale: [1, 1.1, 1],
                duration: 2000,
                loop: true,
                easing: 'easeInOutQuad'
            });
        });
        <% } %>

        // 3D card tilt effect
        document.querySelectorAll('.card-3d').forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 20;
                const rotateY = (centerX - x) / 20;
                
                card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
            });
            
            card.addEventListener('mouseleave', () => {
                card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)';
            });
        });

        // Info item hover animation
        document.querySelectorAll('.info-item').forEach(item => {
            item.addEventListener('mouseenter', function() {
                anime({
                    targets: this,
                    translateX: 12,
                    duration: 300,
                    easing: 'easeOutQuad'
                });
            });
            
            item.addEventListener('mouseleave', function() {
                anime({
                    targets: this,
                    translateX: 0,
                    duration: 300,
                    easing: 'easeOutQuad'
                });
            });
        });

        // Smooth scroll
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if(target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    </script>
</body>
</html>
