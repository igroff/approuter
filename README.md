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

So, in practice, with a simple interface addition ( adding a executable file called ar-start ) Approuter will spin up and manage whatever process is started, routing inbound requests to it as they are recieved, and seemlessly upgrading whenever changes are available.

### Definitions

- Application: The code managed by approuter.  This is generally code stored in a git repository that contains at least a file named ar-start at it's root.
- Application Lifecycle or Lifecycle - The stages of existence that Approuter manages for your application.  This includes installation, start, upgrade, draining, inactive.
- Repository or Repo: The version control system (git) that contains the application code.  This is referenced by an URL, and must be accessible from whatever location Approuter is running.
- Control Files: Executable files in the root of the repository that Approuter uses to manage various stages of the application lifecycle
- Jobs: Executables that are scheduled in the crontab of the user running Approuter using 'shat' notation.
- shat: A convenient way to embed a cron schedule in a file using a shat '#@ ' followed by a valid cron schedule.


### How do I use it?

Use a dedicated user for Approuter, it expects this and is pretty liberal with things like the crontab (in that it will remove the whole thing on shutdown).


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

        $ start https://github.com/intimonkey/approuter-test.git 8080 2

- Check to see if it's running.  Once start of your app is done you should be able to 

        $ status
        perpls:
        [+ +++ +++]  2013-09-25T13_38_25-0500_9005  uptime: 3441s/3441s  pids: 25751/25750
        [+ +++ +++]  2013-09-25T13_38_25-0500_9006  uptime: 3441s/3441s  pids: 25754/25753
        [+ +++ +++]  instance_update                uptime: 3567s/3567s  pids: 13191/13190
        [+ +++ +++]  nginx                          uptime: 3567s/3567s  pids: 13193/13192


### Common Commands

    start <repository url> <nginx port> [worker count] [branch]

* repository url : a valid git url that contains the application source
* nginx port : this is the port on which nginx will be listening for inbound requests.
* worker count : this is the number of processes that Approuter will start to handle requests.  These will become upstream entries that NGINX will be proxying to.


<!-- -->

    status

Shows the status of all processes managed by approuter, ultimately this is just a view into processes managed by perpd.

    stop

Shuts everything managed by approuter including removing the crontab.

    update_approuter

Fetches any changes to the approuter code. It's safest to assume that you'd need to
stop and restart to take advantage of any changes.  The majority of the logic behind approuter is managed in shell scripts so there's generally no need to rebuild (`make`).


### Known issues

- On OS X logrotate is built into a different directory than the cron job references, so the cron task will fail.  Since OS X is generally only used for development, it's left 'as-is'.
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
