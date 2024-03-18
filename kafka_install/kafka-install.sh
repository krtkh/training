#/bin/bash
### Скрипт по установке Apache Kafka на Linux
### Переменные
echo "Введите путь куда скачать дистрибутив"
read DISTR_DIR
sleep 1
echo "Введите путь куда установится Apache Kafka дистрибутив"
read KAFKA_DIR
sleep 1
echo "Введите путь где Apache Kafka будет хранить данные"
read DATA_DIR

### Обновление системы
clear
sleep 1
echo "Обновляем систему"
sleep 2
sudo apt update -y
sudo apt upgrade -y
clear
### Установка Java и проверка версии
sleep 2
echo "Устанавливаем пакет jdk"
sleep 2
sudo apt install default-jdk -y
sleep 2
clear
echo "Проверяем версию Java"
echo " "
java -version
sleep 2
clear
### Создание папки для дистрибутива в домашнем каталоге, папки для кафки и для данных
echo "Создаем папки для дистрибутива, кафки и данных для кафки"
sleep 2
sudo mkdir $DISTR_DIR
sudo mkdir $KAFKA_DIR
sudo mkdir $DATA_DIR
sleep 2
clear
### Создание пользователя kafka для управления apache kafka и выдача ему прав на директории
echo "Создаем пользователя кафка"
sleep 2
sudo useradd -r -c 'Kafka broker user service' kafka
sudo chown -R kafka:kafka $KAFKA_DIR
sudo chown -R kafka:kafka $DATA_DIR
clear
### Скачивание дистрибутива kafka в папку ~/distr
echo "Требуется ссылка на дистрибутив,вставьте полную ссылку:"
read KAFKA_DISTR
cd ~/distr
sudo wget $KAFKA_DISTR
sleep 2
clear
### Разархивирование kafka и копирование дистрибутива в /opt/kafka
echo "Распаковываем архив и копируем его в /opt/kafka"
cd ~/distr
sudo tar zxf kafka_*.tgz -C /opt/kafka --strip 1
sleep 2
clear
### Правим файл конфигурации
echo "Сейчас будет предложено поправить файл конфигурации перед первым запуском Apache Kafka"
sleep 3
sudo vi /opt/kafka/config/server.properties
echo "Файл конфигурации обновлен"
sleep 1
clear
### Создаем Unit файлы
echo "Создаем Unit файлы"
sudo touch /etc/systemd/system/zookeeper.service
sudo touch /etc/systemd/system/kafka.service
sudo chmod 777 /etc/systemd/system/zookeeper.service /etc/systemd/system/kafka.service
sudo echo "
[Unit]
Description=Zookeeper Service
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/zookeeper.service

sudo echo "
[Unit]
Description=Kafka Service
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /opt/kafka/kafka.log 2>&1'
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/kafka.service
sleep 2
clear
echo "Перечитываем конфигурацию systemd, чтобы подхватить изменения"
sudo systemctl daemon-reload
sleep 1
echo "Разрешаем автозапуск сервисов zookeeper и kafka"
sudo systemctl enable zookeeper kafka
sleep 1
echo "Стартуем кафку"
sudo systemctl start kafka
sleep 1
clear
echo "Выводим статус процесса Kafka"
sleep 1
sudo systemctl status kafka.service
