FROM koha/koha:25.11

# Instalar cron
RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/*

# Copiar scripts de manutenção
COPY scripts/maintenance/ /etc/periodic/

# Configurar crontab
RUN echo "0 2 * * * /etc/periodic/daily.sh" > /etc/crontab
RUN echo "0 3 * * 0 /etc/periodic/weekly.sh" >> /etc/crontab
RUN echo "0 4 1 * * /etc/periodic/monthly.sh" >> /etc/crontab

# Script de entrada
COPY docker/cron-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["cron", "-f"]