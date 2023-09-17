#!/bin/bash

# Проверка на наличие задачи в crontab
CRON_JOB="0 2 * * * /home/wireguard/datetime.sh"
if ! (crontab -l | grep -q "datetime.sh"); then
    (crontab -l ; echo "$CRON_JOB") | crontab -
    echo "Cron job added successfully."
else
    echo "Cron job already exists."
fi
