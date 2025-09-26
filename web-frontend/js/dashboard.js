/* ============================================================================
   SGMP - Dashboard Functionality
   ============================================================================ */

// Dashboard Manager
const DashboardManager = {
    // Configuration
    config: {
        refreshInterval: 30000, // 30 seconds
        animationDelay: 150,
        chartColors: {
            primary: '#2c3e50',
            secondary: '#3498db',
            success: '#27ae60',
            warning: '#f39c12',
            danger: '#e74c3c',
            info: '#9b59b6'
        }
    },

    // State
    state: {
        isLoading: false,
        lastUpdate: null,
        autoRefresh: true
    },

    // Initialize dashboard
    init: function() {
        this.loadDashboardData();
        this.setupEventListeners();
        this.startAutoRefresh();
        this.animateCards();
    },

    // Setup event listeners
    setupEventListeners: function() {
        // Quick action buttons
        const quickActionButtons = document.querySelectorAll('.action-buttons .btn');
        quickActionButtons.forEach(button => {
            button.addEventListener('click', this.handleQuickAction.bind(this));
        });

        // Summary cards click handlers
        const summaryCards = document.querySelectorAll('.summary-card');
        summaryCards.forEach(card => {
            card.addEventListener('click', this.handleCardClick.bind(this));
            card.style.cursor = 'pointer';
        });

        // Refresh button (if exists)
        const refreshButton = document.getElementById('refresh-dashboard');
        if (refreshButton) {
            refreshButton.addEventListener('click', this.refreshDashboard.bind(this));
        }
    },

    // Load dashboard data
    loadDashboardData: function() {
        this.state.isLoading = true;
        
        // Simulate API call with mock data
        setTimeout(() => {
            this.updateSummaryCards();
            this.updateRecentActivities();
            this.updateCharts();
            this.state.isLoading = false;
            this.state.lastUpdate = new Date();
        }, 1000);
    },

    // Update summary cards
    updateSummaryCards: function() {
        const stats = this.getMockStats();
        
        // Animate numbers
        this.animateNumber('total-residents', stats.totalResidents);
        this.animateUnitsOccupancy(stats.occupiedUnits, stats.totalUnits);
        this.animateNumber('pending-reservations', stats.pendingReservations);
        this.animateNumber('open-service-orders', stats.openServiceOrders);
        
        // Update trends
        this.updateTrends(stats);
    },

    // Animate number counting
    animateNumber: function(elementId, targetValue) {
        const element = document.getElementById(elementId);
        if (!element) return;

        const startValue = parseInt(element.textContent) || 0;
        const difference = targetValue - startValue;
        const duration = 1000;
        const steps = 60;
        const stepValue = difference / steps;
        const stepDuration = duration / steps;

        let currentStep = 0;
        const timer = setInterval(() => {
            currentStep++;
            const currentValue = Math.round(startValue + (stepValue * currentStep));
            element.textContent = currentValue;

            if (currentStep >= steps) {
                clearInterval(timer);
                element.textContent = targetValue;
            }
        }, stepDuration);
    },

    // Animate units occupancy
    animateUnitsOccupancy: function(occupied, total) {
        const element = document.getElementById('occupied-units');
        if (!element) return;

        element.textContent = `${occupied}/${total}`;
        
        // Update progress bar if exists
        const progressBar = element.closest('.summary-card')?.querySelector('.progress-bar');
        if (progressBar) {
            const percentage = (occupied / total) * 100;
            progressBar.style.width = `${percentage}%`;
        }
    },

    // Update trend indicators
    updateTrends: function(stats) {
        // Residents trend
        const residentsTrend = document.querySelector('#total-residents').closest('.card-content').querySelector('.trend');
        if (residentsTrend) {
            const change = Math.floor(Math.random() * 5) + 1; // Mock data
            residentsTrend.innerHTML = `<i class="fas fa-arrow-up"></i> +${change} este mês`;
        }

        // Occupancy percentage
        const unitsOccupancy = (stats.occupiedUnits / stats.totalUnits * 100).toFixed(0);
        const occupancyTrend = document.querySelector('#occupied-units').closest('.card-content').querySelector('.trend');
        if (occupancyTrend) {
            occupancyTrend.innerHTML = `<i class="fas fa-chart-pie"></i> ${unitsOccupancy}% ocupação`;
        }

        // Urgent service orders
        const urgentOrders = Math.floor(stats.openServiceOrders * 0.25);
        const serviceOrdersTrend = document.querySelector('#open-service-orders').closest('.card-content').querySelector('.trend');
        if (serviceOrdersTrend) {
            serviceOrdersTrend.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${urgentOrders} urgentes`;
            serviceOrdersTrend.className = urgentOrders > 0 ? 'trend negative' : 'trend';
        }
    },

    // Update recent activities
    updateRecentActivities: function() {
        const activitiesList = document.getElementById('recent-activities');
        if (!activitiesList) return;

        const mockActivities = this.getMockActivities();
        
        // Clear existing activities (except first few for demo)
        // In a real app, we'd replace all with fresh data
        
        // Add new activities with animation
        mockActivities.forEach((activity, index) => {
            setTimeout(() => {
                this.addActivityItem(activity);
            }, index * 200);
        });
    },

    // Add activity item
    addActivityItem: function(activity) {
        const activitiesList = document.getElementById('recent-activities');
        if (!activitiesList) return;

        const activityElement = document.createElement('div');
        activityElement.className = 'activity-item new-activity';
        activityElement.innerHTML = `
            <div class="activity-icon ${activity.type}">
                <i class="${activity.icon}"></i>
            </div>
            <div class="activity-content">
                <p>${activity.description}</p>
                <span class="activity-time">${activity.time}</span>
            </div>
        `;

        // Add to top of list
        activitiesList.insertBefore(activityElement, activitiesList.firstChild);

        // Remove new-activity class after animation
        setTimeout(() => {
            activityElement.classList.remove('new-activity');
        }, 500);

        // Limit number of activities shown
        const activities = activitiesList.querySelectorAll('.activity-item');
        if (activities.length > 10) {
            activities[activities.length - 1].remove();
        }
    },

    // Update charts
    updateCharts: function() {
        this.updateOccupancyChart();
        // Other charts would be updated here
    },

    // Update occupancy chart
    updateOccupancyChart: function() {
        const chartContainer = document.getElementById('occupancy-chart');
        if (!chartContainer) return;

        // For now, just update the placeholder
        // In a real implementation, this would use Chart.js or similar
        const placeholder = chartContainer.querySelector('.chart-placeholder');
        if (placeholder) {
            placeholder.innerHTML = `
                <div class="mock-chart">
                    <div class="chart-bars">
                        <div class="bar" style="height: 80%"><span>Bloco A: 89%</span></div>
                        <div class="bar" style="height: 75%"><span>Bloco B: 75%</span></div>
                        <div class="bar" style="height: 92%"><span>Bloco C: 92%</span></div>
                        <div class="bar" style="height: 85%"><span>Bloco D: 85%</span></div>
                    </div>
                    <p>Taxa de ocupação por bloco</p>
                </div>
            `;
        }
    },

    // Handle quick action buttons
    handleQuickAction: function(event) {
        const button = event.currentTarget;
        const action = button.onclick?.toString().match(/openModal\('(.+?)'\)/)?.[1] || 
                      button.textContent.trim();
        
        // Show loading state
        const originalContent = button.innerHTML;
        button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processando...';
        button.disabled = true;

        // Simulate action
        setTimeout(() => {
            button.innerHTML = originalContent;
            button.disabled = false;
            
            this.showActionResult(action);
        }, 1500);
    },

    // Show action result
    showActionResult: function(action) {
        const messages = {
            'new-resident': 'Formulário de novo morador aberto',
            'new-reservation': 'Sistema de reservas aberto',
            'new-service-order': 'Nova ordem de serviço criada',
            'generate-report': 'Relatório sendo gerado...'
        };
        
        const message = messages[action] || `Ação executada: ${action}`;
        
        if (window.SGMP && window.SGMP.utils) {
            window.SGMP.utils.showNotification(message, 'success');
        } else {
            alert(message);
        }
    },

    // Handle summary card clicks
    handleCardClick: function(event) {
        const card = event.currentTarget;
        const cardType = Array.from(card.classList).find(cls => 
            ['residents', 'units', 'reservations', 'service-orders'].includes(cls.replace('summary-card', '').trim())
        );

        if (cardType) {
            const pageMap = {
                'residents': 'people',
                'units': 'units',
                'reservations': 'reservations',
                'service-orders': 'service-orders'
            };
            
            const page = pageMap[cardType];
            if (page && window.NavigationManager) {
                window.NavigationManager.navigateToPage(page);
            }
        }
    },

    // Animate cards on load
    animateCards: function() {
        const cards = document.querySelectorAll('.summary-card');
        cards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            
            setTimeout(() => {
                card.style.transition = 'all 0.6s ease-out';
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, index * this.config.animationDelay);
        });
    },

    // Start auto refresh
    startAutoRefresh: function() {
        if (!this.state.autoRefresh) return;

        setInterval(() => {
            if (!this.state.isLoading) {
                this.refreshDashboard();
            }
        }, this.config.refreshInterval);
    },

    // Refresh dashboard
    refreshDashboard: function() {
        console.log('🔄 Atualizando dashboard...');
        this.loadDashboardData();
        
        // Show refresh feedback
        if (window.SGMP && window.SGMP.utils) {
            window.SGMP.utils.showNotification('Dashboard atualizado', 'info');
        }
    },

    // Get mock statistics
    getMockStats: function() {
        const baseStats = {
            totalResidents: 152,
            occupiedUnits: 89,
            totalUnits: 100,
            pendingReservations: 7,
            openServiceOrders: 12
        };

        // Add some randomness to simulate real data
        return {
            ...baseStats,
            totalResidents: baseStats.totalResidents + Math.floor(Math.random() * 3) - 1,
            pendingReservations: Math.max(0, baseStats.pendingReservations + Math.floor(Math.random() * 3) - 1),
            openServiceOrders: Math.max(0, baseStats.openServiceOrders + Math.floor(Math.random() * 5) - 2)
        };
    },

    // Get mock activities
    getMockActivities: function() {
        const activities = [
            {
                type: 'new-resident',
                icon: 'fas fa-user-plus',
                description: '<strong>Ana Paula</strong> foi cadastrada no Apto 205',
                time: 'há 1 hora'
            },
            {
                type: 'reservation',
                icon: 'fas fa-calendar-plus',
                description: '<strong>Carlos Mendes</strong> reservou a Quadra de Tênis',
                time: 'há 2 horas'
            }
        ];

        return activities.slice(0, Math.floor(Math.random() * activities.length) + 1);
    }
};

// Initialize dashboard when page loads
document.addEventListener('DOMContentLoaded', function() {
    // Check if we're on the dashboard
    if (document.getElementById('dashboard-content')) {
        DashboardManager.init();
    }
});

// Re-initialize when navigating to dashboard
document.addEventListener('pageChanged', function(event) {
    if (event.detail.page === 'dashboard') {
        DashboardManager.init();
    }
});

// Export for global access
window.DashboardManager = DashboardManager;