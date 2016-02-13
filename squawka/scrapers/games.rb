#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'
agent.robots = false

league_id = ARGV[0]
season_id = ARGV[1]

#http://www.squawka.com/match-results?ctl=8_s2015&pg=1

games = CSV.open("tsv/games_#{league_id}_#{season_id}.tsv",
                 "w",
                 {:col_sep => "\t"})

games << ["season_id", "league_id",
          "home_team_id", "home_team_name", "home_team_url",
          "away_team_id", "away_team_name", "away_team_url",
          "result", "home_goals", "away_goals",
          "league_name",
          "game_date",
          "match_url"]

base_url = "http://www.squawka.com/match-results"

#?ctl=#{league_id}_s#{season_id}"
#doc = Nokogiri::HTML(agent.get(league_url).body)
#?ctl=#{league_id}_s#{season_id}"

doc = agent.get(base_url)

league_url = "http://www.squawka.com/match-results?ctl=#{league_id}_s#{season_id}"
doc = Nokogiri::HTML(agent.get(league_url).body)

#form = doc.forms[1]
#form["ctl"] = league_id
#form["season"] = season_id

pl_path = '//*[@id="sq-pagination"]/span[2]/a'

pn = 1
doc.xpath(pl_path).each do |pl|
  pl_url = pl.attribute("href").text.strip rescue nil
  pn = [pn, pl_url.split("=")[1].to_i].max
end

game_path ='//tr[@class="match-today"]' #/td[@class="match-centre"]/a'

(1..pn).each do |n|

  if (n>1)
    page_url = "http://www.squawka.com/match-results?ctl=#{league_id}_s#{season_id}&pg=#{n}"
    doc = Nokogiri::HTML(agent.get(page_url).body)
  end
  
  doc.xpath(game_path).each do |game|

    row = [season_id, league_id]
    teams = game.xpath('td[@class="match-teams"]').first
    teams.xpath('table/tr/td').each_with_index do |team,i|
      case i
      when 0,2
        a = team.xpath('a').first
        team_url = a.attribute("href").text.strip rescue nil
        team_id = team_url.split("/")[-2] rescue nil
        team_name = a.xpath('span').first.text.strip rescue nil
        row += [team_id, team_name, team_url]
      end
    end
    
    result = game.xpath('td[@class="match-channel"]').first
    result = result.text.strip rescue nil
    scores = result.split("-") rescue nil
    home_score = scores[0].to_i rescue nil
    away_score = scores[1].to_i rescue nil
    row += [result, home_score, away_score]
    
    league = game.xpath('td[@class="match-league"]').first
    league = league.text.strip rescue nil
    row += [league]
    
    kick_off = game.xpath('td[@class="match-kick-off"]').first
    kick_off = kick_off.text.strip rescue nil
    row += [kick_off]
    
    centre = game.xpath('td[@class="match-centre"]/a').first
    game_url = centre.attribute("href").text rescue nil
    row += [game_url]
    
    games << row

  end
    
end
