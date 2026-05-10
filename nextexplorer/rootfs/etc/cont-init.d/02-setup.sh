#!/usr/bin/with-contenv bashio

CONFIG_PATH="/etc/autofs/auto.cifs"

bashio::log.info "Generating autofs configuration..."
V_ROOT="${VOLUME_ROOT:-/storage}"

> "$CONFIG_PATH"

for mount in $(bashio::config 'mounts|keys'); do
    SERVER=$(bashio::config "mounts[${mount}].server")
    SERVER_CLEAN=$(echo "$SERVER" | sed 's|^//||')
    
    NAME=$(bashio::config "mounts[${mount}].name")
    USER=$(bashio::config "mounts[${mount}].username")
    PASS=$(bashio::config "mounts[${mount}].password")
    
    # Точка монтирования (полный путь для direct maps)
    MOUNT_POINT="$V_ROOT/${NAME}"
    
    # Создаем папку, если её нет (обязательно для direct maps)
    mkdir -p "$MOUNT_POINT"

    # Формируем строку для auto.cifs
    # Используем vers=3.0 как стандарт, noserverino для стабильности
    ENTRY="${MOUNT_POINT} -fstype=cifs,rw,username=${USER},password=${PASS},noserverino,iocharset=utf8 ://${SERVER_CLEAN}"
    
    echo "$ENTRY" >> "$CONFIG_PATH"
    
    bashio::log.info "Configured automount for ${NAME} at ${MOUNT_POINT}"
done

# Устанавливаем права доступа (только root должен видеть пароли)
chmod 600 "$CONFIG_PATH"

bashio::log.info "Autofs configuration generated."