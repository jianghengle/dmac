# DMAC
The prototype of Data Management and Analysis Core.

Online demo(http://34.212.66.157)
  
Need to install Postgres, Git, Zip and Unzip on the server to make the application fully work.

It has three components: `admin`, `server`, `client`. Each needs to be installed and run seperately. Refer to the README inside each for installation instruction.


The `admin` is a Rails application for database migration and management.

The `server` is the backend, which is a pure API server in Crystal.

The `client` is the frontend, which is a Vuejs application.

The frontend and backend are fully decoupled. The built `client` code can be served from anywhere. But if you want to Single Sign On through globus, it must be served by the API server directly.

Currently, I deployed all on one Anvil instance. The code is checked out in the HOME directory, and run as SystemD services: `dmac_admin.service`, `dmac_server.service`. The built `client` is also in HOME as the `dist` directory and served by the API server together. Additionally, there is a `dmac_cleaner.service` running daily by the timer `dmac_cleaner.service`. You could take a look at the service files in `services` in HOME, but the actual service files are in `\usr\lib\systemd\system`.

The project files are in `HOME/dmac-root`, which is set as environment variable `DMAC_ROOT`. You could take a look at `dmac_server.service` to see this variable and `PG_URL` variable, which contains the database info.

To redeploy the application on the same server:
* Go to `dmac` directory and checkout the latest dev
* If `admin` needs to be redeployed:
  - If there is new migrations, go to `admin` and run `rake db:migrate`
  - Restart the service: `sudo systemctl restart dmac_admin`
  - Note that the admin site is on port `3001`
* If `server` needs to be redeployed:
  - Go to `server` and run `shards build`
  - Restart the service: `sudo systemctl restart dmac_server`
* If `client` needs to be redeployed:
  - build `client` locally and `scp -r dist centos@server:~`
  
To install the application from scratch, first install Postgres(https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7), Git, Zip and Unzip, and then install `admin`, `server` and `client` as instructed in their READMEs.
