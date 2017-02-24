#!/usr/bin/env ruby
# coding: utf-8

require 'json'
require 'csv'

players = CSV.open("csv/players.csv", "w")

ARGV.each_with_index do |page,i|

  file = File.read(page)
  hash = JSON.parse(file)

  hash["playerTableStats"].each_with_index do |player,j|
    if (i==0) and (j==0)
      players << player.keys
    end
    players << player.values
  end

end
