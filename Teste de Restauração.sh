# Criar banco de teste
mysql -e "CREATE DATABASE koha_feumn_test"

# Importar backup
gunzip < backup.sql.gz | mysql koha_feumn_test

# Verificar dados
mysql koha_feumn_test -e "SELECT COUNT(*) FROM borrowers"