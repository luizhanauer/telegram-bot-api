# 🚀 Telegram Bot API - Optimized Local Server

Este repositório fornece binários pré-compilados e um script de instalação automatizada para o **Telegram Bot API**. O objetivo é facilitar o deploy de um servidor local de alta performance, eliminando a necessidade de compilação manual e atualizações complexas.

A build é otimizada especificamente para o **Ubuntu 24.04**, garantindo máxima compatibilidade com sistemas modernos.

## 🌟 Destaques desta Versão

* **Alta Performance:** Compilado com a flag `-O3`, que aplica as otimizações mais agressivas do compilador para garantir que o binário execute o código na velocidade máxima.
* **Paralelismo:** Build gerada utilizando todas as threads disponíveis na CPU (`-j$(nproc)`), aproveitando ao máximo o hardware para processamento de requisições.
* **Instalação One-Liner:** Um script intuitivo que cuida do download, permissões e criação do serviço de sistema.
* **Segurança:** Configurado para rodar como um serviço isolado em um usuário comum, protegendo a integridade do seu servidor.

## 🛠️ Instalação Rápida

Para instalar o binário, configurar as permissões e gerar o serviço `systemd` automaticamente, execute o comando abaixo:

```bash
curl -fsS https://luizhanauer.github.io/telegram-bot-api/install.sh | sh
```

O script solicitará seu `API_ID` e `API_HASH` (que você pode obter em [my.telegram.org](https://my.telegram.org/apps)) e configurará tudo para você.

## 📂 Estrutura de Diretórios

Seguindo as boas práticas de Linux, a instalação utiliza os seguintes caminhos:

* **Binário:** `/usr/local/bin/telegram-bot-api`
* **Diretório de Trabalho:** `/var/lib/telegram-bot-api` (Onde arquivos e downloads do bot são armazenados)
* **Serviço:** `/etc/systemd/system/telegram-bot-api.service`

---

## ⚡ Comandos Úteis

Após a instalação, você pode gerenciar o servidor do seu bot utilizando os comandos padrão do `systemctl`.

| Ação | Comando |
| --- | --- |
| **Ver Status** | `sudo systemctl status telegram-bot-api` |
| **Ver Logs (Real-time)** | `journalctl -u telegram-bot-api.service -f` |
| **Reiniciar Serviço** | `sudo systemctl restart telegram-bot-api` |
| **Parar Serviço** | `sudo systemctl stop telegram-bot-api` |
| **Iniciar Serviço** | `sudo systemctl start telegram-bot-api` |

### Verificando a Versão

Para garantir que o binário está funcionando corretamente e verificar a versão atual:

```bash
telegram-bot-api --version
```

---

## 🏗️ Compilação Manual (Opcional)

Se você preferir compilar do zero para o seu hardware específico, o processo utiliza `cmake` e `g++`:

```bash
# Instalar dependências
sudo apt install make git zlib1g-dev libssl-dev gperf cmake g++ -y

# Clonar e Compilar
git clone --recursive https://github.com/tdlib/telegram-bot-api.git
cd telegram-bot-api && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ..
cmake --build . --target install -j$(nproc)

```

---

## 💳 Créditos e Referências

Este projeto é uma distribuição facilitada do código-fonte oficial.

* **Projeto Original:** [tdlib/telegram-bot-api](https://github.com/tdlib/telegram-bot-api)
* **Licença:** O Telegram Bot API é disponibilizado sob a licença **Boost Software License 1.0**.

---

**Desenvolvido por [luizhanauer**](https://github.com/luizhanauer)
