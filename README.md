# Учебное задание: создание бастионного хоста

## Задача

При помощи bash создать 3 виртуальных машины в YC. 1 виртуальная машина имеет белый внешний IP, 2 других - только локальные адреса

## Необходимый софт

Для запуска на компьютере должны быть: git, docker, docker compose

## Инструкция по запуску

Загрузить из репозитория

```
git clone https://github.com/DisWEBru/otus_devops_l5.git
```

Перейти в директорию проекта

```
cd otus_devops_l5
```

Открыть и заполнить .env

- **YC_TOKEN** - OAuth-токен в сервисе Яндекс ID (Подробнее: https://yandex.cloud/ru/docs/cli/quickstart#initialize)
- **YC_CLOUD_ID** - ID облака в котором каталог для развертывания
- **YC_FOLDER_ID** - ID каталога для развертывания

### Создание серверов

Открыть и заполнить servers.sh

- **SSH_KEY** - Публичный ключ
- **INTERNAL_SG_ID** - ID группы безопасности для внутренней сети
- **INTERNAL_SUBNET_ID** - ID внешней подсети
- **BASTION_INTERNAL_IP** - Локальный IP bastion
- **BASTION_USER** - Пользователь для сервера bastion
- **EXTERNAL_IP_VAL** - IP внешний (IP external)
- **EXTERNAL_SG_ID** - ID группы безопасности для внешней сети
- **EXTERNAL_SUBNET_ID** - ID внешней подсети
- **INTERNAL_SERVER_1_NAME** - Наименование внутреннего сервера 1
- **INTERNAL_SERVER_1_USER** - Пользователь внутреннего сервера 1
- **INTERNAL_SERVER_2_NAME** - Наименование внутреннего сервера 2
- **INTERNAL_SERVER_2_USER** - Пользователь внутреннего сервера 2

Запустить скрипт на создание серверов

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat servers.sh)"
```

### Создание сетей

Открыть и заполнить networks.sh

- **SSH_KEY** - Публичный ключ

Остальные параметры заполняются при необходимости

Запустить скрипт на создание сетей

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat networks.sh)"
```

### Создание сетей и серверов

Открыть и заполнить full.sh

- **SSH_KEY** - Публичный ключ

Остальные параметры заполняются при необходимости

Запустить скрипт на создание сетей и серверов

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat full.sh)"
```

### Создание сервера бастион

Открыть и заполнить server_bastion.sh

- **SSH_KEY** - Публичный ключ
- **BASTION_INTERNAL_IP** - Локальный IP bastion
- **BASTION_USER** - Пользователь для сервера bastion
- **EXTERNAL_IP_VAL** - IP внешний (IP external)
- **EXTERNAL_SG_ID** - ID группы безопасности для внешней сети
- **INTERNAL_SG_ID** - ID группы безопасности для внутренней сети
- **EXTERNAL_SUBNET_ID** - ID внешней подсети
- **INTERNAL_SUBNET_ID** - ID внешней подсети

Запустить скрипт на создание сервера bastion

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat server_bastion.sh)"
```
