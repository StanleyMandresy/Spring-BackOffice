<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.spring.BackOffice.model.Hotel" %>
<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>✨ Formulaire de Réservation</title>
    
    <!-- Tailwind CSS + DaisyUI -->
    <link href="https://cdn.jsdelivr.net/npm/daisyui@4.7.2/dist/full.min.css" rel="stylesheet" type="text/css" />
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
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

        /* Floating animation */
        @keyframes floating {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
        }

        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Input focus effects */
        .form-input {
            transition: all 0.3s ease;
            border: 2px solid #d1d5db;
        }

        .form-input:focus {
            border-color: #87986A;
            box-shadow: 0 0 0 4px rgba(135, 152, 106, 0.2);
            transform: translateY(-2px);
        }

        /* Label animation on focus */
        .form-group {
            position: relative;
        }

        .form-label {
            transition: all 0.3s ease;
            display: inline-block;
        }

        .form-input:focus ~ .form-label,
        .form-input:not(:placeholder-shown) ~ .form-label {
            transform: translateY(-5px);
            font-size: 0.875rem;
            color: #718355;
        }

        /* Glow effect on hover */
        .glow-on-hover {
            transition: all 0.3s ease;
        }

        .glow-on-hover:hover {
            box-shadow: 0 0 20px rgba(151, 169, 124, 0.6);
            transform: translateY(-3px);
        }

        /* Progress bar */
        .progress-bar {
            height: 6px;
            background: linear-gradient(90deg, #718355 0%, #87986A 50%, #97A97C 100%);
            border-radius: 10px;
            transition: width 0.5s ease;
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

        /* Custom select styling */
        .custom-select {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2387986A'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 1.5em 1.5em;
            padding-right: 2.5rem;
        }

        /* Hotel card in select (visual enhancement) */
        .hotel-card {
            background: linear-gradient(135deg, #E9F5DB 0%, #CFE1B9 100%);
            border: 2px solid #87986A;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .hotel-card:hover {
            transform: translateX(10px);
            box-shadow: 0 8px 20px rgba(135, 152, 106, 0.4);
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

        /* Gradient text */
        .gradient-text {
            background: linear-gradient(135deg, #718355 0%, #87986A 50%, #97A97C 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Input icons */
        .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #87986A;
            font-size: 1.25rem;
            transition: all 0.3s ease;
        }

        .has-icon {
            padding-left: 48px;
        }

        .form-input:focus + .input-icon {
            color: #718355;
            transform: translateY(-50%) scale(1.2);
        }

        /* Tooltip */
        .tooltip-custom {
            position: relative;
            display: inline-block;
        }

        .tooltip-custom .tooltiptext {
            visibility: hidden;
            width: 200px;
            background-color: #718355;
            color: #fff;
            text-align: center;
            border-radius: 8px;
            padding: 8px;
            position: absolute;
            z-index: 1;
            bottom: 125%;
            left: 50%;
            margin-left: -100px;
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 0.875rem;
        }

        .tooltip-custom:hover .tooltiptext {
            visibility: visible;
            opacity: 1;
        }

        /* Success checkmark animation */
        .checkmark {
            display: inline-block;
            transform: rotate(45deg);
            height: 20px;
            width: 10px;
            border-bottom: 3px solid #87986A;
            border-right: 3px solid #87986A;
            animation: checkmark 0.5s ease;
        }

        @keyframes checkmark {
            0% { height: 0; width: 0; }
            50% { height: 20px; width: 0; }
            100% { height: 20px; width: 10px; }
        }

        /* Form validation indicators */
        .input-valid {
            border-color: #87986A !important;
            background-color: rgba(135, 152, 106, 0.08);
        }

        .input-invalid {
            border-color: #ef4444 !important;
            background-color: rgba(239, 68, 68, 0.05);
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

        .ripple:active::after {
            width: 300px;
            height: 300px;
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
        <div class="max-w-4xl mx-auto">
            
            <!-- Main Card -->
            <div class="glass-card rounded-3xl shadow-2xl overflow-hidden fade-in-up">
                
                <!-- Header -->
                <div class="bg-gradient-to-br from-[#B5C99A] via-[#97A97C] to-[#87986A] p-10 text-center relative overflow-hidden">
                    <!-- Animated circles -->
                    <div class="absolute top-0 left-0 w-64 h-64 bg-white opacity-10 rounded-full -translate-x-1/2 -translate-y-1/2"></div>
                    <div class="absolute bottom-0 right-0 w-80 h-80 bg-white opacity-10 rounded-full translate-x-1/3 translate-y-1/3"></div>
                    
                    <div class="relative z-10">
                        <div class="text-6xl mb-4 floating">
                            🏨
                        </div>
                        <h1 class="text-4xl md:text-5xl font-extrabold text-white mb-3 drop-shadow-lg">
                            Formulaire de Réservation
                        </h1>
                        <p class="text-lg md:text-xl text-white/90 font-medium">
                            <i class="bi bi-stars"></i>
                            Réservez votre séjour dans nos hôtels partenaires
                        </p>
                        <div class="mt-6 flex items-center justify-center gap-3">
                            <span class="badge badge-lg bg-white/20 border-white/40 text-white backdrop-blur-sm">
                                <i class="fas fa-shield-check"></i> Paiement Sécurisé
                            </span>
                            <span class="badge badge-lg bg-white/20 border-white/40 text-white backdrop-blur-sm">
                                <i class="fas fa-bolt"></i> Confirmation Rapide
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Form Container -->
                <div class="p-8 md:p-12">
                    
                    <!-- Error Message -->
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

                    <!-- Info Box -->
                    <div class="alert bg-gradient-to-r from-blue-100 to-cyan-100 border-2 border-blue-300 shadow-lg mb-8 fade-in-up">
                        <i class="bi bi-info-circle-fill text-3xl text-blue-600"></i>
                        <div>
                            <h4 class="font-bold text-blue-900">Information importante</h4>
                            <p class="text-blue-800 text-sm">
                                Tous les champs marqués d'un <span class="text-red-500 font-bold">*</span> sont obligatoires
                            </p>
                        </div>
                    </div>

                    <!-- Progress Indicator -->
                    <div class="mb-8 fade-in-up">
                        <div class="flex justify-between mb-2 text-sm font-semibold text-gray-600">
                            <span>Progression du formulaire</span>
                            <span id="progress-text">0%</span>
                        </div>
                        <div class="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                            <div id="progress-bar" class="progress-bar" style="width: 0%"></div>
                        </div>
                    </div>

                    <!-- Form -->
                    <form id="reservationForm" action="/sprint0/reservation/create" method="POST" class="space-y-6">
                        
                        <!-- Client ID -->
                        <div class="form-group fade-in-up" style="animation-delay: 0.1s">
                            <label for="idClient" class="label">
                                <span class="label-text text-base font-bold text-gray-700">
                                    <i class="bi bi-person-badge" style="color: #87986A;"></i>
                                    Identifiant Client
                                    <span class="text-red-500">*</span>
                                </span>
                                <span class="label-text-alt">
                                    <div class="tooltip tooltip-left" data-tip="Votre identifiant unique">
                                        <i class="bi bi-question-circle text-gray-400"></i>
                                    </div>
                                </span>
                            </label>
                            <div class="relative">
                                <input 
                                    type="text" 
                                    id="idClient" 
                                    name="idClient" 
                                    placeholder="Ex: CLIENT123" 
                                    class="input input-bordered w-full form-input has-icon glow-on-hover"
                                    required 
                                    maxlength="50"
                                />
                                <i class="bi bi-person-circle input-icon"></i>
                            </div>
                        </div>

                        <!-- Hotel Selection -->
                        <div class="form-group fade-in-up" style="animation-delay: 0.2s">
                            <label for="idHotel" class="label">
                                <span class="label-text text-base font-bold text-gray-700">
                                    <i class="fas fa-hotel" style="color: #87986A;"></i>
                                    Sélectionnez un Hôtel
                                    <span class="text-red-500">*</span>
                                </span>
                            </label>
                            <div class="relative">
                                <select 
                                    id="idHotel" 
                                    name="idHotel" 
                                    class="select select-bordered w-full form-input custom-select glow-on-hover text-base"
                                    required
                                >
                                    <option value="">🏨 -- Choisissez votre hôtel --</option>
                                    <%
                                        List<Hotel> hotels = (List<Hotel>) request.getAttribute("hotels");
                                        if (hotels != null && !hotels.isEmpty()) {
                                            for (Hotel hotel : hotels) {
                                                String etoiles = "⭐".repeat(hotel.getNombreEtoiles());
                                    %>
                                        <option value="<%= hotel.getIdHotel() %>" data-price="<%= hotel.getPrixNuit() %>">
                                            <%= hotel.getNomHotel() %> - <%= hotel.getVille() %> 
                                            (<%= etoiles %> - <%= String.format("%.2f", hotel.getPrixNuit()) %>€/nuit)
                                        </option>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <option value="">❌ Aucun hôtel disponible</option>
                                    <%
                                        }
                                    %>
                                </select>
                            </div>
                            <label class="label">
                                <span class="label-text-alt text-gray-500">
                                    <i class="bi bi-star-fill text-yellow-500"></i>
                                    Les meilleurs hôtels sélectionnés pour vous
                                </span>
                            </label>
                        </div>

                        <!-- Number of Passengers -->
                        <div class="form-group fade-in-up" style="animation-delay: 0.3s">
                            <label for="nombrePassagers" class="label">
                                <span class="label-text text-base font-bold text-gray-700">
                                    <i class="bi bi-people-fill" style="color: #87986A;"></i>
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
                                    class="input input-bordered w-full form-input has-icon glow-on-hover"
                                    required
                                />
                                <i class="bi bi-person-plus input-icon"></i>
                            </div>
                            <label class="label">
                                <span class="label-text-alt text-gray-500">Maximum 10 personnes par réservation</span>
                            </label>
                        </div>

                        <!-- Date and Time Row -->
                        <div class="grid md:grid-cols-2 gap-6">
                            
                            <!-- Arrival Date -->
                            <div class="form-group fade-in-up" style="animation-delay: 0.4s">
                                <label for="dateArrivee" class="label">
                                    <span class="label-text text-base font-bold text-gray-700">
                                        <i class="bi bi-calendar-event" style="color: #87986A;"></i>
                                        Date d'Arrivée
                                        <span class="text-red-500">*</span>
                                    </span>
                                </label>
                                <input 
                                    type="date" 
                                    id="dateArrivee" 
                                    name="dateArrivee" 
                                    class="input input-bordered w-full form-input glow-on-hover"
                                    required
                                />
                            </div>

                            <!-- Arrival Time -->
                            <div class="form-group fade-in-up" style="animation-delay: 0.5s">
                                <label for="heureArrivee" class="label">
                                    <span class="label-text text-base font-bold text-gray-700">
                                        <i class="bi bi-clock-fill" style="color: #87986A;"></i>
                                        Heure d'Arrivée
                                        <span class="text-red-500">*</span>
                                    </span>
                                </label>
                                <input 
                                    type="time" 
                                    id="heureArrivee" 
                                    name="heureArrivee" 
                                    class="input input-bordered w-full form-input glow-on-hover"
                                    required
                                />
                            </div>
                        </div>

                        <!-- Comments -->
                        <div class="form-group fade-in-up" style="animation-delay: 0.6s">
                            <label for="commentaire" class="label">
                                <span class="label-text text-base font-bold text-gray-700">
                                    <i class="fas fa-comment-dots" style="color: #87986A;"></i>
                                    Commentaire / Demandes Spéciales
                                </span>
                                <span class="label-text-alt text-gray-500">Optionnel</span>
                            </label>
                            <textarea 
                                id="commentaire" 
                                name="commentaire" 
                                placeholder="Ex: Préférence pour une chambre vue mer, arrivée tardive, lit bébé nécessaire..."
                                class="textarea textarea-bordered w-full h-32 form-input glow-on-hover resize-none"
                            ></textarea>
                            <label class="label">
                                <span class="label-text-alt"></span>
                                <span class="label-text-alt text-gray-500" id="char-count">0 / 500 caractères</span>
                            </label>
                        </div>

                        <!-- Price Estimate -->
                        <div id="price-estimate" class="hidden fade-in-up">
                            <div class="card bg-gradient-to-br from-[#E9F5DB] to-[#CFE1B9] border-2 shadow-lg" style="border-color: #B5C99A;">
                                <div class="card-body">
                                    <h3 class="card-title" style="color: #718355;">
                                        <i class="fas fa-calculator"></i>
                                        Estimation du Prix
                                    </h3>
                                    <div class="stats stats-vertical lg:stats-horizontal shadow mt-4">
                                        <div class="stat bg-white/70">
                                            <div class="stat-figure" style="color: #87986A;">
                                                <i class="fas fa-euro-sign text-3xl"></i>
                                            </div>
                                            <div class="stat-title">Prix par nuit</div>
                                            <div class="stat-value" style="color: #87986A;" id="price-per-night">0€</div>
                                        </div>
                                        <div class="stat bg-white/70">
                                            <div class="stat-figure text-blue-600">
                                                <i class="fas fa-users text-3xl"></i>
                                            </div>
                                            <div class="stat-title">Passagers</div>
                                            <div class="stat-value text-blue-600" id="passenger-count">0</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Submit Button -->
                        <div class="fade-in-up" style="animation-delay: 0.7s">
                            <button 
                                type="submit" 
                                id="submitBtn"
                                class="btn btn-magical btn-lg w-full text-white text-lg ripple shine"
                            >
                                <i class="fas fa-check-circle text-2xl"></i>
                                <span class="font-bold">Confirmer la Réservation</span>
                                <i class="fas fa-arrow-right text-xl"></i>
                            </button>
                        </div>

                        <!-- Additional Info -->
                        <div class="text-center text-sm text-gray-600 fade-in-up" style="animation-delay: 0.8s">
                            <i class="bi bi-shield-lock-fill" style="color: #87986A;"></i>
                            Vos informations sont sécurisées et cryptées
                        </div>
                    </form>

                    <!-- Divider -->
                    <div class="divider my-8 fade-in-up" style="animation-delay: 0.9s">Navigation</div>

                    <!-- Back Link -->
                    <div class="text-center fade-in-up" style="animation-delay: 1s">
                        <a 
                            href="/sprint0/reservation/list" 
                            class="btn btn-outline btn-lg border-2 ripple shine" style="border-color: #87986A; color: #718355;" onmouseover="this.style.backgroundColor='#87986A'; this.style.color='white';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#718355';"
                        >
                            <i class="bi bi-list-ul text-xl"></i>
                            <span class="font-bold">Voir Toutes les Réservations</span>
                            <i class="fas fa-external-link-alt"></i>
                        </a>
                    </div>

                    <!-- Trust Badges -->
                    <div class="mt-10 fade-in-up" style="animation-delay: 1.1s">
                        <div class="divider text-sm text-gray-500">Nos Garanties</div>
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
                            <div class="text-center p-4 bg-gradient-to-br from-green-50 to-emerald-50 rounded-xl border-2 border-green-200">
                                <i class="fas fa-medal text-3xl text-yellow-500 mb-2"></i>
                                <p class="text-xs font-semibold text-gray-700">Meilleur Prix</p>
                            </div>
                            <div class="text-center p-4 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-xl border-2 border-blue-200">
                                <i class="fas fa-undo text-3xl text-blue-500 mb-2"></i>
                                <p class="text-xs font-semibold text-gray-700">Annulation Gratuite</p>
                            </div>
                            <div class="text-center p-4 bg-gradient-to-br from-purple-50 to-pink-50 rounded-xl border-2 border-purple-200">
                                <i class="fas fa-headset text-3xl text-purple-500 mb-2"></i>
                                <p class="text-xs font-semibold text-gray-700">Support 24/7</p>
                            </div>
                            <div class="text-center p-4 bg-gradient-to-br from-orange-50 to-yellow-50 rounded-xl border-2 border-orange-200">
                                <i class="fas fa-star text-3xl text-orange-500 mb-2"></i>
                                <p class="text-xs font-semibold text-gray-700">Satisfaction 100%</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Form validation and progress tracking
        const form = document.getElementById('reservationForm');
        const progressBar = document.getElementById('progress-bar');
        const progressText = document.getElementById('progress-text');
        const inputs = form.querySelectorAll('input[required], select[required]');
        const commentaire = document.getElementById('commentaire');
        const charCount = document.getElementById('char-count');
        const priceEstimate = document.getElementById('price-estimate');
        const hotelSelect = document.getElementById('idHotel');
        const passengersInput = document.getElementById('nombrePassagers');

        // Update progress bar
        function updateProgress() {
            let filledInputs = 0;
            inputs.forEach(input => {
                if (input.value.trim() !== '') {
                    filledInputs++;
                    input.classList.add('input-valid');
                    input.classList.remove('input-invalid');
                } else {
                    input.classList.remove('input-valid');
                }
            });
            
            const progress = (filledInputs / inputs.length) * 100;
            progressBar.style.width = progress + '%';
            progressText.textContent = Math.round(progress) + '%';
        }

        // Character count for textarea
        commentaire.addEventListener('input', function() {
            const length = this.value.length;
            charCount.textContent = length + ' / 500 caractères';
            if (length > 500) {
                this.value = this.value.substring(0, 500);
            }
        });

        // Update price estimate
        function updatePriceEstimate() {
            const selectedOption = hotelSelect.options[hotelSelect.selectedIndex];
            const price = selectedOption.getAttribute('data-price');
            const passengers = passengersInput.value;

            if (price && passengers) {
                document.getElementById('price-per-night').textContent = parseFloat(price).toFixed(2) + '€';
                document.getElementById('passenger-count').textContent = passengers;
                priceEstimate.classList.remove('hidden');
                
                anime({
                    targets: '#price-estimate',
                    opacity: [0, 1],
                    translateY: [20, 0],
                    duration: 800,
                    easing: 'easeOutExpo'
                });
            }
        }

        hotelSelect.addEventListener('change', updatePriceEstimate);
        passengersInput.addEventListener('input', updatePriceEstimate);

        // Add event listeners for progress
        inputs.forEach(input => {
            input.addEventListener('input', updateProgress);
            input.addEventListener('blur', function() {
                if (this.value.trim() === '' && this.hasAttribute('required')) {
                    this.classList.add('input-invalid');
                }
            });
        });

        // Form submission with animation
        form.addEventListener('submit', function(e) {
            const idClient = document.getElementById('idClient').value.trim();
            const idHotel = document.getElementById('idHotel').value;
            const nombrePassagers = parseInt(document.getElementById('nombrePassagers').value);

            if (!idClient) {
                e.preventDefault();
                showError('Veuillez saisir un identifiant client');
                return;
            }

            if (!idHotel) {
                e.preventDefault();
                showError('Veuillez sélectionner un hôtel');
                return;
            }

            if (!nombrePassagers || nombrePassagers < 1) {
                e.preventDefault();
                showError('Le nombre de passagers doit être au moins 1');
                return;
            }

            // Show loading state
            const submitBtn = document.getElementById('submitBtn');
            submitBtn.innerHTML = '<span class="loading loading-spinner loading-md"></span> Traitement en cours...';
            submitBtn.disabled = true;
        });

        // Error notification
        function showError(message) {
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-error shadow-lg fixed top-4 right-4 w-auto z-50';
            alertDiv.innerHTML = `
                <i class="fas fa-exclamation-circle text-2xl"></i>
                <span>${message}</span>
            `;
            document.body.appendChild(alertDiv);

            setTimeout(() => {
                alertDiv.style.opacity = '0';
                setTimeout(() => alertDiv.remove(), 300);
            }, 3000);
        }

        // Anime.js animations on load
        window.addEventListener('load', function() {
            anime({
                targets: '.fade-in-up',
                translateY: [50, 0],
                opacity: [0, 1],
                duration: 1000,
                delay: anime.stagger(100),
                easing: 'easeOutExpo'
            });

            // Add ripple effect to inputs on click
            document.querySelectorAll('.form-input').forEach(input => {
                input.addEventListener('focus', function() {
                    anime({
                        targets: this,
                        scale: [1, 1.02, 1],
                        duration: 300,
                        easing: 'easeInOutQuad'
                    });
                });
            });
        });

        // Set minimum date to today
        const dateInput = document.getElementById('dateArrivee');
        const today = new Date().toISOString().split('T')[0];
        dateInput.setAttribute('min', today);

        // Initial progress update
        updateProgress();
    </script>
    
    </div><!-- End main-content-with-sidebar -->
</body>
</html>
