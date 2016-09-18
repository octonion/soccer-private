#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.113 Safari/537.36'
agent.robots = false

seasons_url = "https://www.squawka.com/match-results"

seasons = CSV.open("tsv/seasons.tsv",
                   "w",
                   {:col_sep => "\t"})

seasons << ["season_id", "season_name"]

season_path = '//*[@id="league-season-list"]/option'

begin
  doc = Nokogiri::HTML(agent.get(seasons_url).body)
rescue
  print "Error ...\n"
  exit
end

doc.xpath(season_path).each do |season|
  season_id = season.attribute("value").text
  season_name = season.inner_text.split(" ")[1]
  seasons << [season_id, season_name]
end
