#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

DISPLAY_SERVICES() {
  echo -e "\nHere are the services we offer:"
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

MAIN_MENU() {
  DISPLAY_SERVICES
  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nInvalid service. Please try again."
    MAIN_MENU
  else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nIt looks like you're a new customer. Please enter your name:"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
