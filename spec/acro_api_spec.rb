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
      response.should == {uuid: response[:uuid],
                          round_number: 1,
                          phase: Game::PHASE_PLAY,
                          phase_ends_at: nil,
                          acro: response[:acro],
                          players: [],
                          entries: []}
    end
  end

  context 'player namespace' do
    before(:each) do
      @@game = nil
    end
    it "should reject the player if doesn't have name" do
      post 'v1/player', nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
      last_response.status.should == 400
      response = json_parse(last_response.body)
      response.should == {:error => 'name is missing'}
    end

    describe 'player tests' do
      before(:each) do
        @name   = 'Player'
        post 'v1/player', {name: @name}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
        @player = json_parse(last_response.body)
      end
      it 'should join the game' do
        last_response.status.should == 201
        response = json_parse(last_response.body)
        response.should == {uuid: response[:uuid],
                            name: @name}
      end


      it 'should join the game with a different name as the required' do
        post 'v1/player', {name: @name}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
        last_response.status.should == 201
        response = json_parse(last_response.body)
        response.should == {uuid:           response[:uuid],
                            name:           "#{@name}1",
                            requested_name: @name}
      end

      it 'should get player info' do
        get "v1/player/#{@player[:uuid]}", nil, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
        last_response.status.should == 200
        response = json_parse(last_response.body)
        response.should == {uuid:   @player[:uuid],
                            name:   @player[:name],
                            score:  0}
      end

      describe 'with entry added' do

        before(:each) do
          @acro = 'TZFGU'
          @expansion = 'Traditionally, Zombies Feel Great Undead'
        end

        it 'should submit an entry' do
          post "v1/player/#{@player[:uuid]}/entry", {acro: @acro, expansion: @expansion}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
          last_response.status.should == 201
          response = json_parse(last_response.body)
          response.should == {uuid:         response[:uuid],
                              acro:         @acro,
                              expansion:    @expansion,
                              received_at:  response[:received_at],
                              accepted:     true}
        end

        it 'should submit an bad entry' do
          expansion = 'I think Zombies Feel Great Undead'

          post "v1/player/#{@player[:uuid]}/entry", {acro: @acro, expansion: expansion}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
          #last_response.status.should == 200
          response = json_parse(last_response.body)
          response.should == {uuid:         response[:uuid],
                              acro:         @acro,
                              expansion:    expansion,
                              received_at:  response[:received_at],
                              accepted:     false,
                              error:        'Expansion not valid for acronym'}
        end

        describe 'with entry added' do

          before(:each) do
            post "v1/player/#{@player[:uuid]}/entry", {acro: @acro, expansion: @expansion}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
            @entry = json_parse(last_response.body)
            Game.tick! # move to vote phase
          end

          it 'should submit a vote' do
            post "v1/player/#{@player[:uuid]}/vote", {entry: @entry[:uuid]}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
            last_response.status.should == 201
            response = json_parse(last_response.body)
            response.should == {received_at:  response[:received_at],
                                uuid:         response[:uuid],
                                player_id:    response[:player_id],
                                entry:        response[:entry],
                                accepted:     true}
          end

          it 'should submit a vote' do
            Game.tick! # move to results phase

            post "v1/player/#{@player[:uuid]}/vote", {entry: @entry[:uuid]}, { 'HTTP_ACCEPT' => 'application/vnd.acme-v2+json' }
            #last_response.status.should == 201
            response = json_parse(last_response.body)
            response.should == {received_at:  response[:received_at],
                                uuid:         response[:uuid],
                                player_id:    response[:player_id],
                                entry:        response[:entry],
                                accepted:     false,
                                error:        'Vote received too late'}
          end
        end
      end
    end
  end

end