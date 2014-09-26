docker-neologism
================

This docker will deploy a full installation of [neologism](https://www.drupal.org/project/neologism), a lightweight web-based vocabulary editor and publishing tool built with Drupal. 

### Install
Simply

    $SHELL <(curl -sL https://raw.githubusercontent.com/SpazioDati/docker-neologism/master/install.sh)

The script will ask you some configuration parameters before setting up a database for neologism. The current configuration will be saved to `./settings.txt` and a script called `run.sh` will be created in the current directory for launching the two dockers (mysql + neologism).
