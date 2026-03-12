# Etapa 1: Compilação (Mantida)
FROM ubuntu:24.04 AS builder
RUN apt update && apt install -y make git zlib1g-dev libssl-dev gperf cmake g++ && rm -rf /var/lib/apt/lists/*
WORKDIR /source
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git .
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    cmake --build . --target install -j$(nproc)

# Etapa 2: Runtime Profissional
FROM ubuntu:24.04
RUN apt update && apt install -y libssl3 zlib1g gosu && rm -rf /var/lib/apt/lists/*

ENV TELEGRAM_WORK_DIR=/var/lib/telegram-bot-api
ENV TELEGRAM_TEMP_DIR=/tmp/telegram-bot-api

RUN mkdir -p ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR}

COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR ${TELEGRAM_WORK_DIR}
EXPOSE 8081

ENTRYPOINT ["entrypoint.sh"]