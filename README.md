# About it

This is a Rack API built to communicate with an ATM machine.

# Routes - RESTRINGIR MÉTODOS

Authenticate user
```
POST users/:id/authenticate
params: pin
return: { token: {token_id} }
```

Operate a deposit
```
POST tokens/:id/deposit
params: account_number, amount
return:
```

Operate a withdraw
```
POST tokens/:id/withdraw
params: amount
return:
```

List operations
```
GET users/:id/operations
params: from, to
return: { token: {token_id} }
```

# How to run it

TO DO
