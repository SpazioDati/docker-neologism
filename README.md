docker-neologism
================

This docker will deploy a full installation of [neologism](https://www.drupal.org/project/neologism), a lightweight web-based vocabulary editor and publishing tool built with Drupal. 

### Quick Installation

    $SHELL <(curl -sL https://raw.githubusercontent.com/SpazioDati/docker-neologism/master/install.sh)

The script will ask you some configuration parameters before setting up a database for neologism. The current configuration will be saved to `settings.txt` and a script called `run.sh` will be created in the current directory for launching the two dockers (mysql + neologism).

### Launching the dockers:
First, the database needs to be launched:

    docker run -d --name='neologism_db'                     \
        -p 127.0.0.1::3306                                  \
        -v "$db_dir":/var/lib/mysql                         \
        -v $db_logs_dir":/var/log/mysql                     \
        -e MYSQL_PASS='$db_admin_pass'                      \
        tutum/mysql

Then, launch the web server:

    docker run -d --name='neologism_web'                    \
        -h neologism                                        \
        --link neologism_db:db                              \
        -p 0.0.0.0:$server_port:80                          \
        -v "$web_logs_dir":/var/log/apache2                 \
        -e SERVER_NAME='$server_name'                       \
        -e OUR_SERVER_PROTOCOL='$server_protocol'           \
        -e DB_USER='$db_user'                               \
        -e DB_PASS='$db_pass'                               \
        -e DB_NAME='$db_name'                               \
        spaziodati/neologism

If you followed the quick installation procedure: you were asked all of these parameters during the procedure itself, they have been saved to `settings.txt`; you can also use the script `run.sh` which will run the dockers with these parameters.


### Manual installation
First, three folders have to be created: mysql data, mysql log files and web server log files; following, the database structure has to be created issuing the following command:

    docker run --rm                                             \
        -v "$db_dir":/var/lib/mysql                             \
        tutum/mysql                                             \
        /bin/bash -c "/usr/bin/mysql_install_db"

After this, create an administrator user (this will be needed in the next step):

    docker run --rm                                             \
        -v "$db_dir":/var/lib/mysql                             \
        -e MYSQL_PASS="$db_admin_pass"                          \
        tutum/mysql                                             \
        /bin/bash -c "/create_mysql_admin_user.sh"

The next step is to import the database structure for neologism. You can use the dump coming with the Git repository or directly download it:

    wget /tmp/setup.sql https://raw.githubusercontent.com/SpazioDati/docker-neologism/master/setup.sql

This file has to be modified to include username, password and database name which will be used by neologism. The following command will do the appropriate replacements:

    sed -e "s/{{db_user}}/$db_user/g"       \
        -e "s/{{db_pass}}/$db_pass/g"       \
        -e "s/{{db_name}}/$db_name/g"       \
        -i /tmp/setup.sql

Or, in alternative, edit it manually and replace the placeholders with the appropriate values; the section which has to be modified is located at the beginning of the file:

    CREATE USER '{{db_user}}'@'localhost';
    GRANT ALL ON {{db_name}}.* TO '{{db_user}}'@'localhost'
        IDENTIFIED BY '{{db_pass}}';
    
    CREATE USER '{{db_user}}'@'%';
    GRANT ALL ON {{db_name}}.* TO '{{db_user}}'@'%'
        IDENTIFIED BY '{{db_pass}}';
    FLUSH PRIVILEGES;
    
    CREATE DATABASE /*!32312 IF NOT EXISTS*/ `{{db_name}}` /*!40100 DEFAULT CHARACTER SET utf8 */;
    
    USE `{{db_name}}`;

Once the dump contains the correct values, import the database:

    docker run --rm                                             \
        -v /tmp:/tmp                                            \
        -v "$db_dir":/var/lib/mysql                             \
        -e MYSQL_PASS="$db_admin_pass"                          \
        tutum/mysql                                             \
        /bin/bash -c "/import_sql.sh admin '$db_admin_pass' /tmp/setup.sql"


Note that the docker needs have access to the database dump; be sure to mount the correct directory (the `-v /tmp:/tmp` part, because that is the path we used in this guide) and to specify the correct path to the dump.

Setup is now complete and you are ready to launch the dockers.


### Parameter reference
Here is the list of required parameters along with a simple description:

 - Web server admin username: `admin`
 - Web server admin password: `password`
 - `$server_name`: Web server domain name
 - `$server_port`: Web server port
 - `$server_protocol`: Web server protocol (`http` or `https`)
 - `$web_logs_dir`: Web server logs folder
 - `$db_dir`: Database data folder
 - `$db_logs_dir`: Database logs folder
 - `$db_user`: Database username for ontology user
 - `$db_pass`: Database password for ontology user
 - `$db_admin_pass`: Database password for admin user
 - `$db_name` Ontology database name

