Droppy
======

A simple web app for watching a folder on dropbox and providing links to download what's in there.


Why
---

Dropbox has public folders, so why this?
There's a few reasons:

* You control it... it's your web, and everything that entails (like your own SSO?)
* Auth baked in
* Runs on the free heroku offer


Picture!
--------

![Pretty!](http://metaatem.net/images/droppy_small.png)

Setup
-----

1. Clone this repo locally: `git clone https://github.com/kastner/droppy.git`
1. Make a new dropbox user (Optional, but a whole lot safer)
1. Start an app in dropbox
  1. Create a new app here: [dropbox.com/developers/apply](https://www.dropbox.com/developers/apply)
  1. Click "Create an App"
  1. Pick a unique app name (doesn't matter what it is)
  1. **important** pick "Full Dropbox" for Access Level
  1. Copy the KEY and SECRET
1. Share one of your dropbox folders with this new user (It's a good idea to create a new one - by default, the app will use a folder named `droppy`)
1. Run this app (see **Install** below)


Install
-------

### Locally

1. `gem install bundler`
1. `gem install foreman`
1. `bundle install`
1. create `.env` put these lines in:
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
1. `heroku config:add DROPBOX_KEY=app_key`
1. `heroku config:add DROPBOX_SECRET=app_secret`
1. **alternate method** if you have it working locally, you can just do `heroku config:add $(cat .env)`
1. `heroku open`
1. It will take you to dropbox, authorize the app. You will be redirected back and it will tell you the new DROPBOX_TOKEN
1. `heroku config add DROPBOX_TOKEN=that_token`


Adding Auth
-----------

Droppy supports HTTP Basic auth. To add it, just add the following two environment variables (to `.env` or `heroku config:add`):

```
AUTH_USERNAME=user
AUTH_PASSWORD=pass
```


FREE SSL on heroku!
-------------------

Heroku offers free ["Piggy-back"](http://devcenter.heroku.com/articles/ssl) ssl on "heroku.com" subdomains. All you need to do is this:

```
heroku addons:add piggyback_ssl
```

And boom, you can now use https for all of it :)


Sending Email
-------------

So you want to alert someone when a new file is there?

Add these to the environment settings (either `.env`, or `heroku config:add`):

* `EMAIL_NOTIFY_LIST` email address to send "to"
* `GMAIL_USER` Gmail username (with @gmail.com, or whathaveyou)
* `GMAIL_PASS` Gmail password
* `DROPPY_URL` Web address for the email to link to

If you're doing this on Heroku, you then need to scale up the clock process:

`heroku scale clock=1`

It will warn you about billing your account. I'm not sure how much it will bill yet.

Debugging
---------

if you need to use irb:

```ruby
open('.env').read.each_line {|l| m=l.scan(/(.*)=(.*)/); ENV[m[0][0]]=m[0][1] }
```
