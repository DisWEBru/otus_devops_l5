FROM debian:bookworm-slim

# Устанавливаем необходимые пакеты и зависимости
RUN apt-get update && apt-get install -y \
    curl \
    jq

# Установка yc CLI
RUN curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash && \
    ln -s /root/yandex-cloud/bin/yc /usr/local/bin/yc

# Создаем entrypoint.sh
RUN echo '#!/bin/bash' > /usr/local/bin/entrypoint.sh && \
    echo 'yc config set token "$YC_TOKEN"' >> /usr/local/bin/entrypoint.sh && \
    echo 'yc config set cloud-id "$YC_CLOUD_ID"' >> /usr/local/bin/entrypoint.sh && \
    echo 'yc config set folder-id "$YC_FOLDER_ID"' >> /usr/local/bin/entrypoint.sh && \
    echo 'yc config set compute-default-zone "$YC_COMPUTE_DEFAULT_ZONE"' >> /usr/local/bin/entrypoint.sh && \
    echo 'exec "$@"' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Рабочая директория
WORKDIR /root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
