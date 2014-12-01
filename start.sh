if [[ ! -d /var/lib/mysql/mysql ]]; then
    export STARTUP_SQL=/setup.sql
    sed '$ d' /run.sh > /createdb.sh
    /bin/bash /createdb.sh
    rm /createdb.sh
fi

source /etc/apache2/envvars && apache2
exec mysqld_safe
