# Server
This is the API server for DMAC in Kemal (http://kemalcr.com) in Crystal (https://crystal-lang.org)

Envrionmental variables:  
PG_URL: the database url like: postgres://username:password@localhost:5432/dmac_development  
DMAC_ROOT: the root directory for projects  
DMAC_SERVER: the server's domain name or ip adress  
DMAC_PORT: the server's port  
GLOBUS_CLIENT_ID: the app client id registered on Globus   
GLOBUS_CLIENT_SECRET: the app client secret generated on Globus   
DMAC_PERMISSION: if using local user and file acl permission to adapt to Globus connect server. Set `local` to enable it.
IRODS_SCRIPT: point to the `script/unl_irods/unl_irods.py` to work with CyVerse. 

When working with Globus connect server:
- set 002 as umask
- add `perms 660` in /etc/gridftp.conf
- set correct hostname in OS and globus config

when adding a manager:
- Add user directory
- make the directory with correct ownership and permissions if working with Globus
- Change user's home directory to the new directory if working with Globus

## Installation
1. install Crystal https://crystal-lang.org/docs/installation/
2. `shards install`

## Usage
API Server `crystal src/server.cr`. It serves on port 3000.

Cleaner `crystal src/cleaner.cr`

## Build for deployment
`shards build`

## Serve client
Make a symbolic link called `public` to your client `dist` folder `ln -s your_dist public`

