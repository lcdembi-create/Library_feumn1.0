/**
 * Testes para o Dashboard FEUMN
 * Executar com: npm test dashboard.test.js
 */

const { DashboardFEUMNModerno } = require('../js/dashboard.js');

// Mock do fetch global
global.fetch = jest.fn();

describe('DashboardFEUMNModerno', () => {
    let dashboard;

    beforeEach(() => {
        dashboard = new DashboardFEUMNModerno();
        fetch.mockClear();
    });

    test('deve inicializar corretamente', () => {
        expect(dashboard.apiBase).toBe('/api/v1/feumn-taxas');
        expect(dashboard.charts).toEqual({});
    });

    test('deve carregar estatísticas da API', async () => {
        const mockStats = {
            total_users: 1500,
            active_users: 1200,
            pending_payments: 50,
            monthly_revenue: 750000,
            rotation_rate: 45,
            overdue_items: 23
        };

        fetch.mockImplementationOnce(() => 
            Promise.resolve({
                ok: true,
                json: () => Promise.resolve(mockStats)
            })
        );

        await dashboard.loadStats();

        expect(fetch).toHaveBeenCalledWith('/api/v1/feumn-taxas/stats');
        
        // Verificar se elementos DOM foram atualizados
        // (assumindo jsdom)
    });

    test('deve tratar erros de API', async () => {
        fetch.mockImplementationOnce(() => 
            Promise.reject(new Error('API Error'))
        );

        console.error = jest.fn();
        await dashboard.loadStats();

        expect(console.error).toHaveBeenCalledWith(
            'Erro ao carregar dados:',
            expect.any(Error)
        );
    });

    test('deve gerar referência corretamente', async () => {
        const mockReference = {
            success: true,
            data: {
                reference: 'FEUMN00000001123456',
                amount: 5000,
                emis_url: 'https://emis.gov.ao/pay/123'
            }
        };

        fetch.mockImplementationOnce(() => 
            Promise.resolve({
                ok: true,
                json: () => Promise.resolve(mockReference)
            })
        );

        // Mock do modal
        global.bootstrap = {
            Modal: class {
                constructor() { this.show = jest.fn(); }
            }
        };

        const result = await dashboard.generateReference(1);
        
        expect(fetch).toHaveBeenCalledWith(
            '/api/v1/feumn-taxas/gerar-referencia',
            expect.objectContaining({
                method: 'POST',
                body: JSON.stringify({ borrowernumber: 1 })
            })
        );
    });

    test('deve calcular períodos corretamente', () => {
        const months = dashboard.getLastMonths(6);
        expect(months).toHaveLength(6);
        expect(months[0]).toMatch(/^(Janeiro|Fevereiro|Março|Abril|Maio|Junho)/);
    });
});

describe('Integração com EMIS', () => {
    test('webhook deve validar assinatura', async () => {
        const response = await fetch('/api/webhook-emis', {
            method: 'POST',
            headers: {
                'X-EMIS-Signature': 'invalid-signature'
            },
            body: JSON.stringify({
                event: 'payment.confirmed',
                reference: 'FEUMN123456'
            })
        });

        expect(response.status).toBe(401);
    });
});