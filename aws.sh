#!/usr/bin/env bash


export DEBIAN_FRONTEND=noninteractive

export NAME="deploy"


update_system() {
    sudo aptitude update
    sudo aptitude -y upgrade
}

install_git() {
    sudo aptitude install git
}

install_server() {
    # Install Apache2 with WSGI
    sudo aptitude install apache2 libapache2-mod-wsgi
}

install_python() {
    # Install Python Package Installer
    sudo apt-get install python-pip
}

install_django() {
    # Install Django
    sudo pip install -e git://github.com/django/django.git@#egg=django-dev
}

build_essential() {
    # Install Build Essential
    sudo aptitude install build-essential
}

install_postgresql() {
    # Install PostgresSQL server/clinet and PyGreSQL
    sudo aptitude install postgresql postgresql-client postgresql-contrib python-pygresql

    # Install Postgresql-dev all (extension build tool) to build psycopg extension
    sudo aptitude install postgresql-server-dev-all

    # Install Psycopg, Python Dev 2.7 so the Django App can connect to Postgres
    sudo aptitude install python2.7-dev; sudo easy_install psycopg2
}

configure_apache() {
    # Configure Apache so that is uses WSGI.
    cat <<EOF | sudo tee /etc/apache2/httpd.conf
Alias /static/ /home/ubuntu/$NAME/static/

<Directory /home/ubuntu/$NAME/static>
Order deny, allow
Allow from all
</Directory>

WSGIScriptAlias / /home/ubuntu/$NAME/apache/django.wsgi
EOF
}

setup_postgresql() {
    sudo su postgres -c psql template1
    ALTER USER postgres WITH PASSWORD 'password';
    \q

    sudo passwd -d postgres
    sudo su postgres -c passwd

    sudo su postgres -c psql template1
    CREATE USER WITH denigma PASSWORD 'password';
    CREATE DATABASE db;
    GRANT ALL PRIVILEGES ON DATABASE db to denigma;
    \q

    cat <<EOF | sudo tee /etc/postgresql/9.1/main/pg_hba.conf
local   db     denigma                         md5
EOF
    sudo service postgresql restart
}

clone {
    git clone $REPO
}

configure_settings(){

}

symlink(){
    ln -s /usr/lib/pymodules/python2.7/django/contrib/admin/media /home/ubuntu/appointly/static/admin
}

syncdb() {
    ./manage.py syncdb
}

restart_server() {
    sudo /etc/init.d/apache2 restart
}

update_syste()
install_git
install_server()
install_python()
install_django()
build_essential()
symlink()
syncdb()
restart_server()
