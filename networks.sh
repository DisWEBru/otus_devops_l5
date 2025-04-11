#!/bin/bash

# Создание внешней сети
echo -e "\e[32m""Creating an external network: $EXTERNAL_NETWORK_NAME""\e[0m"
EXTERNAL_NETWORK_ID=$(yc vpc network create --name "$EXTERNAL_NETWORK_NAME" --format json | jq -r .id)

# Создание подсети
echo -e "\e[32m""Creating a subnet: $EXTERNAL_SUBNET_NAME""\e[0m"
EXTERNAL_SUBNET_ID=$(yc vpc subnet create \
  --name "$EXTERNAL_SUBNET_NAME" \
  --zone "$YC_COMPUTE_DEFAULT_ZONE" \
  --range "$EXTERNAL_CIDR" \
  --network-id "$EXTERNAL_NETWORK_ID" \
  --format json | jq -r .id)

echo -e "Subnet ID \"$EXTERNAL_SUBNET_NAME\": ""\033[33m""$EXTERNAL_SUBNET_ID""\e[0m"

# Создание внутренней сети
echo -e "\e[32m""Creating an internal network: $INTERNAL_NETWORK_NAME""\e[0m"
INTERNAL_NETWORK_ID=$(yc vpc network create --name "$INTERNAL_NETWORK_NAME" --format json | jq -r .id)

# Создание подсети
echo -e "\e[32m""Creating subnet: $INTERNAL_SUBNET_NAME""\e[0m"
INTERNAL_SUBNET_ID=$(yc vpc subnet create \
  --name "$INTERNAL_SUBNET_NAME" \
  --zone "$YC_COMPUTE_DEFAULT_ZONE" \
  --range "$INTERNAL_CIDR" \
  --network-id "$INTERNAL_NETWORK_ID" \
  --format json | jq -r .id)

echo -e "Subnet ID \"$INTERNAL_SUBNET_NAME\": ""\033[33m""$INTERNAL_SUBNET_ID""\e[0m"

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

echo -e "Security group ID \"$EXTERNAL_SG_NAME\": ""\033[33m""$EXTERNAL_SG_ID""\e[0m"

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

echo -e "Security group ID \"$INTERNAL_SG_NAME\": ""\033[33m""$INTERNAL_SG_ID""\e[0m"

# Резервирование публичного IP
echo -e "\e[32m""Public IP reservation""\e[0m"
EXTERNAL_IP=$(yc vpc address create \
  --name "$IP_NAME" \
  --external-ipv4=[zone="$YC_COMPUTE_DEFAULT_ZONE"] \
  --format json)

EXTERNAL_IP_VAL=$(echo "$EXTERNAL_IP" | jq -r .external_ipv4_address.address)

echo -e "Public IP: ""\033[33m""$EXTERNAL_IP_VAL""\e[0m"

echo "✅ Done"
