docker-neologism
================

This docker will deploy a full installation of [neologism](https://www.drupal.org/project/neologism), a lightweight web-based vocabulary editor and publishing tool built with Drupal. 

## Launching the docker
Use this command to launch the docker, inserting the appropriate parameters server_port, web_logs_dir and database_data_dir. If you are fine with the default settings (good for local developement) you can directly use this, which will download the latest image from the docker registry, otherwise read the next section.
```
docker run -d --name='neologism_web'                    \
    -h neologism                                        \
    -p 0.0.0.0:<server_port>:80                         \
    -v <web_logs_dir>:/var/log/apache2                  \
    -v <database_data_dir>:/var/lib/mysql               \
    spaziodati/neologism
```

## Personalizing the docker settings
In order to customize the docker settings you need to have a copy of the repository on your machine; you can obtain it via git (`git clone https://github.com/SpazioDati/docker-neologism.git`) or by downloading [this zip archive](https://github.com/SpazioDati/docker-neologism/archive/master.zip).

The section which contains the customizable parameters is shown below, along with the default values:
```
ENV DB_USER ontology
ENV DB_NAME ontology
ENV DB_PASS password
ENV SERVER_NAME localhost
ENV OUR_SERVER_PROTOCOL http
ENV MYSQL_USER admin
ENV MYSQL_PASS password
```

You might want to change `SERVER_NAME` and `OUR_SERVER_PROTOCOL` to match your domain name. The other parameters are the database name, username and password for the web site and for the administrator.

When you have finished configuring the parameters, build the docker image with the following command (from the directory which contains the repository)

```
docker build --tag='spaziodati/neologism' .
```
