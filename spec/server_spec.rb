require_relative '../src/server'
require_relative '../src/handlers/user'
require_relative '../src/handlers/token'

describe 'AtmServer' do
  include Rack::Test::Methods

  def app
    AtmServer
  end

  let(:users_handler) { double('users_handler') }
  let(:token_handler) { double('token_handler') }
  let(:fake_200) { [200, {}, ['body']] }

  describe 'GET /' do
    it 'request to root returns 404' do
      get '/'
      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET /ping' do
    it 'request to ping returns pong' do
      get '/ping'
      expect(last_response.body).to eq('pong')
    end
  end

  describe 'POST /users/:id/authenticate' do
    before do
      allow(Handlers::User).to receive(:new).and_return(users_handler)
      allow(users_handler).to receive(:authenticate).and_return(fake_200)
    end

    it 'initializes Handlers::User with the user id' do
      expect(Handlers::User).to receive(:new).with('666')
      post '/users/666/authenticate/?pin=123'
    end

    it 'calls user handler authenticate with env params' do
      params = { 'pin' => '123' }
      expect(users_handler).to receive(:authenticate).with(params)
      post '/users/666/authenticate/?pin=123'
    end
  end

  describe 'GET /tokens/:id/operations' do
    before do
      allow(Handlers::Token).to receive(:new).and_return(token_handler)
      allow(token_handler).to receive(:operations).and_return(fake_200)
    end

    it 'initializes Handlers::Token with the token id' do
      expect(Handlers::Token).to receive(:new).with('myt0k3n')
      get '/tokens/myt0k3n/operations/?from=2010-01-01&to=2010-01-20'
    end

    it 'calls token handler operations with env params' do
      params = { 'from' => '2010-01-01', 'to' => '2010-01-20' }
      expect(token_handler).to receive(:operations).with(params)
      get '/tokens/myt0k3n/operations/?from=2010-01-01&to=2010-01-20'
    end
  end

  describe 'POST /tokens/:id/withdraw' do
    before do
      allow(Handlers::Token).to receive(:new).and_return(token_handler)
      allow(token_handler).to receive(:withdraw).and_return(fake_200)
    end

    it 'initializes Handlers::Token with the token id' do
      expect(Handlers::Token).to receive(:new).with('myt0k3n')
      post '/tokens/myt0k3n/withdraw/?amount=100'
    end

    it 'calls token handler withdraw with env params' do
      params = { 'amount' => '100' }
      expect(token_handler).to receive(:withdraw).with(params)
      post '/tokens/myt0k3n/withdraw?amount=100'
    end
  end

  describe 'POST /tokens/:id/deposit' do
    before do
      allow(Handlers::Token).to receive(:new).and_return(token_handler)
      allow(token_handler).to receive(:deposit).and_return(fake_200)
    end

    it 'initializes Handlers::Token with the token id' do
      expect(Handlers::Token).to receive(:new).with('myt0k3n')
      post '/tokens/myt0k3n/deposit/?account=123&amount=100'
    end

    it 'calls token handler deposit with env params' do
      params = { 'account' => '123', 'amount' => '100' }
      expect(token_handler).to receive(:deposit).with(params)
      post '/tokens/myt0k3n/deposit?account=123&amount=100'
    end
  end
end
