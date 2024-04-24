#!/bin/bash

USERID=$(id -u) # get the current user ID
TIMESTAMP=$(date +%F-%H-%M-%S) # get the current timestamp
SCRIPT_NAME=$(echo $0 | cut -d'.' -f1) # get script name
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password:"
read -s mysql_root_password

if [ "$USERID" -ne 0 ]
then
    echo "Please perform this action with ROOT user"
else
    echo "Your super user"
fi
VALIDATION(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILED $N"
    else
        echo -e "$2 is $G SUCCESSFUL $N"
    fi
}
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATION $? "Disabling node.js"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATION $? "Enabling node.js"

dnf install nodejs -y &>>$LOG_FILE
VALIDATION $? "Installing nodejs"

useradd expense &>>$LOG_FILE
VALIDATION $? "Adding user"

mkdir /app &>>$LOG_FILE
VALIDATION $? "creating folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATION $? "Downloading package"

cd /app &>>$LOG_FILE
rm -rf /app/*
VALIDATION $? "Change directory"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATION $? "Unzipping the package"

npm install &>>$LOG_FILE
VALIDATION $? "Execute npm command"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATION $? "Copying backend service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATION $? "Restart system"

systemctl start backend &>>$LOG_FILE
VALIDATION $? "Starting backend"

systemctl enable backend &>>$LOG_FILE
VALIDATION $? "Enable Backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATION $? "Installing sql client"

mysql -h db.sivasatya.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG_FILE
VALIDATION $? "schema Loading"

systemctl restart backend &>>$LOG_FILE
VALIDATION $? "restating backend"