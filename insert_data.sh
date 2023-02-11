#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    CURRENT_WINNER=""
    CURRENT_WINNER=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")
    if [[ -z $CURRENT_WINNER ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    else
      echo -e "\n$WINNER already in database"
    fi
  fi
  if [[ $OPPONENT != "opponent" ]]
  then
    CURRENT_OPPONENT=""
    CURRENT_OPPONENT=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $CURRENT_OPPONENT ]]
    then
    INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    else
      echo -e "\n$OPPONENT already in database"
    fi
  fi
done
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # get winner/opponent team_ids
  if [[ $YEAR != 'year' ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # insert into database
    INSERT_GAME=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND')")
    if [[ $INSERT_GAME == 'INSERT 0 1' ]]
    then
      echo -e "\nInserted $WINNER($WINNER_ID) v. $OPPONENT($OPPONENT_ID) ($YEAR)"
    fi
  fi
done
echo $($PSQL "SELECT * FROM teams")
echo $($PSQL "SELECT * FROM games")
