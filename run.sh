#!/bin/bash

# SSH публичный ключ для доступа
SSH_KEY=""

# Наименование сервера bastion
BASTION_NAME="otus-bastion-host"
# Локальный IP bastion
BASTION_INTERNAL_IP="172.16.16.254"
# Пользователь для сервера bastion
BASTION_USER="bastion"

# Наименование внутреннего сервера 1
INTERNAL_SERVER_1_NAME="otus-test-vm-1"
# Пользователь для внутреннего сервера 1
INTERNAL_SERVER_1_USER="test"

# Наименование внутреннего сервера 2
INTERNAL_SERVER_2_NAME="otus-test-vm-2"
# Пользователь для внутреннего сервера 2
INTERNAL_SERVER_2_USER="test"

# Зона (zone)
ZONE="ru-central1-b"

# Имя для IP (IP name)
IP_NAME="bastion-public-ip"

# Настройки внешней сети (external network settings)
# Имя сети (network name)
EXTERNAL_NETWORK_NAME="external-bastion-network"
# Имя подсети (subnet name)
EXTERNAL_SUBNET_NAME="bastion-external-segment"
# CIDR
EXTERNAL_CIDR="172.16.17.0/28"

# Настройки внутренней сети (internal network settings)
# Имя сети (network name)
INTERNAL_NETWORK_NAME="internal-bastion-network"
# Имя подсети (subnet name)
INTERNAL_SUBNET_NAME="bastion-internal-segment"
# CIDR
INTERNAL_CIDR="172.16.16.0/24"

# Группа безопастности для внешней сети (security group for external network)
# Имя (Name)
EXTERNAL_SG_NAME="secure-bastion-sg2"
# Правила на входящий CIDR (incoming CIDR rules)
EXTERNAL_SG_INCOM_CIDR="0.0.0.0/0"

# Группа безопастности для внутренней сети (security group for internal network)
# Имя (Name)
INTERNAL_SG_NAME="internal-bastion-sg2"
# Правила на входящий CIDR (incoming CIDR rules)
INTERNAL_SG_INCOM_CIDR="172.16.16.254/32"

# Открываемый порт (opening port)
OPENING_PORT=22

### ------------------------------------------------------------------

# Создание внешней сети
echo -e "\e[32m""Creating an external network: $EXTERNAL_NETWORK_NAME""\e[0m"
EXTERNAL_NETWORK_ID=$(yc vpc network create --name "$EXTERNAL_NETWORK_NAME" --format json | jq -r .id)

# Создание подсети
echo -e "\e[32m""Creating a subnet: $EXTERNAL_SUBNET_NAME""\e[0m"
EXTERNAL_SUBNET_ID=$(yc vpc subnet create \
  --name "$EXTERNAL_SUBNET_NAME" \
  --zone "$ZONE" \
  --range "$EXTERNAL_CIDR" \
  --network-id "$EXTERNAL_NETWORK_ID" \
  --format json | jq -r .id)

# Создание внутренней сети
echo -e "\e[32m""Creating an internal network: $INTERNAL_NETWORK_NAME""\e[0m"
INTERNAL_NETWORK_ID=$(yc vpc network create --name "$INTERNAL_NETWORK_NAME" --format json | jq -r .id)

# Создание подсети
echo -e "\e[32m""Creating subnet: $INTERNAL_SUBNET_NAME""\e[0m"
INTERNAL_SUBNET_ID=$(yc vpc subnet create \
  --name "$INTERNAL_SUBNET_NAME" \
  --zone "$ZONE" \
  --range "$INTERNAL_CIDR" \
  --network-id "$INTERNAL_NETWORK_ID" \
  --format json | jq -r .id)

# Создание группы безопасности для внешней сети
echo -e "\e[32m""Creating security group for external network: $EXTERNAL_SG_NAME""\e[0m"
EXTERNAL_SG_ID=$(yc vpc security-group create \
  --name "$EXTERNAL_SG_NAME" \
  --network-id "$EXTERNAL_NETWORK_ID" \
  --format json | jq -r .id)

# Добавление входящего правила в группу безопасности для внешней сети
echo -e "\e[32m""Adding an incoming rule to $EXTERNAL_SG_NAME""\e[0m"
EXTERNAL_ROLE_INCOMING=$(yc vpc security-group update-rules "$EXTERNAL_SG_ID" \
  --add-rule "direction=ingress,port=$OPENING_PORT,protocol=tcp,v4-cidrs=[$EXTERNAL_SG_INCOM_CIDR]"
  --format json)

# Создание группы безопасности для внутренней сети
echo -e "\e[32m""Creating security group: $INTERNAL_SG_NAME""\e[0m"
INTERNAL_SG_ID=$(yc vpc security-group create \
  --name "$INTERNAL_SG_NAME" \
  --network-id "$INTERNAL_NETWORK_ID" \
  --format json | jq -r .id)

# Добавление входящего правила в группу безопасности для внутренней сети
echo -e "\e[32m""Adding an incoming rule to $INTERNAL_SG_NAME""\e[0m"
INTERNAL_ROLE_INCOMING=$(yc vpc security-group update-rules "$INTERNAL_SG_ID" \
  --add-rule "direction=ingress,port=$OPENING_PORT,protocol=tcp,v4-cidrs=[$INTERNAL_SG_INCOM_CIDR]"
  --format json)

# Добавление исходящего правила в группу безопасности для внутренней сети
echo -e "\e[32m""Adding an outcoming rule to $INTERNAL_SG_NAME""\e[0m"
INTERNAL_ROLE_OUTCOMING=$(yc vpc security-group update-rules "$INTERNAL_SG_ID" \
  --add-rule "direction=egress,port=$OPENING_PORT,protocol=tcp,predefined=self_security_group"
  --format json)

# Резервирование публичного IP
echo -e "\e[32m""Public IP reservation""\e[0m"
EXTERNAL_IP=$(yc vpc address create \
  --name "$IP_NAME" \
  --external-ipv4=[zone="$ZONE"] \
  --format json)

EXTERNAL_IP_VAL=$(echo "$EXTERNAL_IP" | jq -r .external_ipv4_address.address)

echo -e "Public IP: ""\033[33m""$EXTERNAL_IP_VAL""\e[0m"

EXTERNAL_IP_ID=$(echo "$EXTERNAL_IP" | jq -r .id)

# Создание сервера bastion
echo -e "#cloud-config\n"\
"users:\n"\
"  - name: $BASTION_USER\n"\
"    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n"\
"    shell: /bin/bash\n"\
"    ssh_authorized_keys:\n"\
"      - $SSH_KEY\n" > bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml
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

# Создание внутреннего сервера 1
echo -e "#cloud-config\n"\
"users:\n"\
"  - name: $INTERNAL_SERVER_1_USER\n"\
"    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n"\
"    shell: /bin/bash\n"\
"    ssh_authorized_keys:\n"\
"      - $SSH_KEY\n" > bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml
echo -e "\e[32m""Creating an internal server 1""\e[0m"
INTERNAL_SERVER_1=$(yc compute instance create \
  --name "$INTERNAL_SERVER_1_NAME" \
  --zone "$ZONE" \
  --hostname "$INTERNAL_SERVER_1_NAME" \
  --network-interface subnet-id="$INTERNAL_SUBNET_ID",security-group-ids="$INTERNAL_SG_ID" \
  --platform standard-v3 \
  --preemptible \
  --memory 1g \
  --cores 2 \
  --core-fraction 20 \
  --create-boot-disk name="$INTERNAL_SERVER_1_NAME"-disk,size=20g,type=network-hdd,image-folder-id=standard-images,image-family=ubuntu-2404-lts \
  --format json \
  --metadata-from-file user-data=bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml)

echo -e "\033[33m""ssh -J $BASTION_USER@$EXTERNAL_IP_VAL $INTERNAL_SERVER_1_USER@"$(echo "$INTERNAL_SERVER_1" | jq -r '.network_interfaces[0].primary_v4_address.address')"\e[0m"

# Создание внутреннего сервера 2
echo -e "#cloud-config\n"\
"users:\n"\
"  - name: $INTERNAL_SERVER_2_USER\n"\
"    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n"\
"    shell: /bin/bash\n"\
"    ssh_authorized_keys:\n"\
"      - $SSH_KEY\n" > bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml
echo -e "\e[32m""Creating an internal server 1""\e[0m"
echo -e "\e[32m""Creating an internal server 2""\e[0m"
INTERNAL_SERVER_2=$(yc compute instance create \
  --name "$INTERNAL_SERVER_2_NAME" \
  --zone "$ZONE" \
  --hostname "$INTERNAL_SERVER_2_NAME" \
  --network-interface subnet-id="$INTERNAL_SUBNET_ID",security-group-ids="$INTERNAL_SG_ID" \
  --platform standard-v3 \
  --preemptible \
  --memory 1g \
  --cores 2 \
  --core-fraction 20 \
  --create-boot-disk name="$INTERNAL_SERVER_2_NAME"-disk,size=20g,type=network-hdd,image-folder-id=standard-images,image-family=ubuntu-2404-lts \
  --format json \
  --metadata-from-file user-data=bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml)

echo -e "\033[33m""ssh -J $BASTION_USER@$EXTERNAL_IP_VAL $INTERNAL_SERVER_2_USER@"$(echo "$INTERNAL_SERVER_2" | jq -r '.network_interfaces[0].primary_v4_address.address')"\e[0m"

rm -f bvq21egtpmy32kg6mfcq9g2pkkipqyov.yaml

echo "✅ Done"
