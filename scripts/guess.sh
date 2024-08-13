#! /bin/bash

# Trap ERR signal and call the error handler function
trap 'handle_error' ERR

# Error handler function
handle_error() {
    echo "An error occurred. Please enter a valid number."
}

# Function to check if input is a valid number
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

MAGIC_NUMBER=$((1 + $RANDOM % 100))
declare -i attempts

while true; do
    read -p "Guess a number: " random

    # Validate if input is a number
    if ! is_number "$random"; then
        echo "Invalid input. Please enter a valid number."
        continue
    fi

    # Perform comparisons once the input is validated
    if [ "$random" -eq "$MAGIC_NUMBER" ]; then
        echo "Congratulations! It took $attempts attempts."
        break
    fi
    if [ "$random" -lt "$MAGIC_NUMBER" ]; then
        echo "Your number is too low!"
    else
        echo "Your number is too high!"
    fi
    attempts+=1
done
