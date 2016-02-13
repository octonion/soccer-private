#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'
agent.robots = false

league_id = ARGV[0]
season_id = ARGV[1]

matches = CSV.open("tsv/matches_#{league_id}_#{season_id}.tsv",
                   "r",
                   {:col_sep => "\t",
                    :headers => TRUE})

matches.each do |match|
  match_id = match["match_id"]
  url = "http://s3-irl-epl.squawka.com/dp/ingame/#{match_id}"
  doc = agent.get(url).body
  xml = Nokogiri::XML(doc)
  File.open("xml/#{match_id}.xml", "w") do |file|
    file << xml
  end
end
