# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 1) do

  create_table "divisions", :force => true do |t|
    t.column "name",   :string, :limit => 128, :default => "", :null => false
    t.column "league", :string, :limit => 128, :default => "", :null => false
  end

  create_table "games", :force => true do |t|
    t.column "date",          :date,                                      :null => false
    t.column "description",   :string,  :limit => 256, :default => "",    :null => false
    t.column "team_id",       :integer,                                   :null => false
    t.column "reminder_sent", :boolean,                :default => false, :null => false
  end

  add_index "games", ["team_id"], :name => "fk_games_teams"

  create_table "players", :force => true do |t|
    t.column "name",          :string,  :limit => 128, :default => "",    :null => false
    t.column "email_address", :string,  :limit => 256
    t.column "phone_number",  :string,  :limit => 16
    t.column "is_sub",        :boolean,                :default => false, :null => false
    t.column "password",      :string,  :limit => 32
  end

  create_table "players_teams", :id => false, :force => true do |t|
    t.column "player_id", :integer, :null => false
    t.column "team_id",   :integer
  end

  add_index "players_teams", ["player_id"], :name => "fk_players_players_teams"
  add_index "players_teams", ["team_id"], :name => "fk_teams_players_teams"

  create_table "teams", :force => true do |t|
    t.column "name",        :string,  :limit => 128, :default => "", :null => false
    t.column "division_id", :integer,                                :null => false
  end

  add_index "teams", ["division_id"], :name => "fk_teams_divisions"
end
