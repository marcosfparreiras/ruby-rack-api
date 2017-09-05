require 'sequel'
require 'pg'

class DatabaseConnection
  class << self
    def connect
      Sequel.connect(
        adapter: ENV['DB_ADAPTER'],
        user: ENV['DB_USER'],
        password: ENV['DB_PASS'],
        host: ENV['DB_HOST']
      )
    end

    def create_tables
      create_accounts_table
      create_users_table
      create_operations_table
      create_tokens_table
    end

    private

    def create_accounts_table
      connect.create_table? :accounts do
        Integer :number, primary_key: true
        Float :current_balance, default: 0.0, allow_null: false
      end
    end

    def create_users_table
      connect.create_table? :users do
        Integer :cpf, primary_key: true
        foreign_key :account_number, :accounts
        String :pin, allow_null: false
        String :name, allow_null: false
      end
    end

    def create_operations_table
      connect.create_table? :operations do
        primary_key :id
        foreign_key :account_number, :accounts
        String :type, allow_null: false
        Float :amount, allow_null: false
      end
    end

    def create_tokens_table
      connect.create_table? :tokens do
        String :id, primary_key: true
        foreign_key :user_cpf, :users
      end
    end
  end
end

