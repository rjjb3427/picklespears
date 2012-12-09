#!/usr/bin/env ruby

require 'picklespears/test/unit'

class TestPickleSpears < PickleSpears::Test::Unit
  def test_homepage
    get '/'
    assert_match( /<title>Teamvite/, last_response.body )
  end

  def test_browse
    league = League.create_test(name: 'Women')
    div = Division.create_test(league_id: league.id)

    team = Team.create_test( :division => div, :name => 'Barcelona' )
    Game.create_test( :team_id => team.id, :date => Date.today + 1 )

    get '/browse', league_id: league.id
    assert_match(/<title>Teamvite - browsing league: Women<\/title>/, last_response.body)
    assert_match(/Barcelona/, last_response.body, 'do we have at least one team')
  end

  def test_team_home
    team = Team.create_test( :name => 'test team' )
    get '/team', :team_id => team.id
    assert_match /Upcoming Games/, last_response.body, 'upcoming games'
  end

  def test_search
    league = League.create_test(name: 'manly men')
    div = Division.create_test(league_id: league.id)
    found_team = Team.create_test(:name => 'THE HARPOON', :division_id => div.id)
    found_team2 = Team.create_test(:name => 'THE AHAS', :division_id => div.id)
    skipped_team = Team.create_test(:name => 'THE HBRPO', :division_id => div.id)

    teams = Team.filter(:name.like '%HA%').order(:name.asc).all
    get '/team/search', :team => 'Ha'
    [ found_team, found_team2 ].each do |team|
      assert_match /team_id=#{team.id}/, last_response.body, "team #{team.id} is found"
    end

    get '/team/search', :team => 'Harpoon'
    assert_equal "http://example.org/team?team_id=#{found_team.id}", last_response.location
  end

  def test_stylesheet
    get '/stylesheet.css'
    assert_match /division/, last_response.body 
  end

  def test_not_signed_in_by_default
    get '/'
    assert_match /login/, last_response.body
  end
end
