#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'
agent.robots = false

league_id = ARGV[0].to_i
season_id = ARGV[1].to_i

matches = CSV.read("tsv/matches_#{league_id}_#{season_id}.tsv",
                   "r",
                   {:col_sep => "\t",
                    :headers => TRUE})

row = matches.first
match_url = row["match_url"]

league_key = match_url.split("/")[2].split(".")[0].gsub("-","")

matches.each do |match|
  match_id = match["match_id"].to_i
  if (match_id==0)
    next
  end

  file_name = "xml/#{match_id}.xml"
  if (File.file?(file_name))
    #next
  end

  url = "http://s3-irl-#{league_key}.squawka.com/dp/ingame/#{match_id}"
  begin
    doc = agent.get(url).body
  rescue
    print "Couldn't find #{match_id}\n"
    next
  end
  xml = Nokogiri::XML(doc)
  File.open(file_name, "w") do |file|
    file << xml
  end
end
