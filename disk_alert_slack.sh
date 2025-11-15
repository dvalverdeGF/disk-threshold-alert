#!/bin/bash
set -eu

# ---- Configuración por defecto (pueden ser sobreescritas con env o args) ----
DEFAULT_THRESHOLD=90
DEFAULT_DISK="/dev/vdx1"
LOGFILE="/var/log/disk_alert_slack.log"
SLACK_WEBHOOK="https://hooks.slack.com/services/XXXXXXXXXXX/BBBBBBBBBB/GGGGGGGGGGGGGGGGGGGG"

# ---- Entrada: prioridad = args > env > defaults ----
# Uso: disk_alert_slack.sh [THRESHOLD] [DISK]
if [ $# -ge 1 ]; then
  THRESHOLD="$1"
else
  THRESHOLD="${THRESHOLD:-$DEFAULT_THRESHOLD}"
fi

if [ $# -ge 2 ]; then
  DISK="$2"
else
  DISK="${DISK:-$DEFAULT_DISK}"
fi

# ---- Comprueba que SLACK_WEBHOOK está definido ----
if [ -z "$SLACK_WEBHOOK" ]; then
  echo "SLACK_WEBHOOK no configurado. Edita el script para añadirlo." >&2
  exit 2
fi

# ---- Obtiene uso (porcentaje entero) de forma robusta ----
# usamos df -P para formato portable; buscamos por dispositivo exacto o por punto de montaje
USAGE_RAW=$(df -P | awk -v d="$DISK" '$1==d || $6==d {print $5; found=1} END{ if(!found) exit 1 }' ) || USAGE_RAW=""
if [ -z "$USAGE_RAW" ]; then
  MSG="⚠️ *Alerta de disco*: No se localizó '$DISK' con 'df -P'. Comprueba el identificador."
  # enviar a slack y loguear
  printf '%s %s\n' "$(date -Iseconds)" "$MSG" >> "$LOGFILE" 2>/dev/null || true
  curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MSG\"}" "$SLACK_WEBHOOK" >/dev/null 2>&1 || true
  exit 1
fi

USAGE=$(echo "$USAGE_RAW" | tr -d '%')
# ---- Validación numérica ----
if ! printf '%s\n' "$USAGE" | grep -Eq '^[0-9]+$'; then
  echo "No se pudo parsear uso: $USAGE_RAW" >&2
  exit 3
fi

# ---- Comparación y notificación ----
if [ "$USAGE" -ge "$THRESHOLD" ]; then
  MESSAGE="⚠️ *Alerta de disco*: $DISK está al *${USAGE}%* de capacidad (umbral: *${THRESHOLD}%*)."
  # Enviar a Slack
  curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MESSAGE\"}" "$SLACK_WEBHOOK" >/dev/null 2>&1 || true
  # Log local
  printf '%s %s\n' "$(date -Iseconds)" "$MESSAGE" >> "$LOGFILE" 2>/dev/null || true
  exit 0
fi

# nada que notificar
exit 0
