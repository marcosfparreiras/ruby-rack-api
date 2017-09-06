# About ths project

This is a REST API built using plain Ruby + Rack to communicate with an ATM machine.

# Some implementation choices

### API response

In order to follow good pratices for an API, a few custom errors handlers were created so the server can return the proper status code for each situation. These status code are:
- 401 Unauthorized: used when there is some error with authentication. In this API, this status code is got when the users tries to log in with the wrong PIN.
- 403 Forbiden: used when some process is not allowed. In this API, this status code is got, for example, when the user tries to withdraw a value greater then the account balance.
- 404 Not Found: used when som resource is not found. In this API, it was used for invalid routes and invalid resources (not existing user or token, depending on the route).

When there is a success, the status code received is the 200 OK, used for general porpose.

### Endpoints choices

Although there more resources (tokens, users, accounts, opperations), the API behavior follows only two of them: **User** and **Token**. In order to use this API, the user needs to login with its CPF and PIN. Once it's done, the API will retrieve a unique token ID. All the following operation should be done based on this Token, so this will be the main resource in the API. This is why all the routes has *users* or *tokens* as namespace. Thus a natural flow for this API would be:
1. User signs in with CPF and PIN. API retrives token_id;
2. Operate over token_id (withdraws, deposits, list operation) as many times as user wants;
3. At the end of the user operation, logs out.

In order to follow the REST design, the routes follow the pattern:
-  `/namespace/action` when there is not a identifier for the resource
-  `/namespace/id/action` when there is a identifier for the resource

The routes created are the following ones:

Authenticate user
```
POST users/:id/authenticate
params: pin
return: { data: { token: <token_id> } }
```

---
Operate a deposit
```
POST tokens/:id/deposit
params: account_number, amount
return: { data: <token_account> }
```

---
Operate a withdraw
```
POST tokens/:id/withdraw
params: amount
return: { data: <param_account> }
```

---
List operations
```
GET tokens/:id/operations
params: from, to, type
return: { data: [<operations] }
```

---
Signout
```
DELETE tokens/:id
params:
return: { data: { token: <token_id> } }
```

# Some advantages and disadvantage

1. As the API is specif for the ATM, there is no way to use to create users and accounts. The advantage of it is that the API has a small and focused responsability. The disadvantage is that it restricts our use (we would have to have another resource to creat these users and accounts).

2. Another advantage of this API is that is handles requests and returns specific HTTP status code, what allow as to understand better each request. As it doesn't meant to run for real (at least for now), only the most important status code were added to the responses (what is also a disadvantage).

3. As the API follows a REST API pattern, the porpose for each route is really easy to understand (once we have some experience with it).

4. A limitation over one endpoint is that the tokens are not deleted by the backend. The ATM machine is responsable for handling it, since it's its responsability to know when to open a connection and guarantee that the it will be closed.

5. One good advantage is that the code is covered by specs (unit tests), what is a good documentation itself. It turns easier for someone to read its specs output and understand what it does and how it does and, of course, gives us confidence to make changes and refactor the code without breaking it. An disadvantage is that there aren't any integration tests (at least for now).

6. Another advantage is that the database used is Postgres, a really robust database.

7. A **HUGE** advatange is that the project was built using Docker, what allow us to have it set up quickly on a local machine or even in production. As the API refers to a container itself, it can be **scaled** appart from the database (#goMicroServices). As the database is another container, it can be easily scaled as well (\o/)

# How to run it

The project was built over Docker. So all you need to execute it is to install [Docker](https://docs.docker.com/engine/installation/) and [Docker Compose](https://docs.docker.com/compose/install/)

Once you have it installed, just follow these steps:

1. Build the image:
```
docker-compose build
```
It might take a while, since you will have to download the base image

---
2. Run the Specs:
```
docker-compose run web bundle exec rspec
```
The RSpec output will be printed on your terminal

----
3. Run the database seed:
```
docker-compose run web bundle exec ruby db/seed.db
```
As the goal of this API is to allow the user to operate over its account, there is no endpoit to create users or accounts. So the script `db/seed.db` was built to initialize the database with a few data so this API can be used.

---
4. Run the server:
```
docker-compose up --build
```
After starting the server, you will be able to access the API through your localhost:3000.

# Have a taste of it
Once the API is running, feel free to explore all its endpoints. The following steps are an example of how one can use this API for several operations:

Step 1: Authenticate with wrong PIN
```
POST http://localhost:3000/users/10101/authenticate?pin=666
returns a 401 (Forbiden) status
```

Step 2: Authenticate with right PIN
```
POST http://localhost:3000/users/10101/authenticate?pin=111
response: {"data":{"token_id":"ebbdb1f1d36f1a196a123ebd0f81799e"}}
returns a 201 Created status
```
Step 3: Use this token_id to list the user operations filtered by type
```
GET http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/operations?type=deposit
response: {"data":[{"id":4,"account_number":111,"type":"deposit","amount":200.0,"date":"2017-01-01"}]}
returns a 200 OK status
```

Step 4: Try a withdraw higher than its balance
```
POST http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/withdraw?amount=9000
returns a 403 Forbiden status
```

Step 5: Make a deposit for yourself
```
POST http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/deposit?amount=100&account=111
response: {"data":{"number":111,"current_balance":100.0}}
return a 200 OK status
```

Step 6: Make a deposit for someone else
```
POST http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/deposit?amount=20&account=222
response: {"data":{"number":222,"current_balance":20.0}}
return a 200 OK status
```

Step 7: Make a withdraw
```
POST http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/withdraw?amount=66
response: {"data":{"number":111,"current_balance":34.0}}
return a 200 OK status
```

Step 8: List your operations
```
GET http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/operations
response: a JSON with all your operations
returns a 200 OK status
```

Step 9: Filter your operations (by type and end date, for example)
```
GET http://localhost:3000/tokens/ebbdb1f1d36f1a196a123ebd0f81799e/operations?type=deposit&to=2017-09-21
response: a JSON with all your filtered operations
returns a 200 OK status
```
