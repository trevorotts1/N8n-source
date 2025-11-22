FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache \
      ffmpeg \
      aws-cli \
      busybox-extras \
 && mkdir -p /home/node/.n8n \
 && chown -R node:node /home/node \
 && mkdir -p /opt/.n8n \
 && chown -R node:node /opt/.n8n

ENV N8N_USER_FOLDER=/opt/.n8n

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

COPY n8n-backup-cron /etc/crontabs/root

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER node

CMD ["/docker-entrypoint.sh"]
