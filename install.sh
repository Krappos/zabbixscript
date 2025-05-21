#!/bin/bash
# Automatizovaná inštalácia Zabbix servera na Ubuntu 24.04
# Skript predpokladá čistú inštaláciu a prístup ako sudo užívateľ

set -e

ZABBIX_DB_PASS= Heslo  
ZABBIX_VERSION="7.0"

echo "Aktualizujem systém..."
sudo apt update && sudo apt upgrade -y

echo "Inštalujem potrebné balíky..."
sudo apt install -y wget mariadb-server

echo "Spúšťam a povoľujem MariaDB..."
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "Pridávam Zabbix repozitár..."
wget https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VERSION}-1+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_${ZABBIX_VERSION}-1+ubuntu24.04_all.deb
sudo apt update

echo "Inštalujem Zabbix server, frontend, agenta a Apache..."
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent

echo "Vytváram databázu a užívateľa pre Zabbix..."
sudo mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '${ZABBIX_DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Importujem základnú databázovú schému..."
zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p${ZABBIX_DB_PASS} zabbix

echo "Konfigurujem Zabbix server..."
sudo sed -i "s/# DBPassword=/DBPassword=${ZABBIX_DB_PASS}/" /etc/zabbix/zabbix_server.conf

echo "Reštartujem a povolujem služby Zabbix a Apache..."
sudo systemctl restart zabbix-server apache2 zabbix-agent
sudo systemctl enable zabbix-server apache2 zabbix-agent

echo "Inštalácia dokončená!"
echo "Otvorte vo webovom prehliadači: http://IP_TVOJEJ_VM/zabbix"
echo "Prihlasovacie údaje:"
echo " - Užívateľ: Admin"
echo " - Heslo: zabbix"


chmod +x install.sh

sudo ./install.sh



