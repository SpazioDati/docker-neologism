docker-neologism
================

This docker will deploy a full installation of [neologism](https://www.drupal.org/project/neologism), a lightweight web-based vocabulary editor and publishing tool built with Drupal. 

## Launching the docker
Use this command to launch the docker, inserting the appropriate parameters server_port (needed), web_logs_dir (optional) and database_data_dir (needed if you want to keep the database when the container is shut down). If you are fine with the default settings (good for local developement) you can directly use this, which will download the latest image from the docker registry, otherwise read the next section.
```
    docker run -d                                           \
        -p 0.0.0.0:8080:80                                  \
        -v <web_logs_dir>:/var/log/apache2                  \
        -v <database_data_dir>:/var/lib/mysql               \
        spaziodati/neologism
```

## Personalizing the docker settings
In order to customize the docker settings you need to have a copy of the repository on your machine; you can obtain it via git (`git clone https://github.com/SpazioDati/docker-neologism.git`) or by downloading [this zip archive](https://github.com/SpazioDati/docker-neologism/archive/master.zip).

The parameters you can customize are in the Dockerfile and are passed as environment variables to the services which need them. Here's the section in the Dockerfile:
```
    # to change these you have to rebuild the image
    ENV DB_USER ontology
    ENV DB_NAME ontology
    ENV DB_PASS password
    ENV MYSQL_USER admin
    ENV MYSQL_PASS password

    # the following can be changed when running the docker via -e, --env or --env-file
    ENV SERVER_NAME localhost
    ENV OUR_SERVER_PROTOCOL http
    ENV OUR_SERVER_PORT 8080
```

You might want to change `SERVER_NAME`, `OUR_SERVER_PROTOCOL` and `OUR_SERVER_PORT` to match your domain setup (these settings are used by apache to build the correct domain name). The other parameters are the database name, username and password for the web site and for the mysql database administrator. The website administrator's username is `admin` and its password is `password`.

When you have finished configuring the parameters, build the docker image with the following command (from the directory which contains the repository):

```
    docker build --tag='spaziodati/neologism' .
```
