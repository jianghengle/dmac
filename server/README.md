# Server
This is the API server for DMAC

Envrionmental variables:  
PG_URL: the database url like: postgres://username:password@localhost:5432/dmac_development
DMAC_ROOT: the root directory for projects

## Installation
1. install Crystal https://crystal-lang.org/docs/installation/
2. `shards install`

## Usage
API Server `crystal src/server.cr`

Cleaner `crystal src/cleaner.cr`

## Build for deployment
`shards build`
