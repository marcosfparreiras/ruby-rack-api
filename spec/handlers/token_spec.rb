require_relative '../../src/handlers/token'

describe 'Token' do
  let(:token_id) { 'mytokenid' }
  let(:user_cpf) { 12341234 }
  let(:account_number) { 333 }

  let(:account) do
    double('account',
      number: account_number,
      current_balance: 100
    )
  end

  let(:user) do
    double('user',
      cpf: user_cpf,
      account: account
    )
  end

  let(:token) { double('token', id: token_id, user: user) }
  subject { Handlers::Token.new(token_id) }

  describe '#initialize' do
    context 'when token does not exist' do
      before do
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(nil)
      end

      it 'raises 404 not found error' do
        expect { Handlers::Token.new(token_id) }.to raise_error(CustomErrors::NotFound)
      end
    end
  end

  describe '#withdraw' do
    context 'when does not have enought balance' do
      before do
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(token)
        allow(Handlers::Token).to receive(:new).and_return(subject)
        allow(subject).to receive(:has_enough_balance?).and_return(false)
      end

      it 'raises 403 forbiden error' do
        params = { 'amount' => 200 }
        expect { subject.withdraw(params) }.to raise_error(CustomErrors::Forbiden)
      end
    end

    context 'when does have enought balance' do
      before do
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(token)
        allow(Handlers::Token).to receive(:new).and_return(subject)
        allow(subject).to receive(:has_enough_balance?).and_return(true)
        allow(subject).to receive(:update_account_balance)
        allow(subject).to receive(:create_operation)
        allow(subject).to receive(:token_account).and_return(account)
        allow(account).to receive(:values).and_return(key1: 'value1')
      end

      it 'updates account balance' do
        params = { 'amount' => '50' }
        expect(subject).to receive(:update_account_balance).with(account, -50)
        subject.withdraw(params)
      end

      it 'creates operation' do
        params = { 'amount' => '50' }
        expect(subject).to receive(:create_operation).with(-50, 'withdraw')
        subject.withdraw(params)
      end
    end
  end

  describe '#deposit' do
    context 'when account does not exist' do
      let(:not_existing_account) { '999' }
      before do
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(token)
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_account).and_return(nil)
        allow(Handlers::Token).to receive(:new).and_return(subject)
      end

      it 'raises 403 forbiden error' do
        params = { 'amount' => 200, 'account' => not_existing_account }
        expect { subject.deposit(params) }.to raise_error(CustomErrors::Forbiden)
      end
    end

    context 'when account exists' do
      let(:account_to_deposit) { double('account to deposit') }

      before do
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(token)
        allow_any_instance_of(Handlers::Token).to receive(:retrieve_account).and_return(account_to_deposit)
        allow(Handlers::Token).to receive(:new).and_return(subject)
        allow(subject).to receive(:update_account_balance)
        allow(subject).to receive(:create_operation)
        allow(subject).to receive(:token_account).and_return(account)
        allow(account_to_deposit).to receive(:values).and_return(key1: 'value1')
      end

      it 'updates account balance' do
        params = { 'amount' => '100', 'account' => '88' }
        expect(subject).to receive(:update_account_balance).with(account_to_deposit, 100)
        subject.deposit(params)
      end

      it 'creates operation' do
        params = { 'amount' => '100', 'account' => '88' }
        expect(subject).to receive(:create_operation).with(100, 'deposit')
        subject.deposit(params)
      end
    end
  end

  describe '#operations' do
    before do
      allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(nil)
    end
    before do
      allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(token)
      allow(Handlers::Token).to receive(:new).and_return(subject)
      allow(subject).to receive(:account_operations)
    end

    it 'returns operations filtered by date' do
      params = { 'from' => '2017-01-01', 'to' => '2017-01-15', 'type' => 'deposit' }
      expect(subject).to receive(:account_operations).with(params['from'], params['to'], params['type'])
      subject.operations(params)
    end
  end

  describe '#signout' do
    before do
      allow_any_instance_of(Handlers::Token).to receive(:retrieve_token).and_return(token)
      allow(Handlers::Token).to receive(:new).and_return(subject)
      allow(token).to receive(:destroy)
    end

    it 'deletes token from database' do
      expect(token).to receive(:destroy)
      subject.signout
    end
  end
end
