#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

leagues_url = "https://www.squawka.com/match-results"

leagues = CSV.open("tsv/leagues.tsv",
                   "w",
                   {:col_sep => "\t"})

leagues << ["league_id", "league_name"]

league_path = '//*[@id="league-filter-list"]/optgroup[1]/option'

doc = Nokogiri::HTML(agent.get(leagues_url).body)

doc.xpath(league_path).each do |league|
  league_id = league.attribute("value").text
  league_name = league.inner_text.strip
  leagues << [league_id, league_name]
end
