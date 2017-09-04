require 'json'

class User
  def authenticate(params)
    [200, {"Content-Type" => "text/plain"}, ['authenticate']]
  end

  def deposit(params)
    [200, {"Content-Type" => "text/plain"}, ['deposit']]
  end

  def withdraw(params)
    [200, {"Content-Type" => "text/plain"}, ['withdraw']]
  end
end
