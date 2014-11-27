#sed -i "s/__SERVER_NAME__/$SERVER_NAME/g" /etc/apache2/sites-available/neologism.conf
#exec /etc/apache2/foreground.sh

if [ -f /setup.sql ]; then
    export STARTUP_SQL=/setup.sql
    sed '$ d' /run.sh > /createdb.sh
    chmod +x /createdb.sh && /createdb.sh
    rm /setup.sql /createdb.sh
fi

source /etc/apache2/envvars && apache2
exec mysqld_safe
