#!/data/data/com.termux/files/usr/bin/bash

TOR_PID_FILE="$HOME/.config/termux-proxy/tor.pid"
PRIVOXY_PID_FILE="$HOME/.config/termux-proxy/privoxy.pid"
TORRC="$HOME/.tor/torrc"
PRIVOXY_CONF="$HOME/.config/termux-proxy/privoxy.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_deps() {
    for cmd in tor privoxy curl; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}[-] $cmd não encontrado. Rode ./install.sh primeiro.${NC}"
            exit 1
        fi
    done
}

start_proxy() {
    check_deps
    if [ -f "$TOR_PID_FILE" ] && kill -0 $(cat $TOR_PID_FILE) 2>/dev/null; then
        echo -e "${YELLOW}[!] Tor já está rodando.${NC}"
    else
        echo -e "${GREEN}[*] Iniciando Tor...${NC}"
        tor -f $TORRC --PidFile $TOR_PID_FILE --RunAsDaemon 1
        sleep 3
    fi

    if [ -f "$PRIVOXY_PID_FILE" ] && kill -0 $(cat $PRIVOXY_PID_FILE) 2>/dev/null; then
        echo -e "${YELLOW}[!] Privoxy já está rodando.${NC}"
    else
        echo -e "${GREEN}[*] Iniciando Privoxy...${NC}"
        privoxy --pidfile $PRIVOXY_PID_FILE $PRIVOXY_CONF
        sleep 1
    fi

    echo -e "${GREEN}[+] Proxy ativo!${NC}"
    echo "  SOCKS5 → 127.0.0.1:9050"
    echo "  HTTP   → 127.0.0.1:8118"
    echo ""
    echo "Teste o IP com: ./termux-proxy.sh ip"
}

stop_proxy() {
    if [ -f "$TOR_PID_FILE" ]; then
        kill $(cat $TOR_PID_FILE) 2>/dev/null && rm -f $TOR_PID_FILE
        echo -e "${GREEN}[+] Tor parado.${NC}"
    fi
    if [ -f "$PRIVOXY_PID_FILE" ]; then
        kill $(cat $PRIVOXY_PID_FILE) 2>/dev/null && rm -f $PRIVOXY_PID_FILE
        echo -e "${GREEN}[+] Privoxy parado.${NC}"
    fi
    pkill -f "tor -f" 2>/dev/null
    pkill -f privoxy 2>/dev/null
}

status() {
    echo -e "${YELLOW}=== Status ===${NC}"
    if [ -f "$TOR_PID_FILE" ] && kill -0 $(cat $TOR_PID_FILE) 2>/dev/null; then
        echo -e "Tor:     ${GREEN}RODANDO${NC}"
    else
        echo -e "Tor:     ${RED}PARADO${NC}"
    fi
    if [ -f "$PRIVOXY_PID_FILE" ] && kill -0 $(cat $PRIVOXY_PID_FILE) 2>/dev/null; then
        echo -e "Privoxy: ${GREEN}RODANDO${NC}"
    else
        echo -e "Privoxy: ${RED}PARADO${NC}"
    fi
}

show_ip() {
    echo -e "${YELLOW}[*] IP real (sem proxy):${NC}"
    curl -s --max-time 10 https://api.ipify.org || echo "falhou"
    echo ""
    echo -e "${YELLOW}[*] IP pelo proxy HTTP (8118):${NC}"
    curl -s --max-time 15 --proxy http://127.0.0.1:8118 https://api.ipify.org || echo "falhou (proxy não está ativo?)"
    echo ""
    echo -e "${YELLOW}[*] IP pelo SOCKS5 (9050):${NC}"
    curl -s --max-time 15 --socks5-hostname 127.0.0.1:9050 https://api.ipify.org || echo "falhou"
}

new_identity() {
    if [ ! -f "$TOR_PID_FILE" ] || ! kill -0 $(cat $TOR_PID_FILE) 2>/dev/null; then
        echo -e "${RED}[-] Tor não está rodando.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[*] Solicitando nova identidade (novo circuito Tor)...${NC}"
    echo -e 'AUTHENTICATE ""\r\nSIGNAL NEWNYM\r\nQUIT\r\n' | nc 127.0.0.1 9051
    sleep 2
    echo -e "${GREEN}[+] Nova identidade solicitada. Aguarde alguns segundos e teste com './termux-proxy.sh ip'${NC}"
}

case "$1" in
    start)   start_proxy ;;
    stop)    stop_proxy ;;
    status)  status ;;
    ip)      show_ip ;;
    newip)   new_identity ;;
    *)
        echo "Uso: $0 {start|stop|status|ip|newip}"
        echo ""
        echo "  start   → inicia Tor + Privoxy"
        echo "  stop    → para tudo"
        echo "  status  → mostra se está rodando"
        echo "  ip      → mostra IP real vs IP anônimo"
        echo "  newip   → pede novo circuito Tor (troca de IP)"
        ;;
esac
