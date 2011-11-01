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
1. Share one of your dropbox folders with this new user (It's a good idea to create a new one)
1. Run this (see **Install** below)


Install
-------

### Locally

1. `gem install bundler`
1. `gem install foreman`
1. `bundle install`
1. edit .env, add `DROPBOX_EMAIL=new_user_email`, `DROPBOX_PASS=new_user_pass` for the **new** user
1. put `DROPBOX_FOLDER=your_new_dropbox_folder` in .env
1. `foreman start`
1. `open http://localhost:5000`


### On Heroku

1. `gem install heroku`
1. `heroku create --stack cedar`
1. `git push heroku master`
1. `heroku config add DROPBOX_EMAIL=new_user_email`
1. `heroku config add DROPBOX_PASS=new_user_pass`
1. `heroku config add DROPBOX_FOLDER=your_new_dropbox_folder`
1. `heroku open`


Debugging
---------

if you need to use irb:

```ruby
open('.env').read.each_line {|l| m=l.scan(/(.*)=(.*)/); ENV[m[0][0]]=m[0][1] }
require 'oauth'
```
