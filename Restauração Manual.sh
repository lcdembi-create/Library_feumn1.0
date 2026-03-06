# Listar backups
ls -la /backup/koha/

# Restaurar banco
gunzip < backup_file.sql.gz | mysql koha_feumnbib

# Restaurar configurações
tar -xzf backup_config.tar.gz -C /