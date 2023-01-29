#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( RANDOM % 10 + 1 ))

RUN_GAME() {

# Ask for username
echo "Enter your username:"
read USERNAME

# Check if <username> exists in database
CHECK_USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# If doesn't exists...
if [[ -z $CHECK_USER ]]
then
  # Insert <username> into database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  # Print result of inserting user in database
  if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nNew user inserted in DB: $USERNAME\n"
  fi
  # Print welcome message to new user
  echo -e "Welcome, $USERNAME! It looks like this is your first time here.\n"

else
    # If <username> exists in database
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    echo -e "\nWelcome back, $CHECK_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

START_GAME

UPDATE_STATS

}

START_GAME() {

# Print game and get input from user
TRY=0
echo "Guess the secret number between 1 and 1000:"
read INPUT
(( TRY++ ))

# If input is not an integer, get input from user again
until [[ $INPUT == $NUMBER ]]
do
  if [[ $INPUT =~ [^0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
    read INPUT
  elif [[ $INPUT -lt $NUMBER ]]
  then
    (( TRY++ ))
    echo "It's higher than that, guess again:"
    read INPUT
  elif [[ $INPUT -gt $NUMBER ]]
  then
    (( TRY++ ))
    echo "It's lower than that, guess again:"
    read INPUT
  fi
done

echo You guessed it in $TRY tries. The secret number was $NUMBER. Nice job!

}

UPDATE_STATS() {
CHECK_BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ $TRY -lt $CHECK_BEST || $CHECK_BEST == 0 ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$TRY  WHERE username='$USERNAME'")
fi

UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")

}

RUN_GAME