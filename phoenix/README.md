##Pete Project: Phoenix Framework (Elixir)##

The why, what and how can be found here:    
[Pete Info](../Readme.md)

This is a simple Phoenix framework app with some eex templates and a view to display some images.
The goal is to compare the performance of this framework with a similar app using other frameworks.
 
### How to run ###
To start your Phoenix app:    
```
# Initial setup
$ mix deps.get --only prod
$ MIX_ENV=prod mix compile

# Compile assets (optional they are committed in the repository)
$ brunch build --production
$ MIX_ENV=prod mix phoenix.digest

# Finally run the server
$ PORT=4001 MIX_ENV=prod elixir mix phoenix.server

# Visit http://ip-or-host.tld:4001/gallery in browser.
```

Check also deployment guide [deployment guides](http://www.phoenixframework.org/docs/deployment).

* Official website: http://www.phoenixframework.org/
