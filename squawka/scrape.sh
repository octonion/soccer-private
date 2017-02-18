#!/bin/bash

league_id=$1
year=$2

./scrapers/games.rb $league_id $year
./scrapers/matches.rb $league_id $year
./scrapers/xml.rb $league_id $year
