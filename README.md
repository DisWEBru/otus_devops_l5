# Учебное задание: создание бастионного хоста

## Задача

При помощи bash создать 3 виртуальных машины в YC. 1 виртуальная машина имеет белый внешний IP, 2 других - только локальные адреса

## Необходимый софт

Для запуска на компьютере должны быть: git, docker, docker compose

## Инструкция по запуску

Обязательные параметры помечены *

Загрузить из репозитория

```
git clone https://github.com/DisWEBru/otus_devops_l5.git
```

Перейти в директорию проекта

```
cd otus_devops_l5
```

Копировать .env.example в .env

```
cp .env.example .env
```

Открыть и заполнить в .env общие параметры

- **YC_TOKEN** * - OAuth-токен в сервисе Яндекс ID (Подробнее: https://yandex.cloud/ru/docs/cli/quickstart#initialize)
- **YC_CLOUD_ID** * - ID облака в котором каталог для развертывания
- **YC_FOLDER_ID** * - ID каталога для развертывания
- **YC_COMPUTE_DEFAULT_ZONE** - Зона

### Создание серверов

Открыть и заполнить в .env параметры для серверов

- **SSH_KEY** * - Публичный ключ для серверов
- **INTERNAL_SG_ID** * - ID группы безопасности для внутренней сети
- **INTERNAL_SUBNET_ID** * - ID внутренней подсети
- **EXTERNAL_SG_ID** * - ID группы безопасности для внешней сети
- **EXTERNAL_SUBNET_ID** * - ID внешней подсети
- **EXTERNAL_IP_VAL** * - IP внешний
- **BASTION_NAME** - Наименование сервера bastion
- **BASTION_USER** - Пользователь для сервера bastion
- **BASTION_INTERNAL_IP** - Локальный IP bastion
- **INTERNAL_SERVER_1_NAME** - Наименование внутреннего сервера 1
- **INTERNAL_SERVER_1_USER** - Пользователь внутреннего сервера 1
- **INTERNAL_SERVER_2_NAME** - Наименование внутреннего сервера 2
- **INTERNAL_SERVER_2_USER** - Пользователь внутреннего сервера 2

Запустить скрипт на создание серверов

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat servers.sh)"
```

### Создание сетей

Открыть и заполнить в .env параметры для сетей

- **IP_NAME** - Имя для IP
- **EXTERNAL_NETWORK_NAME** - Имя внешней сети
- **EXTERNAL_SUBNET_NAME** - Имя внешней подсети
- **EXTERNAL_CIDR** - CIDR внешней подсети
- **INTERNAL_NETWORK_NAME** - Имя внутренней сети
- **INTERNAL_SUBNET_NAME** - Имя внутренней подсети
- **INTERNAL_CIDR** - CIDR внутренней подсети
- **EXTERNAL_SG_NAME** - Имя группы безопастности для внешней сети
- **EXTERNAL_SG_INCOM_CIDR** - Правила на входящий CIDR для внешней сети
- **INTERNAL_SG_NAME** - Имя группы безопастности для внутренней сети
- **INTERNAL_SG_INCOM_CIDR** - Правила на входящий CIDR для внутренней сети
- **OPENING_PORT** - Открываемый порт

Запустить скрипт на создание сетей

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat networks.sh)"
```

### Создание сетей и серверов

Открыть и заполнить в .env параметры для сетей и серверов

- **SSH_KEY** * - Публичный ключ
- **BASTION_NAME** - Наименование сервера bastion
- **BASTION_INTERNAL_IP** - Локальный IP bastion
- **BASTION_USER** - Пользователь для сервера bastion
- **INTERNAL_SERVER_1_NAME** - Наименование внутреннего сервера 1
- **INTERNAL_SERVER_1_USER** - Пользователь внутреннего сервера 1
- **INTERNAL_SERVER_2_NAME** - Наименование внутреннего сервера 2
- **INTERNAL_SERVER_2_USER** - Пользователь внутреннего сервера 2
- **IP_NAME** - Имя для IP
- **EXTERNAL_NETWORK_NAME** - Имя внешней сети
- **EXTERNAL_SUBNET_NAME** - Имя внешней подсети
- **EXTERNAL_CIDR** - CIDR внешней подсети
- **INTERNAL_NETWORK_NAME** - Имя внутренней сети
- **INTERNAL_SUBNET_NAME** - Имя внутренней подсети
- **INTERNAL_CIDR** - CIDR внутренней подсети
- **EXTERNAL_SG_NAME** - Имя группы безопастности для внешней сети
- **EXTERNAL_SG_INCOM_CIDR** - Правила на входящий CIDR для внешней сети
- **INTERNAL_SG_NAME** - Имя группы безопастности для внутренней сети
- **INTERNAL_SG_INCOM_CIDR** - Правила на входящий CIDR для внутренней сети
- **OPENING_PORT** - Открываемый порт

Запустить скрипт на создание сетей и серверов

```
docker compose run --rm -it disweb.yandex.cli bash -c "$(cat full.sh)"
```
