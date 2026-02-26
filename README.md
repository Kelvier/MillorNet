# 🔒 Millornet — Empresa de Ciberseguridad y Pentesting

> Proyecto Final de ASIX 2025/2026 — Infraestructura empresarial de ciberseguridad montada sobre VirtualBox con Ubuntu Server, Docker y múltiples servicios de red.

---

## 📋 Descripción

**Millornet** es una infraestructura empresarial simulada de ciberseguridad y pentesting. El proyecto replica un entorno real con segmentación de redes, servicios en contenedores Docker, monitorización, backups y una zona de laboratorio para pruebas de pentesting.

Todo está desplegado sobre **VirtualBox** usando **Ubuntu Server 24.04 LTS**.

---

## 🗺️ Arquitectura de Red

```
[Internet]
    |
[Adaptador Puente] — enp0s3 (WAN 192.168.1.0/24)
    |
[millornet-router] — Ubuntu Server
    |
    ├── enp0s8 ──→ Red Empresa    (10.10.10.0/24)  — Servidor, herramientas
    ├── enp0s9 ──→ Red DMZ        (10.20.20.0/24)  — Web, Mail, FTP
    └── enp0s10 ──→ Red Laboratorio (10.30.30.0/24) — Máquinas vulnerables
```

### Política de Segmentación

| Origen | Destino | Permitido |
|---|---|---|
| Empresa | Internet | ✅ |
| Empresa | DMZ | ✅ |
| Empresa | Laboratorio | ✅ |
| DMZ | Internet | ✅ |
| DMZ | Empresa | ❌ |
| Laboratorio | Cualquiera | ❌ |

---

## 🖥️ Máquinas Virtuales

| VM | Hostname | IP | Rol |
|---|---|---|---|
| Router | millornet-router | 10.10.10.1 | Router, DNS, DHCP, Firewall, VPN |
| Servidor | millornet-server | 10.10.10.10 | Docker, Portainer, Grafana, Backups |
| DMZ | millornet-dmz | 10.20.20.10 | Nginx, Mailserver, FTP |
| Laboratorio | millornet-lab | 10.30.30.x | Contenedores vulnerables *(WIP)* |

---

## 🔧 Servicios por Máquina

### 🛡️ Router (millornet-router)

| Servicio | Software | Función |
|---|---|---|
| NAT / Enrutamiento | iptables | Salida a internet para redes internas |
| DHCP | isc-dhcp-server | Asignación automática de IPs |
| DNS | Bind9 | Zonas internas + forwarding externo |
| Firewall | iptables | Segmentación y control de tráfico |
| VPN | WireGuard | Acceso remoto seguro |
| Monitorización | ntopng | Análisis de tráfico en tiempo real |
| Anti fuerza bruta | Fail2ban | Bloqueo automático de atacantes SSH |

**Zonas DNS configuradas:**
- `millornet.local` → Red empresa
- `dmz.millornet.local` → Red DMZ
- `lab.millornet.local` → Red laboratorio

---

### 🐳 Servidor Principal (millornet-server)

Stack Docker Compose con los siguientes contenedores:

| Contenedor | Imagen | Puerto | Función |
|---|---|---|---|
| millornet-traefik | traefik:latest | 80, 443, 8080 | Proxy inverso |
| millornet-portainer | portainer/portainer-ce | 9000 | Panel de gestión Docker |
| millornet-duplicati | linuxserver/duplicati | 8200 | Backups cifrados AES-256 |
| millornet-prometheus | prom/prometheus | 9090 | Recolección de métricas |
| millornet-grafana | grafana/grafana | 3000 | Dashboard de monitorización |
| millornet-node-exporter | prom/node-exporter | 9100 | Métricas del sistema |
| millornet-cadvisor | gcr.io/cadvisor | 8081 | Métricas de contenedores |

---

### 🌐 DMZ (millornet-dmz)

| Contenedor | Imagen | Puerto | Dominio |
|---|---|---|---|
| dmz-nginx | nginx:latest | 80, 443 | www.dmz.millornet.local |
| dmz-mailserver | docker-mailserver | 25, 587, 993 | mail.dmz.millornet.local |
| dmz-ftp | garethflowers/ftp-server | 20, 21 | ftp.dmz.millornet.local |

---

## 🚀 Cómo levantar la infraestructura

### 1. Requisitos
- VirtualBox 7.x
- 4 VMs con Ubuntu Server 24.04 LTS
- Mínimo 8GB RAM total recomendado

### 2. Router
```bash
# Configurar interfaces (Netplan)
sudo netplan apply

# Levantar servicios
sudo systemctl start isc-dhcp-server bind9 wg-quick@wg0 fail2ban ntopng
sudo bash /etc/firewall-millornet.sh
```

### 3. Servidor principal
```bash
cd ~/millornet
sudo chmod 666 /var/run/docker.sock
docker compose up -d
```

### 4. DMZ
```bash
cd ~/millornet-dmz
sudo chmod 666 /var/run/docker.sock
docker compose up -d
```

---

## 🌍 Acceso a los paneles web

Desde tu PC usando SSH tunneling:

```bash
# Tunel al servidor
ssh -L 9000:10.10.10.10:9000 -L 3000:10.10.10.10:3000 -L 8080:10.10.10.10:8080 -L 8200:10.10.10.10:8200 ikervp@192.168.56.102

# Tunel a la DMZ
ssh -L 8888:10.20.20.10:80 ikervp@192.168.56.103
```

| Panel | URL | Credenciales |
|---|---|---|
| Portainer | http://localhost:9000 | admin / *configurado al instalar* |
| Grafana | http://localhost:3000 | admin / Millornet2026! |
| Traefik | http://localhost:8080 | Sin autenticación |
| Duplicati | http://localhost:8200 | alumnes |
| Web DMZ | http://localhost:8888 | Pública |
| ntopng | http://192.168.1.39:3000 | admin / admin |

---

## 🔮 Planes a Futuro

- [ ] Despliegue de red de laboratorio con contenedores vulnerables (DVWA, WebGoat, Juice Shop, Metasploitable)
- [ ] Instalación de herramientas de pentesting (Metasploit, Burp Suite, Nmap, Wireshark)
- [ ] Implementación de Wazuh como SIEM
- [ ] Certificados SSL/TLS con Let's Encrypt
- [ ] Autenticación 2FA en Portainer y Grafana
- [ ] Logs centralizados con ELK Stack
- [ ] Informes de pentesting sobre los contenedores vulnerables

---

## 📁 Estructura del Proyecto

```
millornet/
├── docker-compose.yml          # Stack servidor principal
├── traefik/
│   └── traefik.yml
├── prometheus/
│   └── prometheus.yml
├── duplicati/
├── backups/
└── millornet-dmz/
    ├── docker-compose.yml      # Stack DMZ
    ├── nginx/
    │   ├── html/index.html
    │   └── conf/default.conf
    ├── mailserver/
    └── ftp/
```

---

## 🛠️ Tecnologías utilizadas

![Ubuntu](https://img.shields.io/badge/Ubuntu_Server-24.04-E95420?style=flat&logo=ubuntu&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)
![WireGuard](https://img.shields.io/badge/WireGuard-VPN-88171A?style=flat&logo=wireguard&logoColor=white)

---

## 👤 Autores

**Iker** — Proyecto Final ASIX 2025/2026
**Enric** — Proyecto Final ASIX 2025/2026

---

> ⚠️ **Aviso:** Este proyecto es un entorno de laboratorio educativo. Las credenciales visibles en este README son de uso interno en entorno simulado y no deben usarse en producción.
