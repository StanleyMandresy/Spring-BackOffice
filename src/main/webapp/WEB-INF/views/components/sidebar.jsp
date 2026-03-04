<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* Sidebar specific styles */
    .sidebar {
        position: fixed;
        top: 0;
        left: 0;
        height: 100vh;
        width: 280px;
        background: linear-gradient(180deg, #B5C99A 0%, #97A97C 50%, #87986A 100%);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
        z-index: 1000;
        transition: transform 0.3s ease;
        overflow-y: auto;
        overflow-x: hidden;
    }

    .sidebar.collapsed {
        transform: translateX(-280px);
    }

    @media (max-width: 768px) {
        .sidebar {
            transform: translateX(-280px);
        }
        .sidebar.mobile-open {
            transform: translateX(0);
        }
    }

    .sidebar-header {
        padding: 25px 20px;
        border-bottom: 2px solid rgba(255, 255, 255, 0.2);
        background: rgba(255, 255, 255, 0.1);
    }

    .sidebar-logo {
        font-size: 28px;
        font-weight: 900;
        color: white;
        text-align: center;
        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
    }

    .sidebar-menu {
        padding: 20px 10px;
    }

    .menu-section {
        margin-bottom: 25px;
    }

    .menu-section-title {
        color: rgba(255, 255, 255, 0.7);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        padding: 0 15px 10px;
        margin-bottom: 5px;
    }

    .menu-item {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 14px 15px;
        margin: 5px 0;
        border-radius: 12px;
        color: white;
        text-decoration: none;
        transition: all 0.3s ease;
        font-weight: 500;
        position: relative;
        overflow: hidden;
    }

    .menu-item::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s;
    }

    .menu-item:hover::before {
        left: 100%;
    }

    .menu-item:hover {
        background: rgba(255, 255, 255, 0.15);
        transform: translateX(5px);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    }

    .menu-item.active {
        background: rgba(255, 255, 255, 0.25);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        border-left: 4px solid white;
    }

    .menu-item i {
        font-size: 20px;
        width: 24px;
        text-align: center;
    }

    .menu-item-text {
        flex: 1;
        font-size: 15px;
    }

    .menu-badge {
        background: rgba(255, 255, 255, 0.3);
        color: white;
        padding: 2px 8px;
        border-radius: 10px;
        font-size: 11px;
        font-weight: 700;
    }

    /* Sidebar toggle button */
    .sidebar-toggle {
        position: fixed;
        top: 20px;
        left: 20px;
        z-index: 1001;
        background: linear-gradient(135deg, #87986A, #718355);
        color: white;
        border: none;
        padding: 12px 15px;
        border-radius: 12px;
        cursor: pointer;
        box-shadow: 0 4px 15px rgba(135, 152, 106, 0.4);
        transition: all 0.3s ease;
        display: none;
    }

    @media (max-width: 768px) {
        .sidebar-toggle {
            display: block;
        }
    }

    .sidebar-toggle:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 20px rgba(135, 152, 106, 0.6);
    }

    /* Main content margin */
    .main-content-with-sidebar {
        margin-left: 280px;
        transition: margin-left 0.3s ease;
    }

    @media (max-width: 768px) {
        .main-content-with-sidebar {
            margin-left: 0;
        }
    }

    /* Sidebar footer */
    .sidebar-footer {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        padding: 20px;
        background: rgba(0, 0, 0, 0.2);
        border-top: 2px solid rgba(255, 255, 255, 0.2);
    }

    .sidebar-user {
        display: flex;
        align-items: center;
        gap: 12px;
        color: white;
    }

    .sidebar-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        font-size: 18px;
    }

    .sidebar-user-info {
        flex: 1;
    }

    .sidebar-user-name {
        font-weight: 700;
        font-size: 14px;
    }

    .sidebar-user-role {
        font-size: 11px;
        opacity: 0.8;
    }

    /* Custom scrollbar for sidebar */
    .sidebar::-webkit-scrollbar {
        width: 6px;
    }

    .sidebar::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.1);
    }

    .sidebar::-webkit-scrollbar-thumb {
        background: rgba(255, 255, 255, 0.3);
        border-radius: 10px;
    }

    .sidebar::-webkit-scrollbar-thumb:hover {
        background: rgba(255, 255, 255, 0.5);
    }

    /* Backdrop for mobile */
    .sidebar-backdrop {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: 999;
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
    }

    .sidebar-backdrop.active {
        display: block;
    }

    /* Submenu styles */
    .submenu {
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.3s ease;
        padding-left: 20px;
    }

    .submenu.open {
        max-height: 500px;
    }

    .submenu-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 15px;
        margin: 3px 0;
        border-radius: 8px;
        color: rgba(255, 255, 255, 0.9);
        text-decoration: none;
        transition: all 0.3s ease;
        font-size: 14px;
    }

    .submenu-item:hover {
        background: rgba(255, 255, 255, 0.1);
        transform: translateX(5px);
    }

    .submenu-item i {
        font-size: 14px;
    }

    .menu-item.has-submenu {
        cursor: pointer;
    }

    .menu-item .submenu-arrow {
        transition: transform 0.3s ease;
        margin-left: auto;
    }

    .menu-item.open .submenu-arrow {
        transform: rotate(180deg);
    }
</style>

<!-- Sidebar Toggle Button (Mobile) -->
<button class="sidebar-toggle" id="sidebarToggle">
    <i class="fas fa-bars"></i>
</button>

<!-- Sidebar Backdrop (Mobile) -->
<div class="sidebar-backdrop" id="sidebarBackdrop"></div>

<!-- Sidebar -->
<div class="sidebar" id="mainSidebar">
    <!-- Header -->
    <div class="sidebar-header">
        <div class="sidebar-logo">
            <i class="fas fa-shield-alt"></i>
            <span>BackOffice</span>
        </div>
    </div>

    <!-- Menu -->
    <div class="sidebar-menu">
        
        <!-- Dashboard Section -->
        <div class="menu-section">
            <div class="menu-section-title">
                <i class="fas fa-home"></i> Principal
            </div>
            <a href="${pageContext.request.contextPath}/" class="menu-item" data-page="dashboard">
                <i class="fas fa-chart-line"></i>
                <span class="menu-item-text">Dashboard</span>
            </a>
        </div>

        <!-- Reservations Section -->
        <div class="menu-section">
            <div class="menu-section-title">
                <i class="fas fa-ticket-alt"></i> Réservations
            </div>
            
            <a href="${pageContext.request.contextPath}/reservation/list" class="menu-item" data-page="reservation-list">
                <i class="fas fa-list"></i>
                <span class="menu-item-text">Liste</span>
                <span class="menu-badge">Voir</span>
            </a>
            
            <a href="${pageContext.request.contextPath}/reservation/form" class="menu-item" data-page="reservation-form">
                <i class="fas fa-plus-circle"></i>
                <span class="menu-item-text">Nouvelle</span>
            </a>
        </div>

        <!-- Vehicles Section -->
        <div class="menu-section">
            <div class="menu-section-title">
                <i class="fas fa-car"></i> Véhicules
            </div>
            
            <a href="${pageContext.request.contextPath}/vehicule/list" class="menu-item" data-page="vehicule-list">
                <i class="fas fa-cars"></i>
                <span class="menu-item-text">Parc Auto</span>
            </a>
            
            <a href="${pageContext.request.contextPath}/vehicule/form" class="menu-item" data-page="vehicule-form">
                <i class="fas fa-car-side"></i>
                <span class="menu-item-text">Ajouter</span>
            </a>
        </div>

        <!-- Planning Section -->
        <div class="menu-section">
            <div class="menu-section-title">
                <i class="fas fa-calendar"></i> Planification
            </div>
            
            <a href="${pageContext.request.contextPath}/planification" class="menu-item" data-page="planification-form">
                <i class="fas fa-calendar-alt"></i>
                <span class="menu-item-text">Planning</span>
                <span class="menu-badge">New</span>
            </a>
        </div>

        <!-- Settings Section -->
        <div class="menu-section">
            <div class="menu-section-title">
                <i class="fas fa-cog"></i> Système
            </div>
            
            <a href="#" class="menu-item" data-page="settings">
                <i class="fas fa-sliders-h"></i>
                <span class="menu-item-text">Paramètres</span>
            </a>
            
            <a href="#" class="menu-item" data-page="api">
                <i class="fas fa-code"></i>
                <span class="menu-item-text">API</span>
            </a>
        </div>

    </div>

    <!-- Footer -->
    <div class="sidebar-footer">
        <div class="sidebar-user">
            <div class="sidebar-avatar">
                <i class="fas fa-user"></i>
            </div>
            <div class="sidebar-user-info">
                <div class="sidebar-user-name">Admin</div>
                <div class="sidebar-user-role">Gestionnaire</div>
            </div>
            <i class="fas fa-sign-out-alt" style="cursor: pointer; opacity: 0.8;"></i>
        </div>
    </div>
</div>

<script>
    // Sidebar functionality
    (function() {
        const sidebar = document.getElementById('mainSidebar');
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebarBackdrop = document.getElementById('sidebarBackdrop');
        
        // Toggle sidebar on mobile
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', function() {
                sidebar.classList.toggle('mobile-open');
                sidebarBackdrop.classList.toggle('active');
            });
        }
        
        // Close sidebar when clicking backdrop
        if (sidebarBackdrop) {
            sidebarBackdrop.addEventListener('click', function() {
                sidebar.classList.remove('mobile-open');
                sidebarBackdrop.classList.remove('active');
            });
        }

        // Set active menu item based on current URL
        const currentPath = window.location.pathname;
        const menuItems = document.querySelectorAll('.menu-item[data-page]');
        
        menuItems.forEach(item => {
            const href = item.getAttribute('href');
            if (currentPath.includes(href) && href !== '${pageContext.request.contextPath}/') {
                item.classList.add('active');
            } else if (currentPath === '${pageContext.request.contextPath}/' && href === '${pageContext.request.contextPath}/') {
                item.classList.add('active');
            }
        });

        // Submenu toggle functionality
        const menuItemsWithSubmenu = document.querySelectorAll('.menu-item.has-submenu');
        menuItemsWithSubmenu.forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                this.classList.toggle('open');
                const submenu = this.nextElementSibling;
                if (submenu && submenu.classList.contains('submenu')) {
                    submenu.classList.toggle('open');
                }
            });
        });

        // Close sidebar on mobile when clicking a link
        const allMenuLinks = document.querySelectorAll('.menu-item, .submenu-item');
        allMenuLinks.forEach(link => {
            link.addEventListener('click', function() {
                if (window.innerWidth <= 768) {
                    sidebar.classList.remove('mobile-open');
                    sidebarBackdrop.classList.remove('active');
                }
            });
        });

        // Animate menu items on load
        if (typeof anime !== 'undefined') {
            anime({
                targets: '.menu-item',
                translateX: [-50, 0],
                opacity: [0, 1],
                duration: 800,
                delay: anime.stagger(50),
                easing: 'easeOutExpo'
            });
        }
    })();
</script>
