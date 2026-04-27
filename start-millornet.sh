#!/bin/bash
echo "=== Millornet Startup ==="

echo "[1/4] Stack principal..."
cd ~/millornet && docker compose up -d

echo "[2/4] Wazuh SIEM..."
cd ~/wazuh-docker/single-node && docker compose up -d

echo "[3/4] DefectDojo..."
cd ~/defectdojo && docker compose up -d

echo "[4/4] Laboratorio..."
ssh -o StrictHostKeyChecking=no ikervp@10.30.30.10 "cd ~/millornet-lab && docker compose up -d" 2>/dev/null || echo "Lab no disponible"

echo ""
echo "=== Estado final ==="
docker ps --format "table {{.Names}}\t{{.Status}}"
