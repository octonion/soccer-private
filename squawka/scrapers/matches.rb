#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'
agent.robots = false

league_id = ARGV[0]
season_id = ARGV[1]

games = CSV.read("tsv/games_#{league_id}_#{season_id}.tsv",
                 "r",
                 {:col_sep => "\t",
                  :headers => TRUE})

keys, values = games.first.to_a.transpose

matches = CSV.open("tsv/matches_#{league_id}_#{season_id}.tsv",
                   "w",
                   {:col_sep => "\t"})

matches << keys + ["match_id"]

games.each do |game|
  url = game["match_url"]
  doc = agent.get(url).body
  raw = doc.match(/parseInt(.*)/)[0]
  match_id = raw.gsub("parseInt('","").gsub("')","").to_i
  row = game
  row["match_id"] = match_id
  matches << row
  matches.flush
end
