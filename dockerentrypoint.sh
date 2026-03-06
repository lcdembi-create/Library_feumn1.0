#!/bin/bash
set -e

# Aguardar MySQL
echo "Aguardando MySQL..."
while ! mysqladmin ping -h"$KOHA_DB_HOST" --silent; do
    sleep 1
done

# Aguardar Redis
echo "Aguardando Redis..."
while ! redis-cli -h redis -a "$REDIS_PASSWORD" ping; do
    sleep 1
done

# Configurar variáveis de ambiente para plugins
export FEUMN_EMIS_API_KEY
export FEUMN_EMIS_MOCK

# Executar script de pós-instalação se necessário
if [ ! -f /usr/share/koha/.installed ]; then
    echo "Executando pós-instalação..."
    /opt/koha-feumn/scripts/post-install-feumn.sh
    touch /usr/share/koha/.installed
fi

# Iniciar Koha
exec "$@"