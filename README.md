Droppy
======

A simple web app for watching a folder on dropbox and providing links to download what's in there.

Setup
-----

1. Make a new dropbox user
1. Start an app in dropbox
  1. Create a new app here: [dropbox.com/developers/apply](https://www.dropbox.com/developers/apply)
  1. Click "Create an App"
  1. Pick a unique app name (doesn't matter what it is)
  1. **important** pick "Full Dropbox" for Access Level
  1. Copy the KEY and SECRET
1. Share one of your dropbox folders with this new user (It's a good idea to create a new one - by default, the app will use a folder named `droppy`)
1. Run this (see **Install** below)


Install
-------

### Locally

1. `gem install bundler`
1. `gem install foreman`
1. `bundle install`
1. edit `.env` put these lines in:
  1. `DROPBOX_KEY=key_from_before`
  1. `DROPBOX_SECRET=secret_from_before`
1. `foreman start`
1. open `http://localhost:5000` in the **same** browser you used to sign up the new dropbox account
1. It will take you to dropbox, authorize the app. You will be redirected back and it will tell you the new DROPBOX_TOKEN
1. put `DROPBOX_TOKEN=that_token` in your .env file
1. restart foreman, and enjoy


### On Heroku

1. `gem install heroku`
1. `heroku create --stack cedar <whatever name you want>`
1. `git push heroku master`
1. `heroku config add DROPBOX_KEY=app_key`
1. `heroku config add DROPBOX_SECRET=app_secret`
1. `heroku open`
1. It will take you to dropbox, authorize the app. You will be redirected back and it will tell you the new DROPBOX_TOKEN
1. `heroku config add DROPBOX_TOKEN=that_token`


Debugging
---------

if you need to use irb:

```ruby
open('.env').read.each_line {|l| m=l.scan(/(.*)=(.*)/); ENV[m[0][0]]=m[0][1] }
```
