# Approuter 2.0 (ok, 0.2.0)

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

So, in practice, with a simple interface addition ( adding a executable file called ar-start ) Approuter will spin up and manage whatever process is started, routing inbound requests to it as they are recieved, and upgrading whenever changes are available.

### Definitions

- Application: The code managed by approuter.  This is generally code stored in a git repository that contains at least a file named ar-start at it's root.
- Application Lifecycle or Lifecycle - The stages of existence that Approuter manages for your application.  This includes installation, start, upgrade, draining, inactive.
- Repository or Repo: The version control system (git) that contains the application code.  This is referenced by an URL, and must be accessible from whatever location Approuter is running.
- Control Files: Executable files in the root of the repository that Approuter uses to manage various stages of the application lifecycle
- Jobs: Executables that are scheduled in the crontab of the user running Approuter using 'shat' notation.
- shat notation: A convenient way to embed a crons schedule in a file using a shat '#@ ' followed by a valid cron schedule.


### How do I use it?

#### Steps

  - Clone the repo into a directory of your choice:
    `cd ~`
    `git clone https://github.com/intimonkey/approuter.git`


### Known issues

- On OS X logrotate is built into a different directory than the cron job references, so the cron task will fail.  Since OS X is generally only used for development, it's left 'as-is'.
- Will not work on Windows.
- Known to work at all on Ubuntu 11.10, 12.04 LTS, OS X 10.8.5
