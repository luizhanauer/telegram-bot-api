#!/bin/bash
# ==============================================================================
# Telegram Bot API - Instalador Automatizado (Ubuntu 24.04)
# Desenvolvido por: luizhanauer
# ==============================================================================

set -e

# Definição de Cores e Estilos
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Limpa a tela para começar a experiência
clear

echo -e "${BLUE}${BOLD}================================================================"
echo -e "          TELEGRAM BOT API - LOCAL SERVER INSTALLER"
echo -e "================================================================${NC}"
echo -e "Este script irá configurar um servidor local do Telegram Bot API,"
echo -e "otimizado para alta performance e segurança.${NC}\n"

# --- ETAPA 1: VALIDAÇÃO DO SISTEMA ---
echo -e "${BOLD}[1/5] Validando compatibilidade do sistema...${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    # O binário foi compilado especificamente para o Ubuntu 24.04
    if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "24.04" ]; then
        echo -e "${GREEN}✔ Sistema identificado: Ubuntu 24.04 LTS${NC}"
    else
        echo -e "${YELLOW}⚠ Atenção: Este binário foi compilado no Ubuntu 24.04.${NC}"
        echo -e "Seu sistema atual é: $PRETTY_NAME"
        read -p "Deseja continuar com a instalação mesmo assim? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Instalação cancelada pelo usuário.${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}✖ Não foi possível identificar seu sistema operacional.${NC}"
    exit 1
fi

# --- ETAPA 2: CONFIGURAÇÕES DA API ---
echo -e "\n${BOLD}[2/5] Configurações de Identidade da API${NC}"
echo -e "Para rodar o servidor local, você precisa registrar um 'App' no Telegram."
echo -e "Acesse: ${BLUE}https://my.telegram.org/apps${NC} para obter suas chaves.\n"

# API ID
echo -e "${YELLOW}API ID:${NC} É o identificador numérico da sua aplicação."
read -p ">> Digite o API_ID: " API_ID
while [[ ! $API_ID =~ ^[0-9]+$ ]]; do
    echo -e "${RED}Entrada inválida. O API_ID deve conter apenas números.${NC}"
    read -p ">> Digite o API_ID: " API_ID
done

# API HASH
echo -e "\n${YELLOW}API HASH:${NC} É a sua chave secreta de autenticação."
read -p ">> Digite o API_HASH: " API_HASH

# PORTA
echo -e "\n${YELLOW}PORTA:${NC} A porta onde o servidor local ficará escutando (Padrão: 8081)."
read -p ">> Digite a porta [8081]: " PORT
PORT=${PORT:-8081}

# --- ETAPA 3: DOWNLOAD DO BINÁRIO ---
echo -e "\n${BOLD}[3/5] Baixando binário pré-compilado...${NC}"
REPO="luizhanauer/telegram-bot-api"
LATEST_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep "browser_download_url" | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo -e "${RED}✖ Erro: Não foi possível encontrar a última versão no GitHub.${NC}"
    exit 1
fi

echo -e "Efetuando download de: ${BLUE}$LATEST_URL${NC}"
curl -L -o telegram-api.tar.gz "$LATEST_URL"
tar -xzf telegram-api.tar.gz
echo -e "${GREEN}✔ Download e extração concluídos.${NC}"

# --- ETAPA 4: INSTALAÇÃO E PERMISSÕES ---
echo -e "\n${BOLD}[4/5] Instalando arquivos e ajustando permissões...${NC}"

# O binário é instalado em /usr/local/bin
echo -e ">> Movendo executável para /usr/local/bin..."
sudo mv telegram-bot-api /usr/local/bin/
sudo chmod +x /usr/local/bin/telegram-bot-api

# Criação do diretório de trabalho seguro
echo -e ">> Preparando diretório de dados em /var/lib/telegram-bot-api..."
sudo mkdir -p /var/lib/telegram-bot-api
sudo chown $USER:$USER /var/lib/telegram-bot-api

# --- ETAPA 5: CONFIGURAÇÃO DO SERVIÇO SYSTEMD ---
echo -e "\n${BOLD}[5/5] Configurando o serviço de sistema (Systemd)...${NC}"
echo -e "Isso permitirá que o servidor inicie automaticamente com o computador."

# Criação do arquivo de serviço conforme as boas práticas
sudo bash -c "cat <<EOF > /etc/systemd/system/telegram-bot-api.service
[Unit]
Description=Telegram Bot API Local Server
After=network.target

[Service]
Type=simple
User=$USER
Group=$(id -gn)
WorkingDirectory=/var/lib/telegram-bot-api
ExecStart=/usr/local/bin/telegram-bot-api --api-id=$API_ID --api-hash=$API_HASH --local --dir=/var/lib/telegram-bot-api --http-port=$PORT
Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF"

echo -e ">> Ativando e iniciando o serviço..."
sudo systemctl daemon-reload
sudo systemctl enable --now telegram-bot-api.service

# Limpeza
rm telegram-api.tar.gz

# --- CONCLUSÃO ---
echo -e "\n${GREEN}${BOLD}================================================================"
echo -e "           INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo -e "================================================================${NC}"
echo -e "O servidor já está rodando!"
echo -e "• ${BOLD}Porta:${NC} $PORT"
echo -e "• ${BOLD}Logs em tempo real:${NC} journalctl -u telegram-bot-api.service -f"
echo -e "• ${BOLD}Status do serviço:${NC} systemctl status telegram-bot-api.service"
echo -e "================================================================\n"