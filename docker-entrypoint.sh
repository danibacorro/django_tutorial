#!/bin/bash

while ! mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST}  -e ";" ; do
    sleep 1
done

if [ "$PRODUCCION" != "true" ]; then
    python3 manage.py migrate && python3 manage.py createsuperuser --noinput

python3 manage.py runserver 0.0.0.0:3000
