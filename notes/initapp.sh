#!/usr/bin/env bash

set -x
export PATH=/home/centos/.local/bin:$PATH
cd /home/centos/notes/
pipenv install
pipenv install --dev python-dotenv
pipenv install psycopg2-binary Flask-SQLAlchemy Flask-Migrate
pipenv install mistune
source .env
export FLASK_ENV=development
export FLASK_APP='/home/centos/notes/.'
pipenv run flask db init
pipenv run flask db migrate
pipenv run flask db upgrade
sudo chown centos:centos /etc/systemd/system
sudo passwd -d centos

cat << EOF > /etc/systemd/system/webapp.service
    [Unit]
    Description="Python web app"
    Documentation=None
    Requires=network-online.target
    After=network-online.target

    [Service]
    User=centos
    Group=centos
    WorkingDirectory=/home/centos/notes/
    ExecStart=/home/centos/.local/bin/pipenv run flask run --host=0.0.0.0 --port=3000
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536


    [Install]
    WantedBy=multi-user.target

EOF
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp
systemctl status webapp
set +x