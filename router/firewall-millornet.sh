#!/bin/bash

# ============================================
# FIREWALL MILLORNET - Segmentación de redes
# ============================================

# Limpiar reglas anteriores
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# ============================================
# POLÍTICAS POR DEFECTO
# ============================================
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# ============================================
# LOOPBACK
# ============================================
iptables -A INPUT -i lo -j ACCEPT

# ============================================
# CONEXIONES ESTABLECIDAS
# ============================================
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# ============================================
# ACCESO AL ROUTER (SSH solo desde empresa)
# ============================================
iptables -A INPUT -i enp0s8 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i enp0s3 -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -i enp0s3 -p tcp --dport 22 -j ACCEPT
# ICMP (ping) desde redes internas
iptables -A INPUT -i enp0s8 -p icmp -j ACCEPT
iptables -A INPUT -i enp0s9 -p icmp -j ACCEPT
iptables -A INPUT -i enp0s10 -p icmp -j ACCEPT
# ============================================
# DNS Y DHCP (el router responde a todas las redes)
# ============================================
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 67 -j ACCEPT

# ============================================
# RED EMPRESA  puede salir a internet y a DMZ
# ============================================
iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s9 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s10 -j ACCEPT

# ============================================
# RED DMZ  solo puede salir a internet
# ============================================
iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s9 -o enp0s8 -j DROP
iptables -A FORWARD -i enp0s9 -o enp0s10 -j DROP

# ============================================
# RED LAB  sin salida a internet ni a otras redes
# ============================================
iptables -A FORWARD -i enp0s10 -o enp0s3 -j DROP
iptables -A FORWARD -i enp0s10 -o enp0s8 -j DROP
iptables -A FORWARD -i enp0s10 -o enp0s9 -j DROP

# ============================================
# VPN WireGuard
# ============================================
iptables -A INPUT -p udp --dport 51820 -j ACCEPT
iptables -A FORWARD -i wg0 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i wg0 -o enp0s9 -j ACCEPT
iptables -A INPUT -i wg0 -p tcp --dport 22 -j ACCEPT
# ============================================
# Panel ntopng (solo desde red local)
# ============================================
iptables -A INPUT -p tcp --dport 3000 -s 192.168.1.0/24 -j ACCEPT
# ============================================
# NAT - Salida a internet
# ============================================
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# ============================================
# DNS saliente del propio router
# ============================================
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT


# Bloquear DNS desde red laboratorio
iptables -I INPUT -i enp0s10 -p udp --dport 53 -j DROP
iptables -I INPUT -i enp0s10 -p tcp --dport 53 -j DROP

# Wazuh — permitir DMZ registrar agentes en el servidor
iptables -I FORWARD -i enp0s9 -o enp0s8 -d 10.10.10.10 -p tcp --dport 1515 -j ACCEPT
iptables -I FORWARD -i enp0s9 -o enp0s8 -d 10.10.10.10 -p tcp --dport 1514 -j ACCEPT
iptables -I FORWARD -i enp0s9 -o enp0s8 -d 10.10.10.10 -p udp --dport 1514 -j ACCEPT

echo " Firewall Millornet aplicado correctamente"
