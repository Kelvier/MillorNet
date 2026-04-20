#!/bin/bash
# Script de renovación automática de certificados Millornet
# Se ejecuta diariamente via cron

CERT="/etc/ssl/millornet-ca/millornet.crt"
KEY="/etc/ssl/millornet-ca/millornet.key"
CA_CRT="/etc/ssl/millornet-ca/ca.crt"
CA_KEY="/etc/ssl/millornet-ca/ca.key"
SAN_CNF="/etc/ssl/millornet-ca/millornet-san.cnf"
DEST_CRT="$HOME/millornet/certs/millornet-server.crt"
DEST_KEY="$HOME/millornet/certs/millornet-server.key"
LOG="$HOME/millornet/certs/renew-certs.log"
DAYS_THRESHOLD=30

# Comprobar días restantes
EXPIRY=$(openssl x509 -in "$DEST_CRT" -noout -enddate 2>/dev/null | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

echo "$(date '+%Y-%m-%d %H:%M') — Días restantes: $DAYS_LEFT" >> "$LOG"

if [ "$DAYS_LEFT" -le "$DAYS_THRESHOLD" ]; then
    echo "$(date '+%Y-%m-%d %H:%M') — Renovando certificado..." >> "$LOG"

    # Generar nuevo certificado firmado por la CA
    openssl genrsa -out "$KEY" 2048
    openssl req -new -key "$KEY" -out /tmp/millornet.csr -config "$SAN_CNF"
    openssl x509 -req -in /tmp/millornet.csr \
        -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial \
        -out "$CERT" -days 825 -sha256 \
        -extfile "$SAN_CNF" -extensions req_ext

    # Copiar al directorio de Traefik
    cp "$CERT" "$DEST_CRT"
    cp "$KEY" "$DEST_KEY"

    # Reiniciar Traefik para que cargue el nuevo certificado
    cd "$HOME/millornet" && docker compose restart traefik

    echo "$(date '+%Y-%m-%d %H:%M') — Certificado renovado correctamente" >> "$LOG"
else
    echo "$(date '+%Y-%m-%d %H:%M') — No es necesario renovar todavía" >> "$LOG"
fi
