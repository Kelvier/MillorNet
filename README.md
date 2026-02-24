🛡️ MillorNet – Infraestructura Corporativa de Laboratorio para Simulación de Pentesting
📌 Descripción del Proyecto

MillorNet es una empresa ficticia especializada en servicios de auditoría de seguridad y pentesting dirigidos a instituciones del sector público.

Este proyecto representa la infraestructura corporativa interna simulada de la empresa, diseñada como laboratorio práctico para el Trabajo de Fin de Curso en Ciberseguridad.

El entorno permite:

Diseñar una arquitectura empresarial realista.

Implementar segmentación de red profesional.

Desplegar servicios corporativos en contenedores.

Introducir vulnerabilidades controladas.

Ejecutar simulaciones ofensivas (Red Team).

Analizar técnicas defensivas (Blue Team).

⚠️ Todo el entorno es aislado y de uso exclusivamente académico.

🏗️ Arquitectura General

La infraestructura de MillorNet está compuesta por:

1 Router/Firewall basado en OpenWRT

1 Servidor Ubuntu Server (host principal)

Servicios desplegados en contenedores Docker

Segmentación en LAN, DMZ y red de gestión

Políticas de firewall restrictivas

🌐 Diseño de Red Corporativa
📍 Espacio de Direccionamiento

Se ha reservado el rango privado:

10.0.0.0/16

Este diseño permite escalabilidad y crecimiento futuro, simulando un entorno empresarial real.

🔷 Segmentación de Red
Zona	Subred	Descripción
WAN	DHCP (NAT hipervisor)	Simulación de Internet
LAN Corporativa	10.0.10.0/24	Red interna empleados
DMZ	10.0.20.0/24	Servicios expuestos
Red de Gestión	10.0.30.0/24	Administración
Red Docker Interna	10.10.0.0/16	Comunicación entre contenedores
📡 Router Corporativo (OpenWRT)
Interfaces
Interfaz	Dirección IP
WAN	DHCP
LAN	10.0.10.1
DMZ	10.0.20.1
MGMT	10.0.30.1
Funciones

Gateway principal

Firewall con políticas restrictivas

NAT

Port Forwarding controlado

DHCP para red LAN

Segmentación entre zonas

🖥️ Servidor Principal – Ubuntu Server

Hostname:

srv-core.millornet.local
Interfaces
Red	IP
LAN	10.0.10.10
DMZ	10.0.20.10
MGMT	10.0.30.10
Funciones

Host de contenedores Docker

Servidor DNS interno

Proxy corporativo

Servidor Web corporativo

Entorno vulnerable de pruebas

Repositorio interno

🐳 Infraestructura Docker

Todos los servicios empresariales se ejecutan en contenedores aislados.

Red Docker
10.10.0.0/16

Ejemplo de creación:

docker network create \
  --subnet 10.10.0.0/16 \
  millornet_net
📦 Servicios Implementados
🌍 Reverse Proxy (Nginx)

IP interna Docker: 10.10.0.10

Publicación hacia DMZ

Gestión de tráfico HTTP/HTTPS

🌐 Servidor Web Corporativo

IP Docker: 10.10.0.20

Accesible desde DMZ

Vulnerabilidades intencionadas:

Versión desactualizada

Directory listing habilitado

Configuración insegura TLS

🧪 Aplicación Web Vulnerable

IP Docker: 10.10.0.30

Vulnerabilidades:

SQL Injection

XSS

Command Injection

File Upload inseguro

Autenticación débil

🧭 Servidor DNS Interno

IP Docker: 10.10.0.53

Dominios internos:

millornet.local
intranet.millornet.local
dev.millornet.local

Función:

Resolución interna

Simulación de ataques DNS

🛜 Proxy Corporativo (Squid)

IP Docker: 10.10.0.40

Puerto: 3128

Vulnerabilidades:

ACL mal configuradas

Autenticación básica débil

Posible abuso como proxy abierto

🔥 Políticas de Firewall

Configuradas en OpenWRT siguiendo modelo corporativo:

Reglas Principales

❌ WAN → LAN → Denegado

❌ WAN → MGMT → Denegado

✅ WAN → DMZ (puertos 80, 443)

❌ DMZ → LAN → Denegado

✅ LAN → WAN → Permitido

✅ MGMT → Todos → Permitido (solo administradores)

Redirección de Puertos
Puerto Externo	Destino Interno
80	10.0.20.10
443	10.0.20.10
