# termux-proxy

Ferramenta simples para **esconder o IP real** no Termux usando a rede **Tor**.

- Proxy **SOCKS5** na porta `9050`
- Proxy **HTTP** na porta `8118` (via Privoxy)
- Não precisa de root
- Comandos fáceis: start / stop / status / ip / newip

## Instalação (Termux)

```bash
pkg install git -y
git clone https://github.com/vibestreamoficial/termux-proxy.git
cd termux-proxy
chmod +x install.sh termux-proxy.sh
./install.sh
```

## Uso

```bash
# Iniciar o proxy
./termux-proxy.sh start

# Ver se está rodando
./termux-proxy.sh status

# Comparar IP real x IP anônimo
./termux-proxy.sh ip

# Pedir novo circuito (trocar IP)
./termux-proxy.sh newip

# Parar
./termux-proxy.sh stop
```

## Como usar o proxy

### No terminal (curl, wget, etc.)

```bash
# HTTP
curl --proxy http://127.0.0.1:8118 https://api.ipify.org

# SOCKS5
curl --socks5-hostname 127.0.0.1:9050 https://api.ipify.org
```

### Em apps Android

Configure o proxy manualmente:

| Tipo   | Host       | Porta |
|--------|------------|-------|
| HTTP   | 127.0.0.1  | 8118  |
| SOCKS5 | 127.0.0.1  | 9050  |

Muitos apps **não respeitam** proxy do sistema. Para eles use apps tipo **Drony**, **ProxyDroid** (root) ou configure o proxy dentro do próprio app (Telegram, browsers, etc.).

### Com proxychains-ng

```bash
pkg install proxychains-ng
# edite $PREFIX/etc/proxychains.conf e coloque:
# socks5 127.0.0.1 9050
proxychains4 curl https://api.ipify.org
```

## Avisos

- Tor não é 100% anônimo se você logar em contas pessoais ou usar o mesmo fingerprint.
- Use apenas para fins legítimos de privacidade.
- O autor não se responsabiliza pelo uso indevido.

## Licença

Livre para uso educacional e pessoal.
