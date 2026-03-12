# Etapa 1: Compilação
FROM ubuntu:24.04 AS builder

# Instalar dependências de compilação
RUN apt update && apt install -y \
    make git zlib1g-dev libssl-dev gperf cmake g++ \
    && rm -rf /var/lib/apt/lists/*

# Clonar o repositório oficial
WORKDIR /source
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git .

# Compilar com otimizações
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    cmake --build . --target install -j$(nproc)

# Etapa 2: Runtime (Imagem Final)
FROM ubuntu:24.04

# Instalar bibliotecas de execução necessárias
RUN apt update && apt install -y \
    libssl3 zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho e usuário sem privilégios
RUN mkdir -p /var/lib/telegram-bot-api && \
    groupadd -r telegrambot && useradd -r -g telegrambot -d /var/lib/telegram-bot-api telegrambot && \
    chown telegrambot:telegrambot /var/lib/telegram-bot-api

# Copiar apenas o binário da etapa anterior
COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

USER telegrambot
WORKDIR /var/lib/telegram-bot-api

# Expor a porta padrão
EXPOSE 8081

# Comando de entrada (pode ser sobrescrito no docker-compose)
ENTRYPOINT ["telegram-bot-api"]