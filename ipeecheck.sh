#!/bin/bash

#exits if there is an unbound variable or an error
set -o nounset
set -o errexit

SERVER="http://icanhazip.com"
ADDR_HST_FILE="$HOME/.ipeecheck_address_history"
EMAIL=name@host.com

#checks if address history file exists.
#if not, it creates it.
if [ -f "$ADDR_HST_FILE" ]
then
    echo "Address history file exists."
else
    echo "Address history file doesn't exist."
    echo "Creating file $ADDR_HST_FILE"
    touch $ADDR_HST_FILE
fi

#gets the current addr from the specified server and
#gets the latest addr from the address history file.
#stores both addresses in variables
echo "Checking current ip address..."
CURRENT_ADDR=$(curl --silent "$SERVER")
PREVIOUS_ADDR=$(tail -n 1 "$ADDR_HST_FILE")

#checks if address has changed since previous execution
#if it hasn't changed, it does nothing.
#else, it appends it to the history file and sends an e-mail
if [ "$CURRENT_ADDR" = "$PREVIOUS_ADDR"  ]
then
    echo "Your ip address hasn't changed."
    exit 0
else
    echo "Your ip address has changed."
    echo "Storing new ip address in $ADDR_HST_FILE"
    echo "$CURRENT_ADDR" >> "$ADDR_HST_FILE"

    echo -e "Your ip address for host $HOSTNAME has changed.\n\
Your new ip address is:\n$CURRENT_ADDR"\
| mailx -v -s "[IPEECHECK] Your ip address has changed" $EMAIL
fi
