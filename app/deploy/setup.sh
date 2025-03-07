#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/Scottman625/CareDjango-vps.git'

PROJECT_BASE_PATH='/usr/local/apps/care168'

PROJECT_PATH='/usr/local/apps/care168/app'

echo "Installing dependencies..."
apt-get update
echo "Hello..."
apt-get install -y python3-dev python3-venv sqlite python3-pip supervisor nginx git

# Create project directorycd
mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Create virtual environment
mkdir -p $PROJECT_BASE_PATH/env
python3 -m venv $PROJECT_BASE_PATH/env

apt-get install python3-pip

# Install python packages
$PROJECT_BASE_PATH/env/bin/python3 -m pip install -r $PROJECT_BASE_PATH/requirements.txt
$PROJECT_BASE_PATH/env/bin/python3 -m pip install uwsgi

# Run migrations and collectstatic
cd $PROJECT_PATH
$PROJECT_BASE_PATH/env/bin/python3 manage.py migrate
$PROJECT_BASE_PATH/env/bin/python3 manage.py collectstatic --noinput

# Configure supervisor
cp $PROJECT_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/care168_profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart care168_profiles_api

# Configure nginx
cp $PROJECT_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/care168_profiles_api.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/care168_profiles_api.conf /etc/nginx/sites-enabled/care168_profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
