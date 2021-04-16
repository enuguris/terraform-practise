#!/bin/bash

new_instance=$1

template_dir="ec2-template"

if [ ! -d ${new_instance} ]; then
  #create directory for the new ec2 instance
  mkdir ${new_instance}
  #copy files from template directory to new ec2 instance directory
  for tf_file in main.tf outputs.tf variables.tf locals.tf; do
    cp ${template_dir}/${tf_file} ${new_instance}/${tf_file}
  done
  #create new ec2 instance module tf file
  sed "s/instance/${new_instance}/g" ${template_dir}/instance.tf > ${new_instance}.tf
else
  echo "${new_instance} directory exists already. Exiting."
  exit 0
fi

