# Approuter 2.0 (ok, 0.2.0)
## Documentation Woefully Incomplete (DWI) 

### What's it do?
The idea is to provide lifecycle managment of a process answering HTTP requests. 
Handling things that are more than just conveniences like:

- Automatic updates when the source repository (git) has changes
- Distinct installation and startup phases to allow the application to do one time installation work before it will made 'live'
- Configurable number of preforked worker processes.  
- Downtime during upgrades (by making sure there is none)
- Managment of worker processes so if anything stops unexpectedly they're automatically restarted
- A handy NGINX front end to do the heavy-lifting for you
- Easy override of NGINX configuration for those 'special' cases
- Automatic scheduling of repeating tasks using cron and our patented 'shat' interface
- Clean installation of new versions. 
- Remain agnostic of your application implementation: It's just a process to Approuter.

So, in practice, with a simple interface addition ( adding an executable file called ar-start ) Approuter will spin up and manage whatever process is started, routing inbound requests to it as they are recieved, and seemlessly upgrading whenever changes are available.

### Definitions

- Application: The code managed by approuter.  This is generally code stored in a git repository that contains at least a file named ar-start at it's root.
- Application Lifecycle or Lifecycle - The stages of existence that Approuter manages for your application.  This includes installation, start, upgrade, draining, inactive.
- Repository or Repo: The version control system (git) that contains the application code.  This is referenced by an URL, and must be accessible from whatever location Approuter is running.
- Control Files: Executable files in the root of the repository that Approuter uses to manage various stages of the application lifecycle
- Jobs: Executables that are scheduled in the crontab of the user running Approuter using 'shat' notation.
- shat: A convenient way to embed a cron schedule in a file using a shat '#@ ' followed by a valid cron schedule.
- Application Overlay - What?
- Overrides: What?

### Application Interfaces

The Apprtouer Application Interface is the interface that Approuter will use
to configure and manage the lifecycle of the application that it manages.

- ar-start: (required) This is an executable file that needs to replace itself
with the process of the running application (needs to exec the app) as it's
final action.  This should limit itself to the a bare minimum to start the app
setting environment variables is reasonable and likely, all significant setup
and install actions should be handled in ar-install.
- ar-install: (optional) This is an executable file that is used to perform
any setup or installation activities prior to starting instances of the
application.  This installation takes place once per application version prior
to starting any workers, any modification of the environment or installation of
packages should be done here. This is the place to do 'one time setup'
operations prior to starting.
- ar-jobs: (optional) A directory containing executable scripts that can be
scheduled (using cron). This directory will be searched on start for any
executable files that contain a #@ 'shat' indicator.  The shat data will be
used to schedule the execution of the script using cron.
- ar-health.conf: (optional) A file containing a path that can be used to
determine if the application is up and working normally.  This path should be
the full path to a page that, when the application is up and healthy, will
return a HTTP status of 200 e.g. /diagnostic.  If no health check is desired,
adding an empty ar-health.conf file will cause the the health check to be
skipped on start.  If the health check path is specified it MUST return a 200
to allow the application to be considered healthy and served, anything else
will result in the application not being made available.
- ar-overrides: A directory containing overrides for approuter configuration
items.
- nginx.conf: If present in the ar-overrides directory will be used as the
template for configuring NGINX used by Approuter.  Approuter expects the
nginx.conf file to be a template allowing it to control certain values, see
the templates/nginx.conf in the Approuter repository for template variables.

### How do I use it?

Use a dedicated user for Approuter, it expects this and is pretty liberal with
things like the crontab (in that it will remove the whole thing on shutdown).

#### 'Installation'
- Log into your box as the user you'd like to have run Approuter.
  
        $ ssh myuser@my.awesome.server
- Clone the repo into a directory of your choice:

        $ cd ~
        $ git clone https://github.com/intimonkey/approuter.git
- Build Approuter

        $ cd ~/approuter/
        $ make
- Source the Approuter environment (still in ~/approuter/)

        $ source ./environment
- Start your app

        $ start_approuter https://github.com/intimonkey/approuter-test.git 8080 2

- Check to see if it's running.  Once start of your app is done you should be able to 

        $ status
        perpls:
        [+ +++ +++]  2013-09-25T13_38_25-0500_9005  uptime: 3441s/3441s  pids: 25751/25750
        [+ +++ +++]  2013-09-25T13_38_25-0500_9006  uptime: 3441s/3441s  pids: 25754/25753
        [+ +++ +++]  instance_update                uptime: 3567s/3567s  pids: 13191/13190
        [+ +++ +++]  nginx                          uptime: 3567s/3567s  pids: 13193/13192

### Filesystem Structure

It is assumed for the discussion of the filesystem that follows it will be assumed (and
is suggested) that Approuter is contained in the directory ~/approuter.

**build_output/** - Directory that will contain the applications build by Approuter such
  as perpd and NGINX.

**managed/** - This directory is where all the managed repos (applications) and the conf
  data to manage them is stored.

**managed/var/** - This directory contains all the generated output from running the man
  This includes: log files, config files, run data (pidfiles) etc.  It also includes
  the generated crontab that will be installed on start.

**managed/app_instances/** - This directory contains cloned repositories of each version
  of the hosted app that Approuter has or is running.  Approuter doesn't remove old
  instances of the app when it adds it simply clones a new instance and starts it, so 
  there can be old instances which are no longer being served by NGINX found here.

**managed/app_instances/active & latest_cloned** - The symbolic links (`active`, and `latest_cloned`)
  present in the `app_instances` directory indicate the currently running application
  instance `active` and the most recently cloned instance `last_cloned`.  Generally
  these should be the same, but in certain circumstances it's possible that they differ.

**managed/var/log/** - This directory contains the log files generated by approuter and
  the services an instances it is managing.  Each service that is run will end up with 
  a directory here (e.g. `manage/var/log/2013-09-25T13_38_25-0500_9005`) with its
  logfiles contained within.

**managed/etc/perp** - This serves as the `PERP_BASE` for the instances of perpd that Approuter
   manages ( Approuter installs the man pages for perpd, and they are available when you
   have sourced the Approuter environment ).

**templates/** - This directory contains templates of various files that Approuter will
  use during it's operation to create various configuration and control files.

**etc/** - Directory created at the root of the approuter environment that can contain
  legacy configuration information, as well as state information used by Approuter.


### Environment and Configuration

* `AR_NO_CRONTAB`: Causes the crontab installation to be skipped, so none of the
  application jobs or Approuter management tasks will be installed.  This is intended
  to simply be a development convenience.
* `DEBUG`: Will cause additional debug information to be written during Approuter
  execution
* `USE_SYSLOG`:  Will cause application logs to be written to syslog instead of
  individual files.  This is subject to all the normal caveats from using syslog, see
  your individual syslog implementation for details
* `IGNORE_HC_ERRORS`: If set to any non empty string value, this will cause the any
  health check errors during start to be ignored.  Setting this value along with
  configuring a health check path, will cause the health check to be performed but
  any non 200 status results to be treated as if they were 200s and the application
  served normally.  If this is set, and the application health check path does _not_ 
  return a 200 the health check will still run until it times out and thus will
  delay the serving of the application but it will still be served after the health
  checks time out.  It's worth it to note that each application worker will be health
  checked independently so if you request 4 'workers' the health check will have to 
  run 4 times prior to the application instance being made available.
* `USE_SERVICE_LOG`: The traditionaly way that Approuter handled logging was to
  have a directory under managed/var/log for each process running a given
  service (e.g. managed/var/log/2014-01-29T16\_11\_08-0500\_9001 ) within which
  the active log was named 'current' and others were timestamped and rolled.
  The new default is to use a single log named service (i.e.
  /managed/var/log/service.log) to which all the active services will log.  If
  this is _not_ desired (i.e. the old behaviour is desired) set this value to
  null.

### Caching
  As a convenience Approuter provides some path prefixes that it will listen
  to allowing for the caching and serving of cached responses. The paths start
  with cacheNU, where N is a numeric value and U is the units. Currently the
  available cache prefixes are as follows:

  * cache1h
  * cache2h
  * cache4h
  * cache365d

  These path prefixes can simply be used at the head of your existing paths to
  allow for caching.

  original request:

          http://approuter.host.example/my/app/index.html

  cached:

         http://approuter.host.example/cache1h/my/app/index.html
  
  When requesting a cached version of an existing endpoint, you will also
  recieve an X-Cache-Status header in the response with a value of HIT or
  MISS according to the use of the cache in servicing the request.

### Common Commands

    start_approuter <repository url> <nginx port> [worker count] [branch]

* repository url : a valid git url that contains the application source
* nginx port : this is the port on which nginx will be listening for inbound requests.
* worker count : this is the number of processes that Approuter will start to handle requests.  These will become upstream entries that NGINX will be proxying to.
* branch: a specific branch to use when deploying the managed application.  If not specified the repository default branch will be used.

<!-- -->

    approuter_status

Shows the status of all processes managed by approuter, ultimately this is just a view into processes managed by perpd.

    stop_approuter

Shuts everything managed by approuter including removing the crontab.

    update_approuter

Fetches any changes to the approuter code. It's safest to assume that you'd need to
stop and restart to take advantage of any changes.  The majority of the logic behind approuter is managed in shell scripts so there's generally no need to rebuild (`make`).

### Known issues

- Will not work on Windows.
- Known to work at all on Ubuntu 11.10, 12.04 LTS, OS X 10.8.5

### None of this is possible without
- [perp](http://b0llix.net/perp/)
- [nginx](http://nginx.org/)
- [lua](http://www.lua.org/)
- logrotate
- [openssl](http://www.openssl.org/)
- [pcre](http://www.pcre.org/)
- [bash](http://www.gnu.org/software/bash/)
- cron - or something that acts like it
