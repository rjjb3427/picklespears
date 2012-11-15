#!/usr/local/ruby/bin/ruby

require 'bundler/setup'
require 'pony'
require 'sinatra'
require 'sinatra/config_file'
require 'haml'
require 'sass'
require 'time'
require 'rack-flash'
require 'bcrypt'
require 'digest'

config_file 'config/config.yml'

class PickleSpears < Sinatra::Application
  set :haml, :ugly => true, :format => :html5


  enable :sessions
  # Must be done after sessions
  require 'rack/openid'
  use Rack::OpenID
  use Rack::Flash, :accessorize => [:errors, :messages]

  DATE_FORMAT='%a %b %e %I:%M %p'

  configure :production do
    set :clean_trace, true
    require 'newrelic_rpm'
  end

  before do
    if session[:player_id]
      @player = Player[session[:player_id]]
      @name = @player.name
    end
  end

  get '/schedule' do

  end

  get '/' do
    @teams = []
    haml :index, layout: false
  end

  get '/browse' do
    @divisions = Division.filter(:league => params[:league]).order(:name.asc).all
    @league = params[:league]
    haml :browse
  end

  get '/stylesheet.css' do
    response['Content-Type'] = 'text/css'
    sass :stylesheet
  end

  post '/players_team/delete' do
    team = Team[params[:team_id]]
    team.remove_player(@player)
    flash[:messages] = "You have successfully left #{team.name}"
    redirect '/player'
  end

  # Meant to be called via ajax
  get '/game/attending_status' do
    @player.set_attending_status_for_game(Game[params[:game_id]], params[:status])
    "Status #{params[:status]} recorded"
  end

  get '/send_game_reminders' do
    output = ''
    Team.all.each do |team|
      next_game = team.next_game()
      output += "\n<br/> working on team #{team.name} ..."

      # skip if more then 4 days away
      if !next_game || next_game.date > (Date.today + 4).to_time || next_game.reminder_sent
        output += "no upcoming unreminded games"
        next
      end

      output += "sending email about #{next_game.description}"

      next_game.reminder_sent = true
      next_game.save

      team.players.each do |player|
        next unless (player.email_address and player.email_address.match(/@/))

        send_email(
          :to      => player.email_address,
          :subject => "Next Game: #{next_game.date.strftime(DATE_FORMAT)} #{next_game.description} ",
          :body    => haml(:reminder, :layout => false, :locals => { :player => player, :game => next_game }),
          :content_type => 'text/html',
        )

      end
    end
    template :output do
      output
    end
    haml :output
  end
end

helpers do

  def title(title=nil)
    @title ||= ''
    @title = title unless title.nil?
    @title
  end

  def url_for(url, args)
    return "#{url}?" + (args.map { |key, val| "#{key}=#{URI.escape(val.to_s)}"}).join("&")
  end

  def status_for_game(player, game)
    return '' unless player && game && player.is_on_team?(game.team)
    pg = PlayersGame.first(:player_id => player.id, :game_id => game.id)

    if pg
      return %{<div>Going: <strong>#{pg.status}</strong> <a href="#" onclick="document.getElementById('status_#{game.id}').style.display = 'block'">[change]</a>} + partial(:attending_status, locals: { game: game }) + "</div>"
    else
      return partial :attending_status, locals: { game: game }
    end
  end

  def send_email(options)
    message = {
      from: 'team@teamvite.com',
      via: :smtp,
      via_options: {
        address: 'smtp.sendgrid.net',
        port: '587',
        domain: 'heroku.com',
        user_name: ENV['SENDGRID_USERNAME'],
        password: ENV['SENDGRID_PASSWORD'],
        authentication: :plain,
        enable_starttls_auto: true
      }
    }.merge(options)

    if production?
      Pony.mail(message)
    else
      p message
    end
  end

  def partial(page, variables={})
    haml ('partials/' + page.to_s).to_sym, { layout: false }.merge(variables)
  end
end

require_relative 'routes/init'
require_relative 'models/init'
