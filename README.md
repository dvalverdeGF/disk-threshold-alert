
# disk_alert_slack

**Monitoriza el uso de disco de un servidor Linux y envía alertas a Slack cuando se supera un umbral configurado.**

## Características

* Configurable por **umbral de porcentaje** (`THRESHOLD`) y disco (`DISK`) a monitorizar.
* Envía alertas a **Slack** mediante Webhook.
* Compatible con **cron**, para comprobaciones periódicas (diarias, cada hora, etc.).
* Registra alertas en un **archivo de log**.
* Manejo robusto de errores: disco no encontrado o uso no numérico.
* Fácil de extender para **email** u otros canales de notificación.
* Ideal para servidores críticos y buzones de correo.

---

## Requisitos

* Linux / Unix
* `bash`
* `curl`
* (Opcional) `mail` si quieres añadir notificaciones por email

---

## Instalación

1. Clona el repositorio:

```bash
git clone https://github.com/tuusuario/slack-disk-alert.git
cd slack-disk-alert
```

2. Copia el script a `/usr/local/bin`:

```bash
sudo cp disk_alert_slack.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/disk_alert_slack.sh
```

3. Edita el script y configura tu Webhook de Slack:

```bash
SLACK_WEBHOOK="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXX"
DISK="/dev/sdc1"
THRESHOLD=90
```

---

## Uso

Ejecuta el script manualmente:

```bash
/usr/local/bin/disk_alert_slack.sh
```

Forzar un umbral distinto sin editar el script:

```bash
THRESHOLD=80 /usr/local/bin/disk_alert_slack.sh
```

Pasando argumentos:

```bash
/usr/local/bin/disk_alert_slack.sh 80 /dev/sdb1
```

---

## Programar en Cron

Para ejecutar **una vez al día a las 08:00**:

```bash
0 8 * * * /usr/local/bin/disk_alert_slack.sh >/dev/null 2>&1
```

Para ejecutar **cada 5 minutos**:

```bash
*/5 * * * * /usr/local/bin/disk_alert_slack.sh >/dev/null 2>&1
```

---

## Registro de alertas

El script guarda un registro local en:

```bash
/var/log/disk_alert_slack.log
```

Puedes revisar el historial de alertas allí.

---

## Ejemplo de mensaje en Slack

```
⚠️ Alerta de disco: /dev/sdc1 está al 91% de capacidad (umbral: 90%).
```

---

## Extensiones posibles

* Añadir alertas por **email** con `mail` o `ssmtp`.
* Monitorear **varios discos** en el mismo script.
* Enviar alertas cuando el disco **baje de un umbral** para notificar recuperación.
* Integración con otros canales (Telegram, Discord, Teams).

---

¿Quieres que haga también la **versión del README con instrucciones de instalación automática por cron y prueba de alerta forzada** lista para copiar y pegar en GitHub?

