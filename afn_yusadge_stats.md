# Yusadge Stats

## 2019-6-25

I'm resurrecting the old yusadge stats app.  I'm getting it up and
running on my laptop here.  It looks like the old old yusadge server
isn't up anymore.  I'm scouring my email looking for the current server.

Ok I found a recent ftp session log in my email:

    Date: Fri, 03 Mar 2017 14:24:23 -0600
    From: Ryan Nowakowski <ryan@fattuba.com>
    To: john pence <john.pence@austinfree.net>
    Subject: Re: Yusadge Stats is back up and running

I saved the log to downloads folder on my home server.  It has the hostname and
user but the password is obscured.  Perhaps it's available on my demo server
database?

Yup, found the password on my demo server!  I can transfer data from my demo
server to my local dev instance like this:

    ssh baadsvik 'export DJANGO_SETTINGS_MODULE=yusadgestats.settings.demofattuba; ~/.virtualenvs/yusadge-stats/bin/python ~/sandboxes/yusadge-stats/manage.py dumpdata --indent=4 yusadge.site yusadge.organization yusadge.computernameregex yusadge.hours' | ./manage.py loaddata --format json -
