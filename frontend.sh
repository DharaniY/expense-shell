#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d'.' -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
VALIDATION(){
    if [$1 -ne 0]
    then
        echo -e "$2 is $R FAILURE $N"
    else
        echo -e "$2 is $G SUCCESSFUL $N"
    fi        
}
if [$USERID -ne 0]
then
    echo "Your not root user, please login with root user"
else
    echo "Your super user"
fi        

dnf install nginx -y &>>$LOG_FILE
VALIDATION $? "mginx installtion"

systemctl enable nginx &>>$LOG_FILE
VALIDATION $? "Enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATION $? "Staring niginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATION $? "removing html files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATION $? "dowinloading package"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATION $? "change directory"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATION $? "Unzipping files"

#check your repo and path
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx"
