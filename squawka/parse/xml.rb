#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "nokogiri"

require "cgi"

args = ARGV
dir = args[0]

print "Target dir is #{dir}\n"

if (args[1..-1].size==1) and (args[1].include?('*'))
  print "No xml files to process; skipping.\n"
  exit
end

if not(File.directory?(dir))
  print "Target csv directory missing; skipping.\n"
  exit
end

games = CSV.open("#{dir}/games.csv", "w")
teams = CSV.open("#{dir}/teams.csv", "w")
players = CSV.open("#{dir}/players.csv", "w")
possessions = CSV.open("#{dir}/possessions.csv", "w")
periods = CSV.open("#{dir}/periods.csv", "w")
time_slices = CSV.open("#{dir}/time_slices.csv", "w")
team_possessions = CSV.open("#{dir}/team_possessions.csv", "w")
swaps = CSV.open("#{dir}/swaps.csv", "w")
players_in_grounds = CSV.open("#{dir}/players_in_grounds.csv", "w")
ts_players = CSV.open("#{dir}/ts_players.csv", "w")
player_inf_scores = CSV.open("#{dir}/player_inf_scores.csv", "w")

args[1..-1].each do |file|

  file_name = File.basename(file)
  game_id = file_name.split(".")[0]

  #game_id = File.dirname(file).split("/")[-1]
  #league_key = File.dirname(file).split("/")[-2]
  #print "Parsing #{game_id} ...\n"

  begin
    xml = Nokogiri::XML(File.open(file))
  rescue
    next
  end

  xml.search("/squawka").each do |squawka|

    date = squawka.attribute("date")
    time = squawka.attribute("time")
    timezone = squawka.attribute("timezone")
    data_freshness = squawka.attribute("data_freshness")

    xml.search("data_panel").each do |data_panel|

      system = data_panel.search("system").first
      
      headline = system.search("headline").first.inner_text
      refresh_rate = system.search("refresh_rate").first.inner_text
      state = system.search("state").first.inner_text
      show_ingame_rdp = system.search("show_ingame_rdp").first.inner_text

      data_panel.search("game").each do |game|

        name = game.search("name").first.inner_text
        venue = game.search("venue").first.inner_text
        kickoff = game.search("kickoff").first.inner_text
        timeleft = game.search("timeleft").first.inner_text
        competition_name = game.search("competition_name").first.inner_text

        games << [game_id, date, time, timezone, data_freshness,
                  state, headline, refresh_rate, show_ingame_rdp,
                  venue, kickoff, timeleft, competition_name]
      
        game.search("team").each do |team|
        
          team_id = team.attribute("id")
          long_name = team.search("long_name").first.inner_text
          short_name = team.search("short_name").first.inner_text
          logo = team.search("logo").first.inner_text
          shirt_url = team.search("shirt_url").first.inner_text
          club_url = team.search("club_url").first.inner_text
          state = team.search("state").first.inner_text
          team_color = team.search("team_color").first.inner_text

          teams << [game_id, team_id, long_name, short_name, logo, shirt_url,
                    club_url, state, team_color]
        
        end

      end

      data_panel.search("players/player").each do |player|
        
        player_id = player.attribute("id")
        team_id = player.attribute("team_id")
        
        first_name = player.search("first_name").first.inner_text
        last_name = player.search("last_name").first.inner_text
        name = player.search("name").first.inner_text
        surname = player.search("surname").first.inner_text
        team_name = player.search("team_name").first.inner_text
        photo = player.search("photo").first.inner_text
        position = player.search("position").first.inner_text
        dob = player.search("dob").first.inner_text
        weight = player.search("weight").first.inner_text
        height = player.search("height").first.inner_text
        shirt_num = player.search("shirt_num").first.inner_text
        total_influence = player.search("total_influence").first.inner_text
        country = player.search("country").first.inner_text
        profile_url = player.search("profile_url").first.inner_text
        x_loc = player.search("x_loc").first.inner_text
        y_loc = player.search("y_loc").first.inner_text
        state = player.search("state").first.inner_text
        age = player.search("age").first.inner_text
        bmi = player.search("bmi").first.inner_text

        players << [game_id, player_id, team_id,
                    first_name, last_name, name, surname,
                    team_name, photo, position, dob, weight, height,
                    shirt_num, total_influence, country, profile_url,
                    x_loc, y_loc, state, age, bmi]
        
      end

      data_panel.search("possession/period").each do |period|

        period_id = period.attribute("id")

        period.search("play_direction").each do |play_direction|
          team_id = play_direction.attribute("team_id")
          play_direction_text = play_direction.inner_text
          periods << [game_id, period_id, team_id, play_direction_text]
        end

        period.search("time_slice").each do |time_slice|

          time_slice_name = time_slice.attribute("name")
          time_slice_id = time_slice.attribute("id")
          scored_min = time_slice.attribute("scored_min")

          time_slices << [game_id, period_id,
                          time_slice_name, time_slice_id,
                          scored_min]

          time_slice.search("team_possession").each do |team_possession|
            team_id = team_possession.attribute("team_id")
            team_possession_text = team_possession.inner_text
            team_possessions << [game_id, period_id,
                                 time_slice_name, time_slice_id,
                                 scored_min,
                                 team_id, team_possession_text]
          end

          time_slice.search("swap_players").each do |swap_players|

            team_id = swap_players.attribute("team_id")
            min = swap_players.attribute("min")
            minsec = swap_players.attribute("minsec")

            sub_to_player = swap_players.search("sub_to_player").first
            sub_to_player_id = sub_to_player.attribute("player_id")
            sub_to_player_name = sub_to_player.text
            
            player_to_sub = swap_players.search("player_to_sub").first
            player_to_sub_id = player_to_sub.attribute("player_id")
            player_to_sub_name = player_to_sub.text
            
            swaps << [game_id, period_id,
                      time_slice_name, time_slice_id,
                      scored_min,
                      team_id, min, minsec,
                      sub_to_player_id, sub_to_player_name,
                      player_to_sub_id, player_to_sub_name]

          end

          time_slice.search("players_in_ground").each do |players_in_ground|
            injurytime_play = players_in_ground.attribute("injurytime_play")

            players_in_grounds << [game_id, period_id,
                                   time_slice_name, time_slice_id,
                                   scored_min,
                                   injurytime_play]
            
            players_in_ground.search("ts_player").each do |ts_player|
              
              ts_player_id = ts_player.attribute("id")
              team_id = ts_player.attribute("team_id")
              first_name = ts_player.search("first_name").first.text
              player_name = ts_player.search("name").first.text
              team_name = ts_player.search("team_name").first.text
              photo = ts_player.search("photo").first.text
              dob = ts_player.search("dob").first.text
              weight = ts_player.search("weight").first.text
              height = ts_player.search("height").first.text
              shirt_num = ts_player.search("shirt_num").first.text
              total_influence = ts_player.search("total_influence").first.text
              profile_url = ts_player.search("profile_url").first.text
              country = ts_player.search("country").first.text
              position = ts_player.search("position").first.text
              state = ts_player.search("state").first.text
              x_loc = ts_player.search("x_loc").first.text
              y_loc = ts_player.search("y_loc").first.text

              ts_players << [game_id, period_id,
                             time_slice_name, time_slice_id,
                             scored_min,
                             ts_player_id, team_id,
                             first_name, player_name, team_name,
                             photo, dob, weight, height, shirt_num,
                             total_influence, profile_url,
                             country, position, state,
                             x_loc, y_loc]
            end

          end

          time_slice.search("player_inf_score").each do |player_inf_score|

            #<player_inf_score id="411" possession="2.32" attack="0" defense="5.39" goalkeeping="0" injurytime_play="0">7.71</player_inf_score>

            player_inf_score_id = player_inf_score.attribute("id")
            possession = player_inf_score.attribute("possession")
            attack = player_inf_score.attribute("attack")
            defense = player_inf_score.attribute("defense")
            goalkeeping = player_inf_score.attribute("goalkeeping")
            injurytime_play = player_inf_score.attribute("injurytime_play")
            player_inf_score_text = player_inf_score.text

            player_inf_scores << [game_id, period_id,
                                  time_slice_name, time_slice_id,
                                  scored_min,
                                  player_inf_score_id,
                                  possession, attack, defense,
                                  goalkeeping, injurytime_play,
                                  player_inf_score_text]

          end

        end

      end

    end

  end
    
end

#  home = game.search("teams/home").first
#  away = game.search("teams/away").first

#  home_id = home.attribute("id")
#  home_color = home.attribute("color")
#  home_name = home.inner_text

#  away_id = away.attribute("id")
#  away_color = away.attribute("color")
#  away_name = away.inner_text
  
#  row = [game_id, year, league_key,
#         home_id, home_color, home_name,
#         away_id, away_color, away_name]

#  gamecast << row

#  attack_keys = ["key", "jersey", "avgX", "avgY", "posX", "posY",
#                 "left", "middle", "right", "playerId", "teamId", "position"]

=begin
  game.search("attack/entry").each do |attack|

    row = [game_id, year, league_key]

    a = attack.attributes

    attack_keys.each do |key|
      value = a[key].value
      if (value.size==0)
        value = nil
      end
      row += [value]
    end

    h = {}
    attack.children.each do |child|
      h["#{child.name}"] = child.text.strip
    end

    row += [h["cdata-section"]]

    grid = h["grid"]
    heat_map = []

    if not(grid==nil)
      values = grid.split("~")
      flat = []
      values.each { |v| flat << v.to_i }
      (0..21).each do |i|
        heat_map += [flat[(32*i)..(32*i+31)]]
      end
      row += [heat_map.reverse]
    else
      row += [nil]
    end

    attacks << row

  end

  play_keys = ["id", "clock", "addedTime", "period", "startX", "startY",
               "teamId", "goal", "ownGoal", "shootout", "videoId"]

  part_keys = ["pId", "jersey", "startX", "startY", "endX", "endY", "endZ"]

  game.search("shots/play").each do |play|

    row = [game_id, year, league_key]

    a = play.attributes
    play_keys.each do |key|
      value = a[key].value rescue nil
      if not(value==nil) and (value.size==0)
        value = nil
      end
      row += [value]
    end

    id = a["id"].value

    h = {}
    play.children.each do |child|
      h["#{child.name}"] = child.text.strip
    end

    # Am I losing information here?
    # Need to handle this for data fields

    h["shotByText"].encode!("UTF-8", "ISO-8859-1", :invalid => :replace, :undef => :replace, :replace => "")

    row += [h["player"]]
    row += [h["result"]]
    row += [h["topScoreText"]]
    row += [h["shotByText"]]

    parts_xml = play.search("part")
    row += [parts_xml.size]

    shots << row

    parts_xml.each_with_index do |part,i|
      
      row = [game_id, year, league_key, id, i]
      
      a = part.attributes
      part_keys.each do |key|
        value = a[key].value rescue nil
        if not(value==nil) and (value.size==0)
          value = nil
        end
        row += [value]
      end

      h = {}
      part.children.each do |child|
        h["#{child.name}"] = child.text.strip
      end

      row += [h["player"]]
      row += [h["result"]]
      row += [h["resultText"]]

      parts << row

    end

  end
  
end

=end
