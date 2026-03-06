# Arquivar logs antigos
logrotate /etc/logrotate.d/koha-feumn

# Verificar espaço em disco
df -h /backup/koha/

# Atualizar sistema
apt update && apt upgrade -y