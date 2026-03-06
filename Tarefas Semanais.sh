# Verificar integridade do banco
mysqlcheck -o koha_feumnbib

# Limpar cache Redis
redis-cli FLUSHDB

# Gerar relatório semanal
/usr/share/koha/bin/cronjobs/feumn_weekly_report.pl