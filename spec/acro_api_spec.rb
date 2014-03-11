require_relative 'spec_helper.rb'

describe AcroApi do
  include Rack::Test::Methods
  include JsonHelpers

  def app
    AcroApi.new
  end

  context 'game namespace' do

    it 'should return code 400 without name' do
      get 'v1/game', nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 400
      response = json_parse(last_response.body)
      response.should == {:error => 'name is missing'}
    end

    it 'should return game state for a game' do
      get 'v1/game', {name: 'test_game'}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 200
      response = json_parse(last_response.body)
      # Is not responsibility of the api tests to check if a game has a valid uuid.
      # I only need to be sure that we have a uuid for the game.
      # When we have full unit test we can move next two lines to model test.
      response[:uuid].should_not be_nil
      response[:uuid].should_not be_empty
      response[:acro].should_not be_nil
      response[:acro].should_not be_empty
      response.should == {uuid: response[:uuid], round_number: 1, phase: Game::PHASE_PLAY, phase_ends_at: nil, acro: response[:acro], players: [], winner: nil}
    end
  end

  context 'player namespace' do
    it "should reject the player if doesn't have name" do
      post 'v1/player', nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 400
      response = json_parse(last_response.body)
      response.should == {:error => 'name is missing'}
    end

    it 'should join the game' do
      name = 'Player'
      post 'v1/player', {name: name}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      response = json_parse(last_response.body)
      response.should == {uuid: response[:uuid], name: name}
    end

    it 'should join the game with a different name as the required' do
      name = 'Player'
      post 'v1/player', {name: name}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      response = json_parse(last_response.body)
      response.should == {uuid: response[:uuid], name: "#{name}1", requested_name: name}
    end

    it 'should get player info' do
      name = 'Player'
      post 'v1/player', {name: name}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      player = json_parse(last_response.body)

      get "v1/player/#{player[:uuid]}", nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 200
      response = json_parse(last_response.body)
      response.should == {uuid: player[:uuid], name: player[:name], requested_name: player[:requested_name], score: 0}
    end

    it 'should submit and entry' do
      post 'v1/player/23432/entry', {acro: 'TZFGU', expansion: 'Traditionally, Zombies Feel Great Undead'}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      json_parse(last_response.body).should == nil
    end

    it 'should submit a vote' do
      post 'v1/player/23432/vote', {entry: 'Traditionally, Zombies Feel Great Undead'}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 201
      json_parse(last_response.body).should == nil
    end
  end

end