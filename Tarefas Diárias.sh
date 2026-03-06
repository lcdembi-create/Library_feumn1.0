# Verificar logs
tail -f /var/log/koha/feumn/feumn.log

# Verificar pagamentos pendentes
/usr/share/koha/bin/cronjobs/feumn_check_payments.pl

# Backup automático (2h)
ls -la /backup/koha/