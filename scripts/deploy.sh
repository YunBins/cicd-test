#!/bin/bash

cd /home/ec2-user/app

DOCKER_APP_NAME=spring

# 실행중인 blue가 있는지
EXIST_BLUE=$(sudo docker-compose -p ${DOCKER_APP_NAME}-blue -f docker-compose.blue.yml ps | grep Up)

# green이 실행중이면 blue up
if [ -z "$EXIST_BLUE" ]; then
        echo "blue up"
        sudo docker-compose -p ${DOCKER_APP_NAME}-blue -f docker-compose.blue.yml up -d --build

        BEFORE_COLOR="green"
        AFTER_COLOR="blue"
        BEFORE_PORT=8082
        AFTER_PORT=8081

# blue가 실행중이면 green up
else
        echo "green up"
        sudo docker-compose -p ${DOCKER_APP_NAME}-green -f docker-compose.green.yml up -d --build

        BEFORE_COLOR="blue"
        AFTER_COLOR="green"
        BEFORE_PORT=8081
        AFTER_PORT=8082
fi

echo "${AFTER_COLOR} server up(port:${AFTER_PORT})"

# 2
for cnt in {1..10}
do
        echo "서버 응답 확인중(${cnt}/10)";
        UP=$(curl -s http://127.0.0.1:${AFTER_PORT}/health-check)
        if [ "${UP}" != "up" ]
                then
                        sleep 10
                        continue
                else
                        break
        fi
done

if [ $cnt -eq 10 ]
then
        echo "서버가 정상적으로 구동되지 않았습니다."
        exit 1
fi

# 3
sudo sed -i "s/${BEFORE_PORT}/${AFTER_PORT}/" /etc/nginx/conf.d/service-url.inc
sudo nginx -s reload
echo "배포완료."

# 4
echo "$BEFORE_COLOR server down(port:${BEFORE_PORT})"
sudo docker-compose -p ${DOCKER_APP_NAME}-${BEFORE_COLOR} -f docker-compose.${BEFORE_COLOR}.yml down