/* ============================================================================
   SGMP - Sistema de Gerenciamento e Manutenção Predial
   Main Application JavaScript
   ============================================================================ */

// Global Application State
const SGMP = {
    state: {
        currentUser: {
            id: 1,
            name: 'Síndico Admin',
            role: 'syndic',
            permissions: ['read', 'write', 'approve']
        },
        currentPage: 'dashboard',
        sidebarCollapsed: false,
        data: {
            residents: [],
            units: [],
            commonAreas: [],
            reservations: [],
            serviceOrders: [],
            employees: [],
            syndics: []
        },
        stats: {
            totalResidents: 152,
            occupiedUnits: 89,
            totalUnits: 100,
            pendingReservations: 7,
            openServiceOrders: 12,
            urgentServiceOrders: 3
        }
    },
    
    // API Configuration (Mock for now)
    api: {
        baseUrl: '/api/v1',
        endpoints: {
            residents: '/residents',
            units: '/units',
            commonAreas: '/common-areas',
            reservations: '/reservations',
            serviceOrders: '/service-orders',
            employees: '/employees',
            syndics: '/syndics',
            reports: '/reports'
        }
    },
    
    // Utility functions
    utils: {
        formatDate: (date) => {
            return new Date(date).toLocaleDateString('pt-BR');
        },
        
        formatCurrency: (amount) => {
            return new Intl.NumberFormat('pt-BR', {
                style: 'currency',
                currency: 'BRL'
            }).format(amount);
        },
        
        formatCPF: (cpf) => {
            return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
        },
        
        validateCPF: (cpf) => {
            cpf = cpf.replace(/[^\d]/g, '');
            if (cpf.length !== 11 || /^(\d)\1{10}$/.test(cpf)) return false;
            
            let sum = 0;
            for (let i = 0; i < 9; i++) {
                sum += parseInt(cpf.charAt(i)) * (10 - i);
            }
            let remainder = (sum * 10) % 11;
            if (remainder === 10 || remainder === 11) remainder = 0;
            if (remainder !== parseInt(cpf.charAt(9))) return false;
            
            sum = 0;
            for (let i = 0; i < 10; i++) {
                sum += parseInt(cpf.charAt(i)) * (11 - i);
            }
            remainder = (sum * 10) % 11;
            if (remainder === 10 || remainder === 11) remainder = 0;
            
            return remainder === parseInt(cpf.charAt(10));
        },
        
        validateEmail: (email) => {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        },
        
        showLoading: () => {
            document.getElementById('loading-overlay').classList.add('show');
        },
        
        hideLoading: () => {
            document.getElementById('loading-overlay').classList.remove('show');
        },
        
        showNotification: (message, type = 'info') => {
            // Create notification element
            const notification = document.createElement('div');
            notification.className = `notification notification-${type}`;
            notification.innerHTML = `
                <div class="notification-content">
                    <i class="fas fa-${type === 'success' ? 'check-circle' : 
                                    type === 'error' ? 'exclamation-circle' : 
                                    type === 'warning' ? 'exclamation-triangle' : 'info-circle'}"></i>
                    <span>${message}</span>
                </div>
                <button class="notification-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;
            
            // Add to page
            document.body.appendChild(notification);
            
            // Auto remove after 5 seconds
            setTimeout(() => {
                if (notification.parentElement) {
                    notification.remove();
                }
            }, 5000);
        }
    },
    
    // Mock data for demonstration
    mockData: {
        residents: [
            {
                id: 1,
                full_name: 'João Silva Santos',
                cpf: '12345678901',
                email: 'joao.silva@email.com',
                phone: '(11) 99999-1234',
                unit: 'Bloco A - Apto 302',
                is_owner: true,
                status: 'active'
            },
            {
                id: 2,
                full_name: 'Maria Oliveira Costa',
                cpf: '98765432109',
                email: 'maria.costa@email.com',
                phone: '(11) 98888-5678',
                unit: 'Bloco B - Apto 105',
                is_owner: false,
                status: 'active'
            }
        ],
        
        serviceOrders: [
            {
                id: 123,
                title: 'Vazamento no Banheiro',
                description: 'Vazamento na torneira do banheiro principal',
                location: 'Bloco A - Apto 105',
                priority: 'high',
                status: 'open',
                created_at: '2024-01-15T10:30:00Z',
                requested_by: 'Maria Santos'
            }
        ],
        
        reservations: [
            {
                id: 1,
                area: 'Salão de Festas',
                resident: 'Maria Santos',
                date: '2024-02-15',
                time: '19:00 - 23:00',
                status: 'pending'
            }
        ]
    }
};

// Application Initialization
document.addEventListener('DOMContentLoaded', function() {
    console.log('🏠 SGMP - Sistema iniciado');
    
    // Initialize application
    SGMP.init();
});

// Main Application Methods
SGMP.init = function() {
    this.loadUserData();
    this.setupEventListeners();
    this.loadDashboardData();
    this.updateUserInterface();
};

SGMP.loadUserData = function() {
    // Load user data from localStorage or API
    const savedUser = localStorage.getItem('sgmp_user');
    if (savedUser) {
        this.state.currentUser = JSON.parse(savedUser);
    }
    
    // Update user info in header
    document.getElementById('current-user').textContent = this.state.currentUser.name;
};

SGMP.setupEventListeners = function() {
    // Sidebar toggle
    const sidebarToggle = document.getElementById('sidebar-toggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', this.toggleSidebar.bind(this));
    }
    
    // Menu navigation
    const menuItems = document.querySelectorAll('.menu-item[data-page]');
    menuItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const page = item.getAttribute('data-page');
            this.navigateToPage(page);
        });
    });
    
    // Window resize handler
    window.addEventListener('resize', this.handleResize.bind(this));
    
    // Handle initial mobile state
    this.handleResize();
};

SGMP.toggleSidebar = function() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('collapsed');
    this.state.sidebarCollapsed = !this.state.sidebarCollapsed;
    
    // Save state
    localStorage.setItem('sgmp_sidebar_collapsed', this.state.sidebarCollapsed);
};

SGMP.handleResize = function() {
    const sidebar = document.getElementById('sidebar');
    const isMobile = window.innerWidth <= 768;
    
    if (isMobile) {
        sidebar.classList.add('mobile');
    } else {
        sidebar.classList.remove('mobile');
        sidebar.classList.remove('open');
    }
};

SGMP.navigateToPage = function(page) {
    // Update state
    this.state.currentPage = page;
    
    // Update active menu item
    document.querySelectorAll('.menu-item').forEach(item => {
        item.classList.remove('active');
    });
    document.querySelector(`[data-page="${page}"]`).classList.add('active');
    
    // Show corresponding content
    document.querySelectorAll('.page-content').forEach(content => {
        content.classList.remove('active');
    });
    
    const targetContent = document.getElementById(`${page}-content`);
    if (targetContent) {
        targetContent.classList.add('active');
        
        // Load page-specific data
        this.loadPageData(page);
    }
    
    // Close mobile sidebar
    if (window.innerWidth <= 768) {
        document.getElementById('sidebar').classList.remove('open');
    }
    
    // Update URL without page reload
    history.pushState({page}, '', `#${page}`);
};

SGMP.loadPageData = function(page) {
    switch(page) {
        case 'dashboard':
            this.loadDashboardData();
            break;
        case 'people':
            this.loadPeopleData();
            break;
        case 'units':
            this.loadUnitsData();
            break;
        case 'areas':
            this.loadAreasData();
            break;
        case 'reservations':
            this.loadReservationsData();
            break;
        case 'service-orders':
            this.loadServiceOrdersData();
            break;
        case 'reports':
            this.loadReportsData();
            break;
    }
};

SGMP.loadDashboardData = function() {
    // Update summary cards with current data
    this.updateSummaryCards();
    this.updateRecentActivities();
};

SGMP.updateSummaryCards = function() {
    document.getElementById('total-residents').textContent = this.state.stats.totalResidents;
    document.getElementById('occupied-units').textContent = 
        `${this.state.stats.occupiedUnits}/${this.state.stats.totalUnits}`;
    document.getElementById('pending-reservations').textContent = this.state.stats.pendingReservations;
    document.getElementById('open-service-orders').textContent = this.state.stats.openServiceOrders;
};

SGMP.updateRecentActivities = function() {
    // This would normally fetch from API
    // For now, we'll use mock data that's already in the HTML
};

SGMP.updateUserInterface = function() {
    // Apply any user-specific customizations
    const userRole = this.state.currentUser.role;
    
    // Hide/show menu items based on permissions
    if (userRole === 'resident') {
        // Hide admin-only sections
        document.querySelector('[data-page="people"]').style.display = 'none';
        document.querySelector('[data-page="reports"]').style.display = 'none';
    }
};

// Load other page data methods (to be implemented)
SGMP.loadPeopleData = function() {
    console.log('Loading people data...');
    // Implementation will be added for other modules
};

SGMP.loadUnitsData = function() {
    console.log('Loading units data...');
};

SGMP.loadAreasData = function() {
    console.log('Loading areas data...');
};

SGMP.loadReservationsData = function() {
    console.log('Loading reservations data...');
};

SGMP.loadServiceOrdersData = function() {
    console.log('Loading service orders data...');
};

SGMP.loadReportsData = function() {
    console.log('Loading reports data...');
};

// Modal functions (called from HTML)
function openModal(type) {
    SGMP.utils.showNotification(`Abrindo modal: ${type}`, 'info');
    // Modal implementation will be added later
}

function generateReport() {
    SGMP.utils.showNotification('Gerando relatório...', 'info');
    // Report generation implementation
}

// Handle browser back/forward navigation
window.addEventListener('popstate', function(event) {
    if (event.state && event.state.page) {
        SGMP.navigateToPage(event.state.page);
    }
});

// Export SGMP object for use in other scripts
window.SGMP = SGMP;