# Server
`crystal src/server.cr`

Envrionmental variables:  
PG_URL: the database url like: postgres://localhost:5432/niobrara_development  
ACCOUNT_SERVER: the account server to authorize a user  

The account server should have two the end points:  
ACCOUNT_SERVER/get_token: accept {email, password} and return {token}  
ACCOUNT_SERVER/get_user: accept {token} and return {email}  

If ACCOUNT_SERVER not set, server will use email replacing "@" with "--" as token  
ACCOUNT_SERVER could be set to the server itself: http://localhost:3000, and then user must have an account on the server to be able to connect.

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/[your-github-name]/websocket/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) hengle - creator, maintainer
