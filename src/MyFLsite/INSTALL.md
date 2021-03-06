DEPLOYMENT DOCUMENTATION
========================
These are instructions on how to install MyFLq webapp outside of a container in a server environment.
To do that you can simply clone the whole repository.

To write this documentation, a virtualbox ubuntu server 12.04 64bit was freshly installed
    OpenSSH server, LAMP server and Mail server included in the install

#On server:
 #Dependencies:
sudo apt-get install libapache2-mod-wsgi-py3
sudo apt-get install python3 python3-setuptools
sudo easy_install3 django
sudo apt-get install git libmysqlclient-dev python3-dev
git clone https://github.com/clelland/MySQL-for-Python-3.git
cd MySQL-for-Python-3/
python3 setup.py build
sudo python3 setup.py install
sudo easy_install3 Pillow
sudo apt-get install rabbitmq-server
sudo easy_install3 Celery
 #Prepare server mysql
mysql -uroot -p
    CREATE DATABASE myflsitedb CHARACTER SET utf8;
    CREATE USER 'myflsiteuser'@'localhost' IDENTIFIED BY 'myfl1234user';
    GRANT ALL ON myflsitedb.* TO 'myflsiteuser'@'localhost';
 #Extract and test web app
git clone https://github.com/beukueb/myflq
cd myflq/src/MyFLsite
python3 manage.py syncdb
python3 manage.py runserver 0.0.0.0:8000 #to test via host browser
 #Change app settings for deployment
mg MyFLsite/settings.py
    #Static files
    STATIC_URL = '/static/'
    STATIC_ROOT = '/var/www/myflsite/static/'
    STATICFILES_DIRS = (  
        os.path.join(BASE_DIR, "static"),
    )
    MEDIA_URL = '/media/'
    MEDIA_ROOT = '/var/www/myflsite/media/'
    
    #Email
    #Debug #=> still to be updated in documentation!!!

sudo mkdir -p /var/www/myflsite/media
sudo chown -R christophe:christophe /var/www/myflsite
sudo chown -R www-data:www-data /var/www/myflsite/media #necessary for apacha, not for manage.py runserver
python3 manage.py collectstatic

 #Update httpd.conf
sudo mg /etc/apache2/httpd.conf
    #Alias /robots.txt /var/www/myflsite/static/robots.txt
    Alias /favicon.ico /var/www/myflsite/static/favicon.ico

    AliasMatch ^/([^/]*\.css) /var/www/myflsite/static/styles/$1

    Alias /media/ /var/www/myflsite/media/
    Alias /static/ /var/www/myflsite/static/

    <Directory /var/www/myflsite/static>
    Order deny,allow
    Allow from all
    </Directory>

    <Directory /var/www/myflsite/media>
    Order deny,allow
    Allow from all
    </Directory>

    WSGIScriptAlias / /home/christophe/MyFLqApp/MyFLsite/MyFLsite/wsgi.py
    WSGIPythonPath /home/christophe/MyFLqApp/MyFLsite/

    <Directory /home/christophe/MyFLqApp/MyFLsite/MyFLsite>
    <Files wsgi.py>
    Order deny,allow
    Allow from all
    #Require all granted #=> if Apache version < 2.4
    </Files>
    </Directory>
sudo apache2ctl restart

#MyFL[q|db].py setup
cd ~/MyFLsite/myflq/programs
 #MyFL[q|db].py dependencies
sudo easy_install3 pymysql numpy
sudo apt-get install g++ libfreetype6-dev libpng-dev #dependencies matplotlib
 #or: sudo apt-get build-dep python-matplotlib #to install all, including optional dependencies for matplotlib (+- 700 Mb)
sudo easy_install3 python-dateutil six #other matplotlib dependency
sudo easy_install3 -U distribute
sudo easy_install3 matplotlib #in case of strange installation problems, try: sudo easy_install3 -m matplotlib
# or: sudo easy_install ipython #this normally includes above dependencies and is necessary for parallel processing
mysql -uroot -p
      GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'passall' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
python3 MyFLdb.py --install admin -p passall

#Enable tasks daemon
##With simple_tasks.py
cd ~/MyFLqApp/MyFLsite
export PYTHONPATH=$PYTHONPATH:~/github/myflq/src/MyFLsite:~/github/myflq/src
sudo -u www-data python3 myflq/simple_tasks.py
##With celery
sudo -i
cd /etc/init.d/
wget https://raw.github.com/celery/celery/3.1/extra/generic-init.d/celeryd --no-check-certificate
chmod +x /etc/init.d/celeryd
emacs /etc/default/celeryd
    # Names of nodes to start
    #   most will only start one node:
    CELERYD_NODES="worker1"
    #   but you can also start multiple and configure settings
    #   for each in CELERYD_OPTS (see `celery multi --help` for examples).
    #CELERYD_NODES="worker1 worker2 worker3"

    # Absolute or relative path to the 'celery' command:
    CELERY_BIN="/usr/local/bin/celery"
    #CELERY_BIN="/virtualenvs/def/bin/celery"

    # App instance to use
    # comment out this line if you don't use an app
    CELERY_APP="MyFLsite"
    # or fully qualified:
    #CELERY_APP="proj.tasks:app"

    # Where to chdir at start.
    CELERYD_CHDIR="/home/christophe/MyFLqApp/MyFLsite/"

    # Extra command-line arguments to the worker
    CELERYD_OPTS="--time-limit=86400 --concurrency=4"
     #86400s = 24h => after which unfinished tasks are killed

    # %N will be replaced with the first part of the nodename.
    CELERYD_LOG_FILE="/var/log/celery/%N.log"
    CELERYD_PID_FILE="/var/run/celery/%N.pid"

    # Workers should run as an unprivileged user.
    #   You need to create this user manually (or you can choose
    #   a user/group combination that already exists, e.g. nobody).
    CELERYD_USER="www-data"
    CELERYD_GROUP="www-data"

    # If enabled pid and log directories will be created if missing,
    # and owned by the userid/group configured.
    CELERY_CREATE_DIRS=1
#Usage:	/etc/init.d/celeryd {start|stop|restart|status}
emacs /etc/rc.local
    /etc/init.d/celeryd start #Add this line before 'exit 0'
    #Other option would be making symbolic links in relevant /etc/rcX.d/ runlevels



