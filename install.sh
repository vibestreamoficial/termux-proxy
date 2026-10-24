#!/data/data/com.termux/files/usr/bin/bash

echo "[*] Atualizando e instalando dependências..."
pkg update -y && pkg upgrade -y
pkg install -y tor privoxy curl netcat-openbsd

mkdir -p $HOME/.config/termux-proxy
mkdir -p $HOME/.tor

# Configuração básica do Tor
cat > $HOME/.tor/torrc << 'EOF'
SocksPort 9050
ControlPort 9051
CookieAuthentication 1
DataDirectory $HOME/.tor/data
EOF

# Configuração do Privoxy (HTTP → SOCKS5)
cat > $HOME/.config/termux-proxy/privoxy.conf << 'EOF'
listen-address 127.0.0.1:8118
forward-socks5 / 127.0.0.1:9050 .
confdir $HOME/.config/termux-proxy
EOF

chmod +x termux-proxy.sh 2>/dev/null || true
echo "[+] Instalação concluída!"
echo "Use: ./termux-proxy.sh start"
