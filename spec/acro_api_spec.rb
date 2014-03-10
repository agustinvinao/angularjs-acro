require_relative 'spec_helper.rb'

describe AcroApi do
  include Rack::Test::Methods

  def app
    AcroApi.new
  end

  context 'game namespace' do
    it 'should return game state' do
      get 'v1/game', nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 200
      last_response.body.should == 'null'
    end

    it 'should return game state for a player' do
      get 'v1/game', {name: 'test_game'}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 200
      last_response.body.should == 'null'
    end
  end

  context 'player namespace' do
    it 'should join the game' do
      post 'v1/player', nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      last_response.body.should == 'null'
    end

    it 'should get player info' do
      get 'v1/player/23432', nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 200
      last_response.body.should == 'null'
    end

    it 'should submit and entry' do
      post 'v1/player/23432/entry', {acro: 'TZFGU', expansion: 'Traditionally, Zombies Feel Great Undead'}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      last_response.body.should == 'null'
    end

    it 'should submit a vote' do
      post 'v1/player/23432/vote', {entry: 'Traditionally, Zombies Feel Great Undead'}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      last_response.body.should == 'null'
    end
  end

end