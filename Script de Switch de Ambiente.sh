#!/bin/bash
# switch-env.sh - Alterna entre ambientes

set -e

ENV=$1
CONFIG_DIR="/etc/koha/feumn"

case $ENV in
    development)
        echo "🔧 Mudando para ambiente DEVELOPMENT..."
        
        # Backup da configuração atual
        cp $CONFIG_DIR/koha-conf.xml $CONFIG_DIR/koha-conf.xml.bak
        
        # Aplicar configuração de desenvolvimento
        cp config/development.xml $CONFIG_DIR/koha-conf.xml
        
        # Ativar mock EMIS
        export FEUMN_EMIS_MOCK=1
        export FEUMN_EMIS_MOCK_URL="http://localhost:3000"
        
        # Configurar logging detalhado
        perl -pi -e 's/log_level = INFO/log_level = DEBUG/' $CONFIG_DIR/logging.conf
        
        echo "✅ Ambiente DEVELOPMENT ativado"
        echo "   EMIS Mock: http://localhost:3000"
        echo "   Logs: /var/log/koha/feumn-dev.log"
        ;;
        
    production)
        echo "🔒 Mudando para ambiente PRODUCTION..."
        
        # Verificar se é seguro
        read -p "Tem certeza? Isso afetará o sistema em produção (s/N): " confirm
        if [[ $confirm != "s" && $confirm != "S" ]]; then
            echo "❌ Operação cancelada"
            exit 1
        fi
        
        # Restaurar configuração
        if [ -f $CONFIG_DIR/koha-conf.xml.bak ]; then
            cp $CONFIG_DIR/koha-conf.xml.bak $CONFIG_DIR/koha-conf.xml
        fi
        
        # Desativar mock
        unset FEUMN_EMIS_MOCK
        unset FEUMN_EMIS_MOCK_URL
        
        # Configurar logging normal
        perl -pi -e 's/log_level = DEBUG/log_level = INFO/' $CONFIG_DIR/logging.conf
        
        # Reiniciar serviços
        systemctl restart apache2
        systemctl restart koha-common
        
        echo "✅ Ambiente PRODUCTION ativado"
        ;;
        
    test)
        echo "🧪 Mudando para ambiente TEST..."
        
        # Configurar banco de teste
        mysql -e "CREATE DATABASE IF NOT EXISTS koha_feumn_test"
        
        # Carregar dados de teste
        mysql koha_feumn_test < tests/fixtures/test_data.sql
        
        # Ativar modo mock
        export FEUMN_EMIS_MOCK=1
        export FEUMN_EMIS_MOCK_AUTO_CONFIRM=1
        
        echo "✅ Ambiente TEST ativado"
        echo "   Banco: koha_feumn_test"
        echo "   Pagamentos auto-confirmados"
        ;;
        
    *)
        echo "Uso: ./switch-env.sh [development|production|test]"
        exit 1
        ;;
esac

# Reload Koha
koha-plack --restart feumnbib

echo "🎯 Ambiente alterado com sucesso!"