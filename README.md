# 🔒 Millornet — Empresa de Ciberseguridad y Pentesting

> Proyecto Final de ASIX 2025/2026 — Infraestructura empresarial de ciberseguridad montada sobre VirtualBox con Ubuntu Server, Docker y múltiples servicios de red.

---

## 📋 Descripción

**Millornet** es una infraestructura empresarial simulada de ciberseguridad y pentesting. El proyecto replica un entorno real con segmentación de redes, servicios en contenedores Docker, monitorización, backups, VPN, laboratorio de pentesting y políticas de seguridad.

Todo está desplegado sobre **VirtualBox** usando **Ubuntu Server 24.04 LTS**.

---

## 🗺️ Arquitectura de Red

[Internet]
|
[Adaptador Puente] — enp0s3 (WAN 192.168.1.0/24)
|
[millornet-router] — Ubuntu Server
|
├── enp0s8 ──→ Red Empresa      (10.10.10.0/24)  — Servidor, herramientas
├── enp0s9 ──→ Red DMZ          (10.20.20.0/24)  — Web, Mail, FTP
└── enp0s10 ──→ Red Laboratorio (10.30.30.0/24)  — Máquinas vulnerables

### Política de Segmentación

| Origen | Destino | Permitido | Motivo |
|---|---|---|---|
| Empresa | Internet | ✅ | Acceso total |
| Empresa | DMZ | ✅ | Gestión interna |
| Empresa | Laboratorio | ✅ | Ataques controlados |
| DMZ | Internet | ✅ | Servicios públicos |
| DMZ | Empresa | ❌ | Aislamiento DMZ |
| DMZ | Laboratorio | ❌ | Aislamiento |
| Laboratorio | Cualquiera | ❌ | Contención total |

---

## 🖥️ Máquinas Virtuales

| VM | Hostname | IP Interna | IP Host-Only | Rol |
|---|---|---|---|---|
| Router | millornet-router | 10.10.10.1 | 192.168.1.x | Router, DNS, DHCP, Firewall, VPN |
| Servidor | millornet-server | 10.10.10.10 | 192.168.56.102 | Docker, Portainer, Grafana, Backups |
| DMZ | millornet-dmz | 10.20.20.10 | 192.168.56.103 | Nginx, Mailserver, FTP |
| Laboratorio | millornet-lab | 10.30.30.10 | 192.168.56.104 | Contenedores vulnerables |

---

## 🔧 Servicios por Máquina

### 🛡️ Router (millornet-router)

| Servicio | Software | Función |
|---|---|---|
| NAT / Enrutamiento | iptables | Salida a internet para redes internas |
| DHCP | isc-dhcp-server | Asignación automática de IPs |
| DNS | Bind9 | Zonas internas + forwarding externo |
| Firewall | iptables | Segmentación y control de tráfico |
| VPN | WireGuard | Acceso remoto seguro (10.99.99.0/24) |
| Monitorización | ntopng | Análisis de tráfico en tiempo real |
| Anti fuerza bruta | Fail2ban | Bloqueo automático de atacantes SSH |

**Zonas DNS configuradas:**
- `millornet.local` → Red empresa (10.10.10.0/24)
- `dmz.millornet.local` → Red DMZ (10.20.20.0/24)
- `lab.millornet.local` → Red laboratorio (10.30.30.0/24)

---

### 🐳 Servidor Principal (millornet-server)

| Contenedor | Imagen | Puerto | Función |
|---|---|---|---|
| millornet-traefik | traefik:latest | 80, 443, 8080 | Proxy inverso SSL/TLS |
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

### 🧪 Laboratorio de Pentesting (millornet-lab)

| Contenedor | Imagen | Puerto | Descripción |
|---|---|---|---|
| lab-dvwa | vulnerables/web-dvwa | 8080 | Damn Vulnerable Web App |
| lab-webgoat | webgoat/webgoat | 8081 | OWASP WebGoat |
| lab-juiceshop | bkimminich/juice-shop | 8082 | OWASP Juice Shop |
| lab-mutillidae | citizenstig/nowasp | 8083 | Mutillidae |

---

### 🛡️ DefectDojo (millornet-server)

Plataforma de gestión de vulnerabilidades accesible en `https://defectdojo.millornet.local`

| Contenedor | Función |
|---|---|
| defectdojo-nginx | Proxy interno y ficheros estáticos |
| defectdojo-uwsgi | Backend Django principal |
| defectdojo-celeryworker | Tareas asíncronas |
| defectdojo-postgres | Base de datos |
| defectdojo-redis | Broker de mensajes |

---

## 🔐 Seguridad Implementada

### SSL/TLS
- CA raíz propia **Millornet Root CA** (válida 10 años)
- Certificado wildcard `*.millornet.local` firmado por la CA (válido 825 días)
- Traefik como terminador TLS centralizado
- Redirección automática HTTP → HTTPS en todos los servicios

| Servicio | HTTPS | 2FA |
|---|---|---|
| Portainer | ✅ | ✅ TOTP |
| Grafana | ✅ | ✅ TOTP |
| Traefik Dashboard | ✅ | ❌ |
| Duplicati | ✅ | ❌ |
| DefectDojo | ✅ | ❌ |

### Hardening (Lynis)

| Máquina | Inicial | Final | Mejora |
|---|---|---|---|
| millornet-router | 62/100 | 71/100 | +9 pts |
| millornet-server | 59/100 | 69/100 | +10 pts |

### Wazuh SIEM

| Agente | Máquina | IP | Estado |
|---|---|---|---|
| 001 | millornet-router | 10.10.10.1 | ✅ Activo |
| 002 | millornet-server | 10.10.10.10 | ✅ Activo |
| 003 | millornet-dmz | 10.20.20.10 | ✅ Activo |

---

## 👥 Usuarios del Sistema

| Usuario | Máquina | Sudo | Docker | Descripción |
|---|---|---|---|---|
| ikervp | Todas | ✅ | ✅ | Administrador principal |
| enrinctg | Router/Servidor | ✅ | ✅ | Administrador secundario |
| dev-millornet | Servidor | ❌ | ✅ | Gestiona contenedores |
| analista-millornet | Servidor | ❌ | ❌ | Solo lectura de logs |
| webmaster-millornet | DMZ | ❌ | ✅ | Gestiona web Nginx |
| invitado-millornet | Todas | ❌ | ❌ | Shell restringida (rbash) |

---

## 🚀 Cómo levantar la infraestructura

### 1. Requisitos
- VirtualBox 7.x
- 4 VMs con Ubuntu Server 24.04 LTS
- Mínimo 8GB RAM total recomendado

### 2. Router
```bash
sudo netplan apply
sudo systemctl start isc-dhcp-server bind9 wg-quick@wg0 fail2ban ntopng
sudo bash /etc/firewall-millornet.sh
```

### 3. Servidor principal
```bash
cd ~/millornet && docker compose up -d
```

### 4. DMZ
```bash
cd ~/millornet-dmz && docker compose up -d
```

### 5. Laboratorio
```bash
cd ~/millornet-lab && docker compose up -d
```

### 6. DefectDojo
```bash
cd ~/defectdojo && docker compose up -d
```

---

## 🌍 Acceso a los servicios

### SSH

| Máquina | Con VPN | Sin VPN (red local) |
|---|---|---|
| Router | `ssh ikervp@10.10.10.1` | `ssh ikervp@192.168.1.x` |
| Servidor | `ssh ikervp@10.10.10.10` | `ssh ikervp@192.168.56.102` |
| DMZ | `ssh ikervp@10.20.20.10` | `ssh ikervp@192.168.56.103` |
| Lab | `ssh ikervp@10.30.30.10` | `ssh ikervp@192.168.56.104` |

### Paneles Web (con VPN activa)

| Panel | URL |
|---|---|
| Portainer | https://portainer.millornet.local |
| Grafana | https://grafana.millornet.local |
| Traefik | https://traefik.millornet.local |
| Duplicati | https://duplicati.millornet.local |
| Prometheus | https://prometheus.millornet.local |
| DefectDojo | https://defectdojo.millornet.local |
| ntopng | http://10.10.10.1:3000 |
| Web DMZ | http://www.dmz.millornet.local |

### Laboratorio (con VPN)

| App | URL |
|---|---|
| DVWA | http://10.30.30.10:8080 |
| WebGoat | http://10.30.30.10:8081/WebGoat |
| Juice Shop | http://10.30.30.10:8082 |
| Mutillidae | http://10.30.30.10:8083 |

---

## 📊 Resultados del Pentesting

| Vulnerabilidad | Severidad | Servicio |
|---|---|---|
| Fuerza bruta login | 🔴 CRÍTICA | DVWA |
| SQL Injection | 🔴 CRÍTICA | DVWA |
| Command Injection (RCE) | 🔴 CRÍTICA | DVWA |
| Credenciales en texto plano | 🔴 CRÍTICA | Mutillidae |
| phpMyAdmin sin autenticación | 🔴 CRÍTICA | Mutillidae |
| XSS Reflejado | 🟠 ALTA | DVWA |
| XSS Almacenado | 🟠 ALTA | DVWA |
| PHP desactualizado | 🟠 ALTA | Mutillidae |
| .git expuesto | 🟠 ALTA | Mutillidae |
| Cookies sin HttpOnly | 🟡 MEDIA | DVWA/Mutillidae |

---

## 📁 Estructura del Repositorio

MillorNet/
├── router/                     # Configuraciones del router
│   ├── firewall-millornet.sh
│   ├── dhcpd.conf
│   ├── named.conf.local / named.conf.options
│   ├── netplan.yaml
│   ├── wg0.conf
│   ├── jail.local
│   ├── ntopng.conf
│   └── zones/
├── server/                     # Servidor principal
│   ├── docker-compose.yml
│   ├── traefik/
│   ├── prometheus/
│   └── certs/
├── dmz/                        # Zona DMZ
│   ├── docker-compose.yml
│   └── nginx/
├── lab/                        # Laboratorio de pentesting
│   └── docker-compose.yml
├── defectdojo/                 # Gestión de vulnerabilidades
│   └── docker-compose.yml
├── MillorNet-web/              # Aplicación web
│   ├── frontend/
│   └── backend/
└── docs/                       # Documentación técnica (PDFs)


## 🛠️ Tecnologías utilizadas

![Ubuntu](https://img.shields.io/badge/Ubuntu_Server-24.04-E95420?style=flat&logo=ubuntu&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)
![WireGuard](https://img.shields.io/badge/WireGuard-VPN-88171A?style=flat&logo=wireguard&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-24A1C1?style=flat&logo=traefikproxy&logoColor=white)
![Wazuh](https://img.shields.io/badge/Wazuh-SIEM-005571?style=flat)
![DefectDojo](https://img.shields.io/badge/DefectDojo-v2.57-orange?style=flat)
![Metasploit](https://img.shields.io/badge/Metasploit-6.4-2596CD?style=flat)

---

## 🔮 Trabajo Futuro

- [ ] Servidor Wazuh centralizado para visualización de alertas SIEM
- [ ] Autenticación en Traefik Dashboard
- [ ] Restricción DNS desde red de laboratorio
- [ ] Script cron para renovación automática de certificados TLS
- [ ] ELK Stack para logs centralizados
- [ ] Alertas automáticas en Grafana
- [ ] Burp Suite y Wireshark en el servidor
- [ ] DDNS para acceso VPN con IP pública dinámica

---

## 👤 Autores

**Iker VP** — Proyecto Final ASIX 2025/2026
**Enric TG** — Proyecto Final ASIX 2025/2026

---

> ⚠️ **Aviso:** Este proyecto es un entorno de laboratorio educativo. Las credenciales se gestionan mediante ficheros `.env` excluidos del repositorio. No usar en producción.
