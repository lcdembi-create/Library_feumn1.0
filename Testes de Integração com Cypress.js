describe('Fluxo de Pagamentos FEUMN', () => {
    beforeEach(() => {
        cy.login('admin', 'senha_teste');
        cy.visit('/cgi-bin/koha/plugins/run.pl?class=Koha::Plugin::FEUMNTaxas');
    });

    it('deve gerar referência de pagamento', () => {
        cy.get('#borrowernumber').type('1001');
        cy.get('#gerar-referencia').click();
        
        cy.get('#reference-modal').should('be.visible');
        cy.get('#reference-number').should('contain', 'FEUMN');
        cy.get('#reference-amount').should('contain', '5.000');
        cy.get('#reference-barcode').should('be.visible');
    });

    it('deve listar pagamentos pendentes', () => {
        cy.get('#payments-table').should('be.visible');
        cy.get('.badge.bg-warning').should('contain', 'Pendente');
    });

    it('deve confirmar pagamento manualmente', () => {
        cy.get('tr:first-child .btn-confirmar').click();
        cy.get('.alert-success').should('contain', 'Pagamento confirmado');
    });

    it('deve bloquear usuário inadimplente', () => {
        cy.visit('/cgi-bin/koha/members/memberentry.pl?op=modify&borrowernumber=1002');
        cy.get('#debarred').should('contain', 'Taxa pendente');
        cy.get('input[type="submit"]').should('be.disabled');
    });

    it('deve liberar acesso após pagamento', () => {
        // Simular webhook
        cy.request({
            method: 'POST',
            url: '/api/webhook-emis',
            headers: {
                'X-EMIS-Signature': 'valid-signature'
            },
            body: {
                event: 'payment.confirmed',
                reference: 'FEUMN1001001',
                amount: 5000
            }
        });

        cy.visit('/cgi-bin/koha/members/memberentry.pl?op=modify&borrowernumber=1001');
        cy.get('#debarred').should('not.exist');
    });
});