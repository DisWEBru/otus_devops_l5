#!/bin/bash

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
  --zone "$YC_COMPUTE_DEFAULT_ZONE" \
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
  --zone "$YC_COMPUTE_DEFAULT_ZONE" \
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
echo -e "\e[32m""Creating an internal server 2""\e[0m"
INTERNAL_SERVER_2=$(yc compute instance create \
  --name "$INTERNAL_SERVER_2_NAME" \
  --zone "$YC_COMPUTE_DEFAULT_ZONE" \
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
