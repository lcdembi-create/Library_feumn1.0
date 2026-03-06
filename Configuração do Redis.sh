#!/bin/bash
# setup-redis.sh

echo "📦 Configurando Redis para FEUMN Koha..."

# Instalar Redis
sudo apt-get update
sudo apt-get install -y redis-server redis-tools

# Configurar Redis
sudo tee /etc/redis/redis.conf > /dev/null << 'EOF'
# Configuração Redis FEUMN
port 6379
bind 127.0.0.1
protected-mode yes
daemonize yes
pidfile /var/run/redis/redis-server.pid
loglevel notice
logfile /var/log/redis/redis-server.log

# Persistência
save 900 1
save 300 10
save 60 10000
rdbcompression yes
dbfilename dump.rdb
dir /var/lib/redis

# Limite de memória
maxmemory 2gb
maxmemory-policy allkeys-lru
maxmemory-samples 10

# Conexões
timeout 0
tcp-keepalive 300
maxclients 10000

# Performance
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60

# Segurança
requirepass $(openssl rand -base64 32)
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command CONFIG ""

# Slow log
slowlog-log-slower-than 10000
slowlog-max-len 1024
EOF

# Instalar módulos Perl para Redis
sudo cpanm Redis Redis::Fast

# Configurar firewall
sudo ufw allow from 127.0.0.1 to any port 6379

# Iniciar Redis
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Criar script de monitoramento
sudo tee /usr/local/bin/redis-monitor.sh > /dev/null << 'EOF'
#!/bin/bash
redis-cli -a $REDIS_PASS INFO stats | grep -E "keyspace|hitrate"
EOF

sudo chmod +x /usr/local/bin/redis-monitor.sh

echo "✅ Redis configurado com sucesso!"