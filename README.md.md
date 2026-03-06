# 📚 Sistema de Gestão de Biblioteca FEUMN - Koha

## Sobre o Projeto
Sistema de gerenciamento de biblioteca baseado em Koha para a Faculdade de Economia da Universidade Mandume Ya Ndemufayo (FEUMN), com suporte a múltiplas faculdades, integração de pagamentos EMIS e dashboard administrativo.

## 🚀 Tecnologias
- **Koha 25.11 LTS** - Sistema de biblioteca
- **Perl 5.34+** - Backend e plugins
- **MySQL 8.0** - Banco de dados
- **Redis 7** - Cache e sessões
- **Docker** - Containerização
- **JavaScript** - Dashboard e interfaces

## 📋 Pré-requisitos
- Docker e Docker Compose
- Git
- Domínio configurado (biblioteca.fe-umn.ao)
- Certificado SSL (auto-configurado via Coolify)

## 🔧 Instalação Rápida

### Com Coolify (recomendado)
1. Importe este repositório no Coolify
2. Configure as variáveis de ambiente
3. Acesse https://biblioteca.fe-umn.ao

### Manualmente com Docker
```bash
git clone https://github.com/feumn/koha-biblioteca.git
cd koha-biblioteca
cp .env.example .env
# Edite .env com suas senhas
docker-compose up -d