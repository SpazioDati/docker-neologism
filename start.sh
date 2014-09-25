
sed -i "s/__SERVER_NAME__/$SERVER_NAME/g" /etc/apache2/sites-available/neologism.conf

exec /etc/apache2/foreground.sh
