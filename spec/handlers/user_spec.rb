require_relative '../../src/handlers/user'

describe 'User' do
  describe '#authenticate' do
    context 'when user does not exist' do
      before do
        allow_any_instance_of(Handlers::User).to receive(:retrieve_user).and_return(nil)
      end

      it 'raises 404 not found error' do
        expect { Handlers::User.new(666) }.to raise_error(CustomErrors::NotFound)
      end
    end

    context 'when user exists' do
      subject { Handlers::User.new(666) }
      let(:user) { double('user', pin: pin, cpf: 111) }

      context 'when pin does not match' do
        let(:pin) { Digest::MD5.hexdigest('wrongpin') }
        before do
          allow_any_instance_of(Handlers::User).to receive(:retrieve_user).and_return(user)
          allow(Handlers::User).to receive(:new).and_return(subject)
        end

        it 'raises 401 unauthorized error' do
          params = { 'pin' => 'mypin' }
          expect { subject.authenticate(params) }.to raise_error(CustomErrors::Unauthorized)
        end
      end

      context 'when pin matches' do
        let(:pin) { Digest::MD5.hexdigest('mypin') }
        let(:token_number) { 'blabla123' }
        let(:fake_token) { double('token', id: token_number)}

        before do
          allow_any_instance_of(Handlers::User).to receive(:retrieve_user).and_return(user)
          allow(Handlers::User).to receive(:new).and_return(subject)
          allow(subject).to receive(:create_token).and_return(fake_token)
        end

        it 'creates a new token and return success status' do
          params = { 'pin' => 'mypin' }
          expect(subject.authenticate(params)[0]).to eq(201)
        end
      end
    end
  end
end
