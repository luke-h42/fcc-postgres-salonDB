#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


SERVICE_MENU(){
echo "What salon service would you like to book?"
#get and list available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
AVAILABLE_SERVICE_ID=$($PSQL "SELECT service_id FROM services")
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done
#take user input
read SERVICE_ID_SELECTED
SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
#if not a number not in the list 
if [[ ! $AVAILABLE_SERVICE_ID =~ (^|[[:space:]])$SERVICE_ID_SELECTED([[:space:]]|$) ]]
then
  # return to service menu
  echo -e "\nThat is not a valid service number.\n"
  SERVICE_MENU 
else 
  # ask for phone number of customer
  echo "Please enter your phone number to make a booking:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if phone number not registered, ask for a name
  if [[ -z $CUSTOMER_NAME ]] 
  then
    echo -e "\nWelcome to the Salon, please enter your name for the booking:\n"
    read CUSTOMER_NAME
    # insert new customer into database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # ask for appointment time 
  echo "What time would you like that booked in for?"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a$SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
fi
    


# output message 
}

SERVICE_MENU