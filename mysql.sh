#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d'.' -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"   

if [ "$USERID" -ne 0 ]
then
    echo "Login with root user for perform this action."
    exit 1  # exit if user is not root user
else
    echo "You are root user"
fi
VALIDATION(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILED $N"
        exit 1 # exit if installation is FAILED
    else
        echo -e "$2 is $G SUCCESS $N"    
    fi    
}

# install mysql package
dnf install mysql-server -y &>>$LOG_FILE
VALIDATION $? "Installing MYSQL server"

# enabling mysql server
systemctl enable mysqld &>>$LOG_FILE
VALIDATION $? "enabling mysql server" 

#Starting mysql server
systemctl start mysqld &>>$LOG_FILE
VALIDATION $? "Starting mysql server"

# changing default password for mysql server
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
VALIDATION $? "setting mysql server root password"
