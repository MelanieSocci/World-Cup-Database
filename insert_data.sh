#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Vaciar las tablas
$PSQL "TRUNCATE games, teams RESTART IDENTITY"

# Leer el CSV línea por línea
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Insertar equipo ganador si no existe
    if [[ -z $($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
    fi

    # Insertar equipo oponente si no existe
    if [[ -z $($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
    fi
  fi
done

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Saltar encabezado
  if [[ $YEAR != "year" ]]
  then
    # Insertar equipos únicos
    for TEAM in "$WINNER" "$OPPONENT"
    do
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      if [[ -z $TEAM_ID ]]
      then
        $PSQL "INSERT INTO teams(name) VALUES('$TEAM')"
      fi
    done

    # Obtener los IDs de los equipos
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insertar el partido en la tabla games
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
  fi
done