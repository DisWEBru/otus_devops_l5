#!/bin/bash

# SSH публичный ключ для доступа !!!
SSH_KEY=""

# Наименование сервера bastion
BASTION_NAME="otus-bastion-host"
# Локальный IP bastion
BASTION_INTERNAL_IP="172.16.16.254"
# Пользователь для сервера bastion
BASTION_USER="bastion"

# Зона (zone)
ZONE="ru-central1-b"

# IP внешний (IP external)
EXTERNAL_IP_VAL="130.193.40.115"

# Группа безопасности для внешней сети !!!
EXTERNAL_SG_ID=

# Группа безопасности для внутренней сети !!!
INTERNAL_SG_ID=

# Внешняя подсеть !!!
EXTERNAL_SUBNET_ID=

# Внутренняя подсеть !!!
INTERNAL_SUBNET_ID=

### ------------------------------------------------------------------

echo -e "#cloud-config\n"\
"users:\n"\
"  - name: $BASTION_USER\n"\
"    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n"\
"    shell: /bin/bash\n"\
"    ssh_authorized_keys:\n"\
"      - $SSH_KEY\n" > bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml

# Создание сервера bastion
echo -e "\e[32m""Creating a bastion server""\e[0m"
EXTERNAL_SERVER_BASTION=$(yc compute instance create \
  --name "$BASTION_NAME" \
  --zone "$ZONE" \
  --hostname "$BASTION_NAME" \
  --network-interface subnet-id="$EXTERNAL_SUBNET_ID",nat-address="$EXTERNAL_IP_VAL",security-group-ids="$EXTERNAL_SG_ID" \
  --network-interface subnet-id="$INTERNAL_SUBNET_ID",ipv4-address="$BASTION_INTERNAL_IP",security-group-ids="$INTERNAL_SG_ID" \
  --platform standard-v3 \
  --preemptible \
  --memory 1g \
  --cores 2 \
  --core-fraction 20 \
  --create-boot-disk name="$BASTION_NAME"-disk,size=20g,type=network-hdd,image-folder-id=standard-images,image-family=ubuntu-2404-lts \
  --format json \
  --metadata-from-file user-data=bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml)

echo -e "\033[33m""ssh $BASTION_USER@$EXTERNAL_IP_VAL""\e[0m"

rm -f bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml

echo "✅ Done"
