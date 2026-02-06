<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Back Office - Hotel Reservations</title>
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
            transition: all 0.3s ease;
        }
        .custom-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(208, 215, 225, 0.4);
        }
        .gradient-text {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }
        .float-animation {
            animation: float 3s ease-in-out infinite;
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
    <div class="min-h-screen flex items-center justify-center p-6">
        <div class="max-w-7xl w-full">
            <!-- Header avec animation -->
            <div class="text-center mb-16 float-animation">
                <div class="inline-block bg-white rounded-full p-6 mb-6 shadow-xl">
                    <i class="fas fa-hotel text-6xl text-purple-600"></i>
                </div>
                <h1 class="text-6xl font-bold mb-4">
                    <span class="gradient-text">Back Office</span>
                </h1>
                <p class="text-2xl text-gray-600">Système de Gestion Hôtelière</p>
                <div class="flex items-center justify-center gap-2 mt-4">
                    <div class="badge badge-success gap-2">
                        <i class="fas fa-check-circle"></i>
                        Spring MVC Opérationnel
                    </div>
                </div>
            </div>

            <!-- Cards Grid -->
            <div class="grid md:grid-cols-3 gap-8">
                <!-- Card 1 - Nouvelle Réservation -->
                <div class="custom-card rounded-3xl p-8 text-center">
                    <div class="bg-gradient-to-br from-blue-500 to-blue-600 w-20 h-20 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg">
                        <i class="fas fa-plus-circle text-4xl text-white"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-800 mb-3">Nouvelle Réservation</h2>
                    <p class="text-gray-600 mb-6">Créez une nouvelle réservation pour vos clients</p>
                    <a href="/sprint0/reservation/form" class="btn btn-primary btn-lg gap-2 w-full bg-gradient-to-r from-blue-500 to-blue-600 border-0 text-white">
                        <i class="fas fa-calendar-plus"></i>
                        Créer
                    </a>
                    <div class="mt-4 stats stats-horizontal shadow-sm bg-custom-lighter w-full">
                        <div class="stat p-3">
                            <div class="stat-title text-xs">Action Rapide</div>
                            <div class="stat-value text-2xl text-blue-600">
                                <i class="fas fa-bolt"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 2 - Liste des Réservations -->
                <div class="custom-card rounded-3xl p-8 text-center">
                    <div class="bg-gradient-to-br from-purple-500 to-purple-600 w-20 h-20 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg">
                        <i class="fas fa-list-ul text-4xl text-white"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-800 mb-3">Liste des Réservations</h2>
                    <p class="text-gray-600 mb-6">Consultez et gérez toutes vos réservations</p>
                    <a href="/sprint0/reservation/list" class="btn btn-secondary btn-lg gap-2 w-full bg-gradient-to-r from-purple-500 to-purple-600 border-0 text-white">
                        <i class="fas fa-eye"></i>
                        Voir tout
                    </a>
                    <div class="mt-4 stats stats-horizontal shadow-sm bg-custom-lighter w-full">
                        <div class="stat p-3">
                            <div class="stat-title text-xs">Gestion</div>
                            <div class="stat-value text-2xl text-purple-600">
                                <i class="fas fa-tasks"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 3 - Statistiques -->
                <div class="custom-card rounded-3xl p-8 text-center">
                    <div class="bg-gradient-to-br from-green-500 to-green-600 w-20 h-20 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg">
                        <i class="fas fa-chart-line text-4xl text-white"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-800 mb-3">Tableau de Bord</h2>
                    <p class="text-gray-600 mb-6">Analysez vos performances en temps réel</p>
                    <button class="btn btn-accent btn-lg gap-2 w-full bg-gradient-to-r from-green-500 to-green-600 border-0 text-white">
                        <i class="fas fa-chart-bar"></i>
                        Analyser
                    </button>
                    <div class="mt-4 stats stats-horizontal shadow-sm bg-custom-lighter w-full">
                        <div class="stat p-3">
                            <div class="stat-title text-xs">Insights</div>
                            <div class="stat-value text-2xl text-green-600">
                                <i class="fas fa-rocket"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Features Section -->
            <div class="mt-16 bg-white rounded-3xl p-8 shadow-xl border border-custom-border">
                <h3 class="text-3xl font-bold text-center mb-8 gradient-text">Fonctionnalités Premium</h3>
                <div class="grid md:grid-cols-4 gap-6">
                    <div class="text-center p-4 rounded-2xl bg-custom-light hover:bg-custom-lighter transition">
                        <i class="fas fa-shield-alt text-4xl text-blue-500 mb-3"></i>
                        <h4 class="font-bold text-gray-800">Sécurisé</h4>
                        <p class="text-sm text-gray-600 mt-2">Protection des données</p>
                    </div>
                    <div class="text-center p-4 rounded-2xl bg-custom-light hover:bg-custom-lighter transition">
                        <i class="fas fa-clock text-4xl text-purple-500 mb-3"></i>
                        <h4 class="font-bold text-gray-800">Temps Réel</h4>
                        <p class="text-sm text-gray-600 mt-2">Synchronisation instant</p>
                    </div>
                    <div class="text-center p-4 rounded-2xl bg-custom-light hover:bg-custom-lighter transition">
                        <i class="fas fa-mobile-alt text-4xl text-green-500 mb-3"></i>
                        <h4 class="font-bold text-gray-800">Responsive</h4>
                        <p class="text-sm text-gray-600 mt-2">Tous les appareils</p>
                    </div>
                    <div class="text-center p-4 rounded-2xl bg-custom-light hover:bg-custom-lighter transition">
                        <i class="fas fa-headset text-4xl text-orange-500 mb-3"></i>
                        <h4 class="font-bold text-gray-800">Support 24/7</h4>
                        <p class="text-sm text-gray-600 mt-2">Assistance continue</p>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <footer class="text-center mt-12 text-gray-600">
                <div class="divider"></div>
                <p class="flex items-center justify-center gap-2">
                    <i class="fas fa-code text-purple-500"></i>
                    Powered by Spring MVC | Design by Tailwind + DaisyUI
                    <i class="fas fa-heart text-red-500"></i>
                </p>
            </footer>
        </div>
    </div>
</body>
</html>
