// PerformanceDashboard.js
class PerformanceDashboard {
    constructor() {
        this.charts = {};
        this.init();
    }

    async init() {
        await this.loadRedisStats();
        this.setupCharts();
        setInterval(() => this.loadRedisStats(), 30000); // 30s
    }

    async loadRedisStats() {
        try {
            const response = await fetch('/api/v1/feumn-taxas/cache-stats');
            const stats = await response.json();

            this.updateStatsUI(stats);
            this.updateHitRateChart(stats);
        } catch (error) {
            console.error('Erro ao carregar stats Redis:', error);
        }
    }

    updateStatsUI(stats) {
        document.getElementById('cache-hits').textContent = stats.hits;
        document.getElementById('cache-misses').textContent = stats.misses;
        document.getElementById('cache-hit-rate').textContent = stats.hit_rate;
        document.getElementById('cache-keys').textContent = stats.keys;
        document.getElementById('cache-memory').textContent = stats.memory;
    }

    setupCharts() {
        const ctx = document.getElementById('hit-rate-chart').getContext('2d');
        
        this.charts.hitRate = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Cache Hit Rate (%)',
                    data: [],
                    borderColor: '#003366',
                    backgroundColor: 'rgba(0, 51, 102, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'Eficiência do Cache Redis'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                },
                animation: {
                    duration: 0
                }
            }
        });

        // Adicionar pontos históricos a cada 30s
        setInterval(() => {
            const now = new Date().toLocaleTimeString();
            this.charts.hitRate.data.labels.push(now);
            
            if (this.charts.hitRate.data.labels.length > 20) {
                this.charts.hitRate.data.labels.shift();
                this.charts.hitRate.data.datasets[0].data.shift();
            }
            
            this.charts.hitRate.update();
        }, 30000);
    }

    updateHitRateChart(stats) {
        if (this.charts.hitRate.data.datasets[0].data.length > 0) {
            this.charts.hitRate.data.datasets[0].data.push(
                parseFloat(stats.hit_rate)
            );
        }
    }
}