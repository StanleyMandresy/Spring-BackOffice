<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr" data-theme="emerald">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚗 ${empty vehicule ? 'Ajouter' : 'Modifier'} un Véhicule</title>
    
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
            50% { transform: translateY(-20px) rotate(5deg); }
        }

        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Form input effects */
        .form-input {
            transition: all 0.3s ease;
        }

        .form-input:focus {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(135, 152, 106, 0.3);
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

        /* Progress bar */
        .progress-container {
            background: rgba(181, 201, 154, 0.2);
            border-radius: 20px;
            overflow: hidden;
            height: 8px;
            margin: 20px 0;
        }

        .progress-bar {
            height: 100%;
            background: linear-gradient(90deg, #87986A, #97A97C, #B5C99A);
            transition: width 0.5s ease;
            box-shadow: 0 0 10px rgba(135, 152, 106, 0.5);
        }

        /* Fuel type cards */
        .fuel-card {
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .fuel-card:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        }

        .fuel-card.selected {
            transform: scale(1.05);
            box-shadow: 0 0 0 4px #87986A;
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

        /* Input validation */
        .input-valid {
            border-color: #87986A !important;
            box-shadow: 0 0 0 3px rgba(135, 152, 106, 0.1);
        }

        .input-invalid {
            border-color: #ef4444 !important;
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <%@ include file="../components/sidebar.jsp" %>
    
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
                <div class="bg-gradient-to-br from-[#B5C99A] via-[#97A97C] to-[#87986A] p-8 md:p-12">
                    <div class="text-center fade-in-down">
                        <div class="text-7xl mb-4 floating inline-block">
                            ${empty vehicule ? '🚗' : '🔧'}
                        </div>
                        <h1 class="text-4xl md:text-5xl font-extrabold text-white mb-3 drop-shadow-2xl">
                            ${empty vehicule ? 'Ajouter' : 'Modifier'} un Véhicule
                        </h1>
                        <p class="text-white/90 text-xl font-medium">
                            <i class="bi bi-clipboard-check"></i>
                            ${empty vehicule ? 'Enregistrez un nouveau véhicule dans votre parc' : 'Mettez à jour les informations du véhicule'}
                        </p>
                    </div>

                    <!-- Progress Bar -->
                    <div class="progress-container mt-6">
                        <div class="progress-bar" id="progressBar" style="width: 0%"></div>
                    </div>
                    <p class="text-white/80 text-center mt-2 text-sm" id="progressText">0% complété</p>
                </div>

                <!-- Content Area -->
                <div class="p-8 md:p-12">
                    
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

                    <!-- Form -->
                    <form action="${pageContext.request.contextPath}/vehicule/save" method="post" id="vehicleForm" class="space-y-8">
                        <c:if test="${not empty vehicule}">
                            <input type="hidden" name="id" value="${vehicule.id}">
                        </c:if>
                        
                        <!-- Reference Field -->
                        <div class="form-control fade-in-up" style="animation-delay: 0.1s">
                            <label class="label">
                                <span class="label-text font-bold text-lg" style="color: #718355;">
                                    <i class="fas fa-tag"></i> Référence du véhicule
                                </span>
                                <span class="label-text-alt text-red-500">* Requis</span>
                            </label>
                            <div class="relative">
                                <span class="absolute left-4 top-1/2 -translate-y-1/2 text-2xl" style="color: #87986A;">
                                    <i class="bi bi-car-front"></i>
                                </span>
                                <input 
                                    type="text" 
                                    id="reference" 
                                    name="reference" 
                                    value="${vehicule.reference}" 
                                    placeholder="Ex: VEH-001, BMW-X5, TESLA-M3..." 
                                    class="input input-bordered w-full pl-14 form-input text-lg font-semibold"
                                    required
                                    style="border: 2px solid #B5C99A;"
                                />
                                <div class="label">
                                    <span class="label-text-alt">
                                        <i class="fas fa-info-circle"></i>
                                        Un identifiant unique pour votre véhicule
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Number of Seats Field -->
                        <div class="form-control fade-in-up" style="animation-delay: 0.2s">
                            <label class="label">
                                <span class="label-text font-bold text-lg" style="color: #718355;">
                                    <i class="fas fa-users"></i> Nombre de places
                                </span>
                                <span class="label-text-alt text-red-500">* Requis</span>
                            </label>
                            <div class="relative">
                                <span class="absolute left-4 top-1/2 -translate-y-1/2 text-2xl" style="color: #87986A;">
                                    <i class="bi bi-people-fill"></i>
                                </span>
                                <input 
                                    type="number" 
                                    id="nbrPlace" 
                                    name="nbrPlace" 
                                    value="${vehicule.nbrPlace}" 
                                    min="1" 
                                    max="100"
                                    placeholder="Ex: 2, 5, 7, 50..." 
                                    class="input input-bordered w-full pl-14 form-input text-lg font-semibold"
                                    required
                                    style="border: 2px solid #B5C99A;"
                                />
                                <div class="label">
                                    <span class="label-text-alt">
                                        <i class="fas fa-info-circle"></i>
                                        Capacité d'accueil du véhicule (passagers)
                                    </span>
                                    <span class="label-text-alt font-bold" style="color: #87986A;" id="seatCounter">
                                        <i class="fas fa-chair"></i> 0 places
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Fuel Type Selection -->
                        <div class="form-control fade-in-up" style="animation-delay: 0.3s">
                            <label class="label">
                                <span class="label-text font-bold text-lg" style="color: #718355;">
                                    <i class="fas fa-gas-pump"></i> Type de carburant
                                </span>
                                <span class="label-text-alt text-red-500">* Requis</span>
                            </label>

                            <!-- Visual Fuel Cards -->
                            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                                <div class="fuel-card glass-card rounded-xl p-4 text-center ${vehicule.typeCarburant == 'D' ? 'selected' : ''}" 
                                     data-fuel="D" onclick="selectFuel('D')">
                                    <div class="text-5xl mb-2">⛽</div>
                                    <h3 class="font-bold text-lg text-yellow-700">Diesel</h3>
                                    <p class="text-sm text-gray-500">Économique</p>
                                </div>

                                <div class="fuel-card glass-card rounded-xl p-4 text-center ${vehicule.typeCarburant == 'ES' ? 'selected' : ''}" 
                                     data-fuel="ES" onclick="selectFuel('ES')">
                                    <div class="text-5xl mb-2">🍃</div>
                                    <h3 class="font-bold text-lg text-green-700">Essence</h3>
                                    <p class="text-sm text-gray-500">Standard</p>
                                </div>

                                <div class="fuel-card glass-card rounded-xl p-4 text-center ${vehicule.typeCarburant == 'S' ? 'selected' : ''}" 
                                     data-fuel="S" onclick="selectFuel('S')">
                                    <div class="text-5xl mb-2">⭐</div>
                                    <h3 class="font-bold text-lg text-blue-700">Super</h3>
                                    <p class="text-sm text-gray-500">Performance</p>
                                </div>

                                <div class="fuel-card glass-card rounded-xl p-4 text-center ${vehicule.typeCarburant == 'E' ? 'selected' : ''}" 
                                     data-fuel="E" onclick="selectFuel('E')">
                                    <div class="text-5xl mb-2">⚡</div>
                                    <h3 class="font-bold text-lg text-purple-700">Électrique</h3>
                                    <p class="text-sm text-gray-500">Écologique</p>
                                </div>
                            </div>

                            <!-- Hidden select for form submission -->
                            <select id="typeCarburant" name="typeCarburant" class="hidden" required>
                                <option value="">Sélectionnez</option>
                                <option value="D" ${vehicule.typeCarburant == 'D' ? 'selected' : ''}>Diesel</option>
                                <option value="ES" ${vehicule.typeCarburant == 'ES' ? 'selected' : ''}>Essence</option>
                                <option value="S" ${vehicule.typeCarburant == 'S' ? 'selected' : ''}>Super</option>
                                <option value="E" ${vehicule.typeCarburant == 'E' ? 'selected' : ''}>Électrique</option>
                            </select>
                        </div>

                        <!-- Action Buttons -->
                        <div class="flex flex-col md:flex-row gap-4 mt-10 fade-in-up" style="animation-delay: 0.4s">
                            <button type="submit" class="btn btn-magical btn-lg flex-1 text-white shine">
                                <i class="fas fa-save text-2xl"></i>
                                <span class="font-bold text-lg">
                                    ${empty vehicule ? 'Enregistrer le Véhicule' : 'Mettre à Jour'}
                                </span>
                                <i class="fas fa-check text-xl"></i>
                            </button>
                            
                            <a href="${pageContext.request.contextPath}/vehicule/list-view" class="btn btn-outline btn-lg flex-1" style="border-color: #87986A; color: #87986A;">
                                <i class="fas fa-times text-xl"></i>
                                <span class="font-bold">Annuler</span>
                            </a>
                        </div>
                    </form>

                    <!-- Info Cards -->
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-10 fade-in-up" style="animation-delay: 0.5s">
                        <div class="glass-card rounded-xl p-6 text-center">
                            <div class="text-4xl mb-2">🎯</div>
                            <h3 class="font-bold" style="color: #718355;">Précision</h3>
                            <p class="text-sm text-gray-600 mt-2">Renseignez avec exactitude</p>
                        </div>
                        <div class="glass-card rounded-xl p-6 text-center">
                            <div class="text-4xl mb-2">⚡</div>
                            <h3 class="font-bold" style="color: #718355;">Rapidité</h3>
                            <p class="text-sm text-gray-600 mt-2">Formulaire en 30 secondes</p>
                        </div>
                        <div class="glass-card rounded-xl p-6 text-center">
                            <div class="text-4xl mb-2">✅</div>
                            <h3 class="font-bold" style="color: #718355;">Validation</h3>
                            <p class="text-sm text-gray-600 mt-2">Vérification automatique</p>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Footer -->
            <div class="mt-8 text-center text-white fade-in-up" style="animation-delay: 0.6s">
                <p class="text-lg font-semibold drop-shadow-lg">
                    <i class="fas fa-database"></i>
                    Gestion intelligente de votre flotte
                    <i class="fas fa-cog"></i>
                </p>
            </div>

        </div>
    </div>

    <script>
        const form = document.getElementById('vehicleForm');
        const referenceInput = document.getElementById('reference');
        const nbrPlaceInput = document.getElementById('nbrPlace');
        const typeCarburantSelect = document.getElementById('typeCarburant');
        const progressBar = document.getElementById('progressBar');
        const progressText = document.getElementById('progressText');
        const seatCounter = document.getElementById('seatCounter');

        // Update progress
        function updateProgress() {
            let progress = 0;
            
            if (referenceInput.value.trim()) progress += 33;
            if (nbrPlaceInput.value && nbrPlaceInput.value > 0) progress += 33;
            if (typeCarburantSelect.value) progress += 34;
            
            progressBar.style.width = progress + '%';
            progressText.textContent = progress + '% complété';
            
            // Visual feedback
            if (progress === 100) {
                progressBar.style.background = 'linear-gradient(90deg, #87986A, #718355)';
                progressText.textContent = '✅ Formulaire complet !';
            }
        }

        // Seat counter
        nbrPlaceInput.addEventListener('input', function() {
            const seats = parseInt(this.value) || 0;
            seatCounter.textContent = `🪑 ${seats} place${seats > 1 ? 's' : ''}`;
            
            // Validation visual
            if (seats > 0) {
                this.classList.add('input-valid');
                this.classList.remove('input-invalid');
            } else {
                this.classList.add('input-invalid');
                this.classList.remove('input-valid');
            }
            
            updateProgress();
        });

        // Reference input
        referenceInput.addEventListener('input', function() {
            if (this.value.trim().length >= 3) {
                this.classList.add('input-valid');
                this.classList.remove('input-invalid');
            } else {
                this.classList.add('input-invalid');
                this.classList.remove('input-valid');
            }
            updateProgress();
        });

        // Fuel selection
        function selectFuel(fuelType) {
            // Update hidden select
            typeCarburantSelect.value = fuelType;
            
            // Update visual cards
            document.querySelectorAll('.fuel-card').forEach(card => {
                card.classList.remove('selected');
            });
            document.querySelector(`.fuel-card[data-fuel="${fuelType}"]`).classList.add('selected');
            
            // Animation
            anime({
                targets: `.fuel-card[data-fuel="${fuelType}"]`,
                scale: [1, 1.1, 1.05],
                duration: 400,
                easing: 'easeOutElastic(1, .8)'
            });
            
            updateProgress();
        }

        // Form submission animation
        form.addEventListener('submit', function(e) {
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin text-2xl"></i> <span class="font-bold">Enregistrement...</span>';
            
            anime({
                targets: submitBtn,
                scale: [1, 0.95, 1],
                duration: 1000,
                loop: true,
                easing: 'easeInOutQuad'
            });
        });

        // Initialize
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

            // Initial progress
            updateProgress();
            
            // Initial seat counter
            if (nbrPlaceInput.value) {
                const seats = parseInt(nbrPlaceInput.value);
                seatCounter.textContent = `🪑 ${seats} place${seats > 1 ? 's' : ''}`;
            }

            // Fuel cards animation
            anime({
                targets: '.fuel-card',
                scale: [0.8, 1],
                opacity: [0, 1],
                duration: 800,
                delay: anime.stagger(100),
                easing: 'easeOutElastic(1, .8)'
            });

            // Input focus effects
            document.querySelectorAll('.form-input').forEach(input => {
                input.addEventListener('focus', function() {
                    anime({
                        targets: this,
                        scale: 1.02,
                        duration: 200,
                        easing: 'easeOutQuad'
                    });
                });

                input.addEventListener('blur', function() {
                    anime({
                        targets: this,
                        scale: 1,
                        duration: 200,
                        easing: 'easeOutQuad'
                    });
                });
            });
        });
    </script>
    
    </div><!-- End main-content-with-sidebar -->
</body>
</html>