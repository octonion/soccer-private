#!/usr/bin/env ruby

require 'json'
require 'mechanize'

#agent = Mechanize.new{ |agent| agent.history.max_size=0 }
#agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
#agent.robots = false

br = Mechanize.Browser()
br.set_handle_robots(False)
exit

base="https://www.whoscored.com/StatisticsFeed/1/GetPlayerStatistics?category=summary&subcategory=all&statsAccumulationType=0&isCurrent=true&playerId=&teamIds=&matchId=&stageId=&tournamentOptions=2,3,4,5,22&sortBy=Rating&sortAscending=&age=&ageComparisonType=&appearances=&appearancesComparisonType=&field=Overall&nationality=&positionOptions=&timeOfTheGameEnd=&timeOfTheGameStart=&isMinApp=true&page=&includeZeroValues=&numberOfPlayersToPick=10"
pages = ARGV[0].to_i

dir = "json"

(1..pages).each do |page|

  url = base #+"#{page}"

  body = agent.get(url).body
  
  File.open("#{dir}/page_#{page}.json", "w") do |f|
    f.write(body.to_json)
  end

end
