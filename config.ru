require_relative 'src/lib/database_connection'
DatabaseConnection.create_tables

require_relative 'src/models/operation'
require_relative 'src/models/user'
require_relative 'src/models/account'
require_relative 'src/models/token'


require_relative 'src/handlers/user'
require_relative 'src/handlers/token'

require_relative 'src/server'

run AtmServer
