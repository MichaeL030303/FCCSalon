#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
MENU() {
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then
    MENU "\nThe selected service does't exist, please insert a valid one"
  else
    SERVICES
  fi
}
SERVICES() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  echo -e "\nInsert your phone number"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nYour name is not in the system, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  fi
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)
  echo When do you want your $SERVICE_NAME, $CUSTOMER_NAME?
  read SERVICE_TIME
  APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID, $CUSTOMER_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}
echo -e "\nWelcome to the salon, how can I help you?\n"
MENU
