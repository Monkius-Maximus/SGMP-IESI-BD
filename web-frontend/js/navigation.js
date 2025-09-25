/* ============================================================================
   SGMP - Navigation and Menu Management
   ============================================================================ */

// Navigation Manager
const NavigationManager = {
    // Initialize navigation
    init: function() {
        this.setupMenuHandlers();
        this.setupMobileMenu();
        this.setupSubmenus();
        this.handleInitialRoute();
    },

    // Setup menu click handlers
    setupMenuHandlers: function() {
        const menuItems = document.querySelectorAll('.sidebar-menu .menu-item > a');
        
        menuItems.forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                
                const menuItem = item.parentElement;
                const page = menuItem.getAttribute('data-page');
                
                if (page) {
                    this.navigateToPage(page);
                }
                
                // Handle submenu toggle
                const hasSubmenu = menuItem.querySelector('.submenu');
                if (hasSubmenu) {
                    this.toggleSubmenu(menuItem);
                }
            });
        });

        // Handle submenu items
        const submenuItems = document.querySelectorAll('.submenu a');
        submenuItems.forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const href = item.getAttribute('href');
                if (href && href.startsWith('#')) {
                    const page = href.substring(1);
                    this.navigateToPage(page);
                }
            });
        });
    },

    // Setup mobile menu functionality
    setupMobileMenu: function() {
        const sidebarToggle = document.getElementById('sidebar-toggle');
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');

        // Toggle mobile sidebar
        sidebarToggle?.addEventListener('click', () => {
            if (window.innerWidth <= 768) {
                sidebar.classList.toggle('open');
                
                // Add overlay for mobile
                this.toggleMobileOverlay(sidebar.classList.contains('open'));
            } else {
                // Desktop sidebar collapse
                sidebar.classList.toggle('collapsed');
                localStorage.setItem('sgmp_sidebar_collapsed', sidebar.classList.contains('collapsed'));
            }
        });

        // Close mobile menu when clicking outside
        document.addEventListener('click', (e) => {
            if (window.innerWidth <= 768 && 
                !sidebar.contains(e.target) && 
                !sidebarToggle.contains(e.target) &&
                sidebar.classList.contains('open')) {
                sidebar.classList.remove('open');
                this.toggleMobileOverlay(false);
            }
        });

        // Handle window resize
        window.addEventListener('resize', () => {
            this.handleResize();
        });
    },

    // Setup submenu functionality
    setupSubmenus: function() {
        const menuItemsWithSubmenu = document.querySelectorAll('.menu-item:has(.submenu)');
        
        menuItemsWithSubmenu.forEach(item => {
            const link = item.querySelector('> a');
            const submenu = item.querySelector('.submenu');
            
            // Add submenu indicator
            if (!link.querySelector('.submenu-indicator')) {
                const indicator = document.createElement('i');
                indicator.className = 'fas fa-chevron-down submenu-indicator';
                link.appendChild(indicator);
            }
        });
    },

    // Toggle submenu
    toggleSubmenu: function(menuItem) {
        const submenu = menuItem.querySelector('.submenu');
        const indicator = menuItem.querySelector('.submenu-indicator');
        
        if (submenu) {
            const isOpen = submenu.classList.contains('open');
            
            // Close all other submenus
            document.querySelectorAll('.submenu.open').forEach(sub => {
                if (sub !== submenu) {
                    sub.classList.remove('open');
                    const otherIndicator = sub.parentElement.querySelector('.submenu-indicator');
                    if (otherIndicator) {
                        otherIndicator.style.transform = 'rotate(0deg)';
                    }
                }
            });
            
            // Toggle current submenu
            submenu.classList.toggle('open');
            
            if (indicator) {
                indicator.style.transform = isOpen ? 'rotate(0deg)' : 'rotate(180deg)';
            }
        }
    },

    // Navigate to specific page
    navigateToPage: function(page) {
        // Update active menu state
        this.updateActiveMenu(page);
        
        // Show corresponding content
        this.showPageContent(page);
        
        // Update URL
        history.pushState({ page }, '', `#${page}`);
        
        // Close mobile menu
        if (window.innerWidth <= 768) {
            document.getElementById('sidebar').classList.remove('open');
            this.toggleMobileOverlay(false);
        }
        
        // Load page data if SGMP is available
        if (window.SGMP && typeof window.SGMP.loadPageData === 'function') {
            window.SGMP.loadPageData(page);
        }
    },

    // Update active menu item
    updateActiveMenu: function(page) {
        // Remove active from all menu items
        document.querySelectorAll('.menu-item').forEach(item => {
            item.classList.remove('active');
        });
        
        // Add active to current page
        const currentMenuItem = document.querySelector(`[data-page="${page}"]`);
        if (currentMenuItem) {
            currentMenuItem.classList.add('active');
            
            // If it's a submenu item, also activate parent
            const parentMenuItem = currentMenuItem.closest('.menu-item:has(.submenu)');
            if (parentMenuItem) {
                parentMenuItem.classList.add('active');
            }
        }
        
        // Handle submenu items
        const submenuLink = document.querySelector(`.submenu a[href="#${page}"]`);
        if (submenuLink) {
            // Remove active from all submenu items
            document.querySelectorAll('.submenu a').forEach(link => {
                link.classList.remove('active');
            });
            
            // Add active to current submenu item
            submenuLink.classList.add('active');
            
            // Activate parent menu item
            const parentMenuItem = submenuLink.closest('.menu-item');
            if (parentMenuItem) {
                parentMenuItem.classList.add('active');
                this.toggleSubmenu(parentMenuItem);
            }
        }
    },

    // Show page content
    showPageContent: function(page) {
        // Hide all page contents
        document.querySelectorAll('.page-content').forEach(content => {
            content.classList.remove('active');
        });
        
        // Show target content
        const targetContent = document.getElementById(`${page}-content`);
        if (targetContent) {
            targetContent.classList.add('active');
        } else {
            // If specific page content doesn't exist, show a placeholder
            this.showPagePlaceholder(page);
        }
    },

    // Show placeholder for pages not yet implemented
    showPagePlaceholder: function(page) {
        const mainContent = document.getElementById('main-content');
        const existingPlaceholder = document.getElementById('dynamic-placeholder');
        
        if (existingPlaceholder) {
            existingPlaceholder.remove();
        }
        
        const placeholder = document.createElement('div');
        placeholder.id = 'dynamic-placeholder';
        placeholder.className = 'page-content active';
        placeholder.innerHTML = `
            <div class="page-header">
                <h2><i class="fas fa-cog"></i> ${this.getPageTitle(page)}</h2>
                <p>Esta página está em desenvolvimento</p>
            </div>
            <div class="content-placeholder">
                <i class="fas fa-tools"></i>
                <p>Conteúdo do módulo ${this.getPageTitle(page)} será implementado em breve</p>
            </div>
        `;
        
        mainContent.appendChild(placeholder);
    },

    // Get page title from page name
    getPageTitle: function(page) {
        const titles = {
            'dashboard': 'Dashboard',
            'people': 'Gestão de Pessoas',
            'residents': 'Moradores',
            'employees': 'Funcionários',
            'syndics': 'Síndicos',
            'units': 'Unidades',
            'areas': 'Áreas Comuns',
            'reservations': 'Reservas',
            'service-orders': 'Ordens de Serviço',
            'reports': 'Relatórios'
        };
        
        return titles[page] || page.charAt(0).toUpperCase() + page.slice(1);
    },

    // Handle initial route from URL
    handleInitialRoute: function() {
        const hash = window.location.hash.substring(1);
        const page = hash || 'dashboard';
        this.navigateToPage(page);
    },

    // Toggle mobile overlay
    toggleMobileOverlay: function(show) {
        let overlay = document.getElementById('mobile-overlay');
        
        if (show && !overlay) {
            overlay = document.createElement('div');
            overlay.id = 'mobile-overlay';
            overlay.className = 'mobile-overlay';
            overlay.addEventListener('click', () => {
                document.getElementById('sidebar').classList.remove('open');
                this.toggleMobileOverlay(false);
            });
            document.body.appendChild(overlay);
        } else if (!show && overlay) {
            overlay.remove();
        }
    },

    // Handle window resize
    handleResize: function() {
        const sidebar = document.getElementById('sidebar');
        
        if (window.innerWidth > 768) {
            // Desktop mode
            sidebar.classList.remove('open');
            this.toggleMobileOverlay(false);
            
            // Restore collapsed state from localStorage
            const wasCollapsed = localStorage.getItem('sgmp_sidebar_collapsed') === 'true';
            if (wasCollapsed) {
                sidebar.classList.add('collapsed');
            }
        }
    },

    // Breadcrumb functionality
    updateBreadcrumb: function(items) {
        let breadcrumb = document.getElementById('breadcrumb');
        
        if (!breadcrumb) {
            // Create breadcrumb if it doesn't exist
            breadcrumb = document.createElement('nav');
            breadcrumb.id = 'breadcrumb';
            breadcrumb.className = 'breadcrumb';
            
            const mainContent = document.getElementById('main-content');
            const firstPageContent = mainContent.querySelector('.page-content');
            if (firstPageContent) {
                mainContent.insertBefore(breadcrumb, firstPageContent);
            }
        }
        
        breadcrumb.innerHTML = items.map((item, index) => {
            const isLast = index === items.length - 1;
            return `
                <span class="breadcrumb-item ${isLast ? 'active' : ''}">
                    ${isLast ? item : `<a href="#${item.toLowerCase()}">${item}</a>`}
                </span>
            `;
        }).join('<i class="fas fa-chevron-right breadcrumb-separator"></i>');
    }
};

// Initialize navigation when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    NavigationManager.init();
});

// Handle browser back/forward navigation
window.addEventListener('popstate', function(event) {
    if (event.state && event.state.page) {
        NavigationManager.navigateToPage(event.state.page);
    }
});

// Export for global access
window.NavigationManager = NavigationManager;