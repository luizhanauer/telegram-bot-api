#!/bin/bash
set -e

# IDs padrão caso o usuário não informe (1000 é o padrão do Ubuntu)
USER_ID=${PUID:-1000}
GROUP_ID=${PGID:-1000}

# Validação obrigatória
if [ -z "$TELEGRAM_API_ID" ] || [ -z "$TELEGRAM_API_HASH" ]; then
    echo -e "\e[31m[ERROR] TELEGRAM_API_ID ou TELEGRAM_API_HASH não configurados!\e[0m"
    exit 1
fi

# Se estiver rodando como ROOT (comportamento padrão do Docker)
if [ "$(id -u)" = '0' ]; then
    echo "[INFO] Ajustando permissões para UID:$USER_ID GID:$GROUP_ID..."
    
    # Cria o grupo e usuário internamente se necessário ou apenas ajusta a pasta
    chown -R "$USER_ID:$GROUP_ID" "$TELEGRAM_WORK_DIR" "$TELEGRAM_TEMP_DIR"
    
    echo "[INFO] Iniciando binário com gosu..."
    exec gosu "$USER_ID:$GROUP_ID" telegram-bot-api \
        --local \
        --dir="$TELEGRAM_WORK_DIR" \
        --temp-dir="$TELEGRAM_TEMP_DIR" \
        --http-port=8081 \
        "$@"
fi

# Se o usuário já iniciou o container como não-root (via user: no compose)
exec telegram-bot-api \
    --local \
    --dir="$TELEGRAM_WORK_DIR" \
    --temp-dir="$TELEGRAM_TEMP_DIR" \
    --http-port=8081 \
    "$@"