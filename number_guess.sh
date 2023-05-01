#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Add game function
GUESS_NUMBER() {

  # Add name prompt
  echo "Enter your username:"
  read USERNAME

  # Get username 
  PLAYER=$($PSQL "SELECT username FROM players WHERE username = '$USERNAME'")

  # Check if player name exists
  # If doesn't exist, add player
  if [[ -z $PLAYER ]]
  then
    INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username = '$USERNAME'")
    echo "Welcome back, $PLAYER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
  fi

  # Generate secret number
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
  echo "SECRET NUMBER = $SECRET_NUMBER"

  # Init number of guesses
  GUESS=1

  # Ask for a number
  echo "Guess the secret number between 1 and 1000:"
  read INPUT_NUMBER

  # Game starts
  # Infinite loop until the input is equal to secret number
  while [[ $INPUT_NUMBER != $SECRET_NUMBER ]]
  do
    # Check if input is a number
    while [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read INPUT_NUMBER
    done

    # Check if input is greater or lower than secret number
    if [[ $INPUT_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read INPUT_NUMBER
    else
      echo "It's higher than that, guess again:"
      read INPUT_NUMBER
    fi

    # Increment guesses number
    GUESS=$(( $GUESS + 1 ))
  done

  # Prompt when game is over
  echo "You guessed it in $GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"

  # Update data
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(number_of_guesses ,secret_number, player_id) VALUES($GUESS, $SECRET_NUMBER, $PLAYER_ID)")

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED WHERE player_id = $PLAYER_ID")

  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE player_id = $PLAYER_ID")
  UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game = $BEST_GAME WHERE player_id = $PLAYER_ID")
}

GUESS_NUMBER
