require_relative 'db/create_tables'
require_relative 'src/models/operation'
require_relative 'src/models/user'
require_relative 'src/models/account'
require_relative 'src/server'

run AtmServer
