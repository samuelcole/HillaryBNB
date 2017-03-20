
## Goal
We want to build an app to allow supporters to share their homes with others from out
of town and to help supporters on the road find lodging.

## How We're Doing It
* Rails 4.2.5
* Devise/ Omniauth for authentication with Facebook and google
* Geocoder gem to search by zipcode, using Bing geocoding API.
* Bower for front end asset management

## Contributing
Please e-mail dsjoerg@gmail.com.
We would love your help.

## Setting up development
* install [Docker Toolbox](https://www.docker.com/toolbox)
* fork MarchBNB on github and clone: `git clone git@github.com:<your github username>/MarchBNB.git && cd MarchBNB`
* `cp config/application.yml.example config/application.yml`
* `export RAILS_ENV=development`
* `docker-machine create -d virtualbox default`
* `eval $(docker-machine env default)`
* `docker-compose build`
* `docker-compose up -d web`
* `open "http://$(docker-machine ip default):8080"`
* `git remote add upstream git@github.com:samuelcole/MarchBNB.git` so you can keep in sync with original project by running `git pull upstream master`.
* Run tests: `RAILS_ENV=test docker-compose run --rm shell bash -c 'bin/rake db:migrate && bin/rake'`
* Populate test data: `docker-compose run --rm shell bash -c 'bundle exec rake db:reset'`
* Rebuild and restart (not always required; DJ unclear on which kind of changes require it): `export RAILS_ENV=development; docker-compose down && docker-compose build && docker-compose up -d web`

## Updating gem versions
* `docker-compose run --rm shell bundle update [gemname]`

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
