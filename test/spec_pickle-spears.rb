#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/spec'
require 'mocha'
require 'pickle-spears'

context 'PickleSpears' do
  before(:each) do
    require 'pickle-spears'
  end

  specify "post from sign in sets cookie" do
    post_it '/sign_in', 'email=ben.prew@gmail.com'
    assert include?('Set-Cookie')
  end

  specify "post from sign in redirects to player hompage" do
    post_it '/sign_in', 'email_address=ben.prew@gmail.com'
    assert_equal '/player?id=4', @response.location
  end

  specify "player page" do
    get_it '/player?id=4'

    assert_match /teams:/i, @response.body
    assert_match /join a team/i, @response.body
    assert_match /upcoming games/i, @response.body
  end

  specify "show a default page" do
    get_it '/'
    assert ok?
  end
end
