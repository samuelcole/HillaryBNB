
## Goal
We want to build an app to allow supporters to share their homes with others from out
of town and to help supporters on the road find lodging.

## How We're Doing It
* Rails 4.2.5
* Devise/ Omniauth for authentication with Facebook and google
* Geocoder gem to search by zipcode, using Bing geocoding API.
* Bower for front end asset management

## Contributing
Please e-mail sam@samuelcole.name.
We would love your help.

## Setting up development

* Fork MarchBNB on github and clone: `git clone git@github.com:<your github username>/MarchBNB.git && cd MarchBNB`
* `cp config/application.yml.example config/application.yml`
* `git remote add upstream git@github.com:samuelcole/MarchBNB.git` so you can keep in sync with original project by running `git pull upstream master`.

### The Manual Way

This is a fairly standard Rails application, so the normal setup
procedures will work:

1. You need to install the correct version of Ruby and Rubygems (based
on the versions specified in the ``Gemfile``). You may want to use a
tool like ``rvm`` to isolate your Ruby and gem files.
2. Install a postgresql database.
3. Run ``bundle install`` to install all of your dependencies.
4. Run ``bin/rake db:migrate RAILS_ENV=development`` to run your
   database migration.
5. Run ``rails server -b 0.0.0.0 -p 8080`` to start your sever.
6. Test your app by visiting the following URL:
  - http://localhost:8080

### Using Docker

The project includes a ``Dockerfile`` that you can use to create a
ruby development server. You can then use this container with a
Postgresql container to create a complete development environment.
Usage is optional based on your comfort level with Docker.

#### Building The Rails Image 

To use it, you would first need to build your image using the
following commands:

    cd ~/src/MarchBNB
    sudo docker build -t marchbnb/rails .
	
#### Creating A Docker Network

Next you'll need a Docker Network that your containers can use to talk
to each other. Run this command:

    sudo docker network create marchbnb-network
	
#### Running Your Containers

##### Postgres

First create a directory on your host where you can store your
persisted data:

    mkdir -vp "$HOME/docker/container/marchbnb-pg-dev/var/lib/postgresql/data"
	
Next run your container:

    export HOST_PGDATA_HOME="$HOME/docker/container/marchbnb-pg-dev/var/lib/postgresql/data"
    export POSTGRES_PASSWORD=
    export POSTGRES_USER=postgres
    export POSTGRES_DB=postgres

    sudo docker run \
         --name db \
		 --net=marchbnb-network \
         -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
         -e POSTGRES_USER="$POSTGRES_USER" \
         -e POSTGRES_DB="$POSTGRES_DB" \
         -v "$HOST_PGDATA_HOME":/var/lib/postgresql/data \
         -d \
         postgres:9.6-alpine
		 
This container will persist even if it's stopped. If you need
to replace it simply remove the existing container and this 
run the ``docker run`` command above again. Otherwise you can 
use the ``docker stop`` and ``docker start`` container commands
to manage it.

##### Rails

When using Docker you don't have to run the ``bundle install`` command
because the ``Dockerfile`` already takes care of that for you. So next
we're going to launch a container that uses the ``marchbnb/rails``
image we build earlier to perform our first database migation:

    cd ~/src/MarchBNB
    sudo docker run \
         -e RAILS_ENV=development \
         --net=marchbnb-network \
         --rm \
         --user "$(id -u):$(id -g)" \
         -v "$PWD":/usr/src/app \
         -w /usr/src/app \
         -it \
         marchbnb/rails \
         bash -c "bin/rake db:migrate RAILS_ENV=development"
		 
This container will automatically delete itself once its done runnning.
You can then run your Rails server with this command:

    cd ~/src/MarchBNB
    sudo docker run \
         -e RAILS_ENV=development \
         --name marchbnb-rails \
         --net=marchbnb-network \
         --rm \
         --user "$(id -u):$(id -g)" \
         -v "$PWD":/usr/src/app \
         -w /usr/src/app \
         -p 8080:8080 \
         -d \
         marchbnb/rails
		 
You can then test your application by visiting this url:

  - http://localhost:8080
  
If you have any issues with the container you can "log into" it
by executing this command:

    cd ~/src/MarchBNB
    sudo docker run \
         -e RAILS_ENV=development \
         --name debug-marchbnb-rails \
         --net=marchbnb-network \
         --rm \
         --user "$(id -u):$(id -g)" \
         -v "$PWD":/usr/src/app \
         -w /usr/src/app \
         -p 8080:8080 \
         -it \
         marchbnb/rails \
         bash
		 
From here you can run rails commands and interrogate your runtime
environment.

#### Running Tests

The first time you run the tests you'll need to set up the database 
like this:

    cd ~/src/MarchBNB
    sudo docker run \
         -e RAILS_ENV=test \
         --name debug-marchbnb-rails \
         --net=marchbnb-network \
         --rm \
         --user "$(id -u):$(id -g)" \
         -v "$PWD":/usr/src/app \
         -w /usr/src/app \
         -p 8080:8080 \
         -it \
         marchbnb/rails \
         bash -c 'bundle exec rake db:create'
		 
Then you can run tests like this:

    cd ~/src/MarchBNB
    sudo docker run \
         -e RAILS_ENV=test \
         --name debug-marchbnb-rails \
         --net=marchbnb-network \
         --rm \
         --user "$(id -u):$(id -g)" \
         -v "$PWD":/usr/src/app \
         -w /usr/src/app \
         -p 8080:8080 \
         -it \
         marchbnb/rails \
         bash -c 'bin/rake db:migrate && bin/rake'
		 
You can populate test data like this:

    cd ~/src/MarchBNB
    sudo docker run \
         -e RAILS_ENV=test \
         --name debug-marchbnb-rails \
         --net=marchbnb-network \
         --rm \
         --user "$(id -u):$(id -g)" \
         -v "$PWD":/usr/src/app \
         -w /usr/src/app \
         -p 8080:8080 \
         -it \
         marchbnb/rails \
         bash -c 'bundle execrake db:reset'
		 
Finally, you can "rebuild and restart" like this:

1. Delete your ``marchbnb-rails`` container.
2. Delete your ``marchbnb/rails`` Docker image.
3. Delete the directory containing your Postgresql data.
4. Start over.

## Updating gem versions
* `docker-compose run --rm shell bundle update [gemname]`

Don't forget to mention that they need to recreate the image.

## Modifying schema
* EXAMPLE: `docker-compose run --rm shell rails generate migration AddAccomodationTypeToHosting accomodation_type:integer`

## Connecting to dev DB
* `docker-compose exec herokuPostgresql psql -U postgres`

## Deploying to Heroku
* install [Heroku Toolbelt](https://toolbelt.heroku.com/)
* `heroku plugins:install heroku-container-tools`
* get application.yml from DJ and put it in config/
* `heroku container:release --app marchbnb`   NOTE that this deploys whatever you have locally in your dev environment, not what is committed to git or pushed to github

If there are database migrations to be deployed:
* `heroku run rake db:migrate`
* `heroku restart`

* `heroku open --app marchbnb`

## Sending daily emails
You should set up the following to run periodically (daily was what BernieBNB did):
* `heroku run rake clear_past_dated_visits`
* `heroku run rake send_new_contacts_digest`
* `heroku run rake send_new_hosts_digest`
*WARNING* do not run `heroku run rake`, it will happily delete the entire database!   <---- TODO fix this so it cant happen in production


## Setup local hostname
Google OAuth only allows hostnames for its OAuth URLs. Setup a local hostname that points to your docker machine
### Mac
* Run `docker-machine ip default` to find your docker machine IP
* Copy that into `/etc/hosts` and give it whatever hostname you want (ex. hbnb.com)
* Visit `hbnb.com:8080` to verify it works

## Setting up Facebook/Google/Bing connections
Configure values for the variables below in config/application.yml:
* Set up Facebook Developer account at https://developers.facebook.com
  then get your FACEBOOK_KEY and FACEBOOK_SECRET.
  * Here is a good How-To article:
    * https://goldplugins.com/documentation/wp-social-pro-documentation/how-to-get-an-app-id-and-secret-key-from-facebook/
* Set up Google Developer account at https://developers.google.com/
  and get your GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.
  * Here are two good How-To articles:
    * https://richonrails.com/articles/google-authentication-in-ruby-on-rails/
    * http://wlowry88.github.io/blog/2014/08/02/google-contacts-api-with-oauth-in-rails/
  * Some instructions
    * In the Google console:
      * Create credentials, which gets you a Client ID and Secret
      * Enable the Google+ API or you will get an invalid credentials error
      * Set your redirect URI to the following http://hbnb.com:8080/auth/google_oauth2/callback
    * Rename your VM to hbnb.com in /etc/hosts (or windows equivalent) to ensure your browser can resolve the callback URI:  `echo '$(docker-machine ip) hbnb.com' >> /etc/hosts`
* Create Bing Maps key (BING_GEOCODE_ID) at
  https://msdn.microsoft.com/en-us/library/ff428642.aspx

## Setting up Mailgun

A mailgun account is required to send the confirmation email when signing up.

* Go to [Mailgun](https://mailgun.com) and sign up for an account
* You will start with a sandbox account with up to 300 emails per day, or you can create a real one with 10k free emails per month.
    * If using the sandbox account, add your own email as an [authorized recipient](https://mailgun.com/app/testing/recipients).
* Go to your sandbox domain page to fill out all the `MAILGUN_*` variables in `config/application.yml`
    * In `config/application.yml`, set MAILER_URL to the result of `echo $(docker-machine ip default):8080`
    * Go to the [main page](https://mailgun.com/app/dashboard) and search for `API Keys` to find your public key.
* Restart `docker-compose restart web`
* If you see a 400 error from Mailgun, check your [logs](https://mailgun.com/app/logs). Mailgun may disable your account pending business verification; you'll need to contact support to have them enable it or borrow someone else's sandbox credentials if they don't respond.

## When does People's Housing send emails?

**NOTE:** This section is outdated and needs to be updated!

As of 20161010, Peopleshousing.com sends emails nightly.  Every night at 3:30/4am Eastern time we do the following:

For each Hosting Offer registered in the system, if there are any visitors who clicked the "SEND MY CONTACT INFO" button within the past 24 hours, we gather their contact information and email them to the the host. (Note that this means a host may receive multiple emails from us if they have multiple Hosting Offers).  (This logic is in https://github.com/DevProgress/HillaryBNB/blob/master/lib/tasks/send_new_contacts_digest.rake)

For each Visit registered in the system, if there are any new Hosting Offers created within the past 24 hours that are within 20 miles of the Visit's zip code, we email them to the visitor. (Note that this means a visitor may receive multiple emails from us if they have multiple pending Visits).  (This logic is in https://github.com/DevProgress/HillaryBNB/blob/master/lib/tasks/send_new_hosts_digest.rake)
