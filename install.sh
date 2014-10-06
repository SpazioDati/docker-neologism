#!/bin/bash

function pause() {
    read -p "$*"
}

function ask() {
    # $1: prompt for the user
    # $2: default value
    # returns: user's answer or default value

    local answer=""
    read -p "$1 (default is $2):" answer

    if [ -z "$answer" ]; then
        answer="$2"
    fi

    echo $answer
}

function ask_path() {
    # $1: prompt for the user
    # $2: default value
    # returns: absolute path or default value

    path=$(ask "$1" "$2")

    mkdir -p $path
    echo $(cd $path; pwd)
}

server_name=$(ask "Web server domain name" "localhost")
server_port=$(ask "Web server port" "8086")
server_protocol=$(ask "Web server protocol" "http")
web_logs_dir=$(ask_path "Web server logs folder" "/srv/neologism/web_logs")
db_dir=$(ask_path "Database data folder" "/srv/neologism/db")
db_logs_dir=$(ask_path "Database logs folder" "/srv/neologism/db_logs")
db_user=$(ask "Database username for ontology user" "ontology")
db_pass=$(ask "Database password for ontology user" "password")
db_admin_pass=$(ask "Database password for admin user" "password")
db_name=$(ask "Ontology database name" "ontology")

echo "Server Settings:" > settings.txt
echo ""  >> settings.txt
echo "Web server admin username: admin" >> settings.txt
echo "Web server admin password: password" >> settings.txt
echo "Web server domain name: $server_name" >> settings.txt
echo "Web server port: $server_port" >> settings.txt
echo "Web server protocol: $server_protocol" >> settings.txt
echo "Web server logs folder: $web_logs_dir" >> settings.txt
echo "Database data folder: $db_dir" >> settings.txt
echo "Database logs folder: $db_logs_dir" >> settings.txt
echo "Database username for ontology user: $db_user" >> settings.txt
echo "Database password for ontology user: $db_pass" >> settings.txt
echo "Database username for admin user: admin" >> settings.txt
echo "Database password for admin user: $db_admin_pass" >> settings.txt
echo "Ontology database name: $db_name" >> settings.txt

echo
echo "*** Setup settings saved in settings.txt ***"
pause 'Press [Enter] key to continue...'

# we don't need the resulting containers as we are only
# interested in the permanent changes made to $db_dir
docker run --rm                                             \
    -v "$db_dir":/var/lib/mysql                             \
    tutum/mysql                                             \
    /bin/bash -c "/usr/bin/mysql_install_db"

docker run --rm                                             \
    -v "$db_dir":/var/lib/mysql                             \
    -e MYSQL_PASS="$db_admin_pass"                          \
    tutum/mysql                                             \
    /bin/bash -c "/create_mysql_admin_user.sh"

if [ -f ./setup.sql ]; then
    echo "Using the database dump found in folder $(pwd)"
    cp ./setup.sql /tmp/setup.sql
else
    echo "Downloading the database dump"
    wget -O /tmp/setup.sql https://raw.githubusercontent.com/SpazioDati/docker-neologism/master/setup.sql
fi

sed -i -e "s/{{db_user}}/$db_user/g" \
       -e "s/{{db_pass}}/$db_pass/g" \
       -e "s/{{db_name}}/$db_name/g" \
       /tmp/setup.sql

docker run --rm                                             \
    -v /tmp:/tmp                                            \
    -v "$db_dir":/var/lib/mysql                             \
    -e MYSQL_PASS="$db_admin_pass"                          \
    tutum/mysql                                             \
    /bin/bash -c "/import_sql.sh admin '$db_admin_pass' /tmp/setup.sql"

# generate run script
echo "# this script launches the two dockers \\" > run.sh
echo "docker run -d --name='neologism_db' \\" >> run.sh
echo "    -p 127.0.0.1::3306 \\" >> run.sh
echo "    -v '$db_dir':/var/lib/mysql \\" >> run.sh
echo "    -v '$db_logs_dir':/var/log/mysql \\" >> run.sh
echo "    -e MYSQL_PASS='$db_admin_pass' \\" >> run.sh
echo "    tutum/mysql" >> run.sh
echo "" >> run.sh
echo "docker run -d --name='neologism_web' \\" >> run.sh
echo "    -h neologism \\" >> run.sh
echo "    --link neologism_db:db \\" >> run.sh
echo "    -p 0.0.0.0:$server_port:80 \\" >> run.sh
echo "    -v '$web_logs_dir':/var/log/apache2 \\" >> run.sh
echo "    -e SERVER_NAME='$server_name' \\" >> run.sh
echo "    -e OUR_SERVER_PROTOCOL='$server_protocol' \\" >> run.sh
echo "    -e DB_USER='$db_user' \\" >> run.sh
echo "    -e DB_PASS='$db_pass' \\" >> run.sh
echo "    -e DB_NAME='$db_name' \\" >> run.sh
echo "    spaziodati/neologism" >> run.sh

chmod u+x run.sh
echo "You can now launch the dockers with ./run.sh"
