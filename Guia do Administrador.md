# 👨‍💼 Guia do Administrador - Biblioteca FEUMN

## Índice
1. [Dashboard](#dashboard)
2. [Gestão de Usuários](#gestão-de-usuários)
3. [Gestão de Taxas](#gestão-de-taxas)
4. [Relatórios](#relatórios)
5. [Manutenção](#manutenção)
6. [Backup e Recuperação](#backup-e-recuperação)
7. [Resolução de Problemas](#resolução-de-problemas)

## Dashboard

### Visão Geral
O dashboard oferece uma visão completa do sistema:

**Métricas Principais:**
- Total de usuários ativos
- Pagamentos pendentes
- Receita mensal
- Taxa de rotação do acervo

**Gráficos:**
- Receita por mês
- Usuários por faculdade
- Itens mais emprestados
- Status de pagamentos

### Acessando
1. URL: https://biblioteca.fe-umn.ao:8080
2. Login com credenciais de administrador
3. Menu: "Dashboard FEUMN"

## Gestão de Usuários

### Criar Usuário
1. Menu: "Usuários > Adicionar usuário"
2. Preencher dados pessoais
3. Selecionar faculdade
4. Escolher categoria
5. Sistema gera taxa automaticamente
6. Clique em "Salvar"

### Categorias de Usuários

| Categoria | Taxa | Período | Privilégios |
|-----------|------|---------|-------------|
| EST_FEUMN | 5000 | Anual | 3 livros / 14 dias |
| EST_FDU | 5000 | Anual | 3 livros / 14 dias |
| EST_FCS | 5000 | Anual | 3 livros / 14 dias |
| EST_FCT | 7500 | Anual | 4 livros / 21 dias |
| DOC | 0 | Anual | 10 livros / 30 dias |
| FUNC | 2500 | Anual | 5 livros / 21 dias |
| EXT | 15000 | Semestral | 2 livros / 7 dias |

### Bloqueios
- Automático: Pagamento pendente > 7 dias
- Manual: Menu "Usuário > Bloquear"
- Motivos: Extraviou livro, comportamento inadequado

## Gestão de Taxas

### Configurar Valores
1. Menu: "Plugins > Sistema de Taxas FEUMN"
2. Ajustar valores por categoria
3. Definir período de validade
4. Salvar configurações

### Verificar Pagamentos
1. Menu: "Relatórios > Pagamentos Pendentes"
2. Lista de referências aguardando
3. Confirmar manualmente se necessário
4. Histórico completo disponível

### Relatório de Inadimplentes
1. Menu: "Relatórios > Inadimplentes"
2. Exportar para Excel/PDF
3. Enviar lembretes em massa
4. Ações: Bloquear / Notificar

## Relatórios

### Relatórios Pré-definidos

```sql
-- 1. Usuários por Faculdade
SELECT f.nome, COUNT(*) as total
FROM borrowers b
JOIN feumn_faculdades f ON b.faculdade_id = f.id
GROUP BY f.nome;

-- 2. Receita por Mês
SELECT DATE_FORMAT(paid_at, '%Y-%m') as mes,
       SUM(amount) as total
FROM feumn_taxas
WHERE status = 'paid'
GROUP BY mes
ORDER BY mes DESC;

-- 3. Itens Mais Emprestados
SELECT b.title, COUNT(*) as vezes
FROM items i
JOIN biblio b ON i.biblionumber = b.biblionumber
JOIN issues iss ON i.itemnumber = iss.itemnumber
GROUP BY b.biblionumber
ORDER BY vezes DESC
LIMIT 10;