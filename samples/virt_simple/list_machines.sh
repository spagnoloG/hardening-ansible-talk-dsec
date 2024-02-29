#!/bin/bash


for f in `ls ./.vagrant/machines/` ; do
    vagrant ssh-config $f
done
