#!/bin/bash

# exit if there is an error
set -e

# build paths
temp_dir=$(mktemp -d)
install_path=${temp_dir}/opt/ghost

# packaging path
base_dir=$(dirname $0)

# prepare the tree
mkdir -p ${temp_dir}/opt/ghost
mkdir -p ${temp_dir}/etc/service
mkdir -p ${temp_dir}/var/lib/ghost 
mkdir -p ${temp_dir}/var/log/ghost 

# copy package files
cp -r ${base_dir}/debian/runit/ghost ${temp_dir}/etc/service

# setup runit to roll the logs daily
echo '86400' > ${temp_dir}/var/lib/ghost/config

# sync over the data from the current directory to the build path
rsync -axvr --exclude .git --exclude dist --exclude content/data --exclude .sass-cache . ${install_path}

# set the package revision along with the app version
revision="1"
version="$(node -e "console.log(require('./package.json').version)")-${revision}"

# use fpm to build the package
fpm -s dir -t deb -n ghost --after-install ${base_dir}/debian/ghost.postinst --deb-compression xz --deb-user root --deb-group root  -v "${version}-${revision}" --category web  -m "Mark Wolfe<mark@wolfe.id.au>" --url http://tryghost.org --description "Just a blogging platform.." -d 'nodejs' -d 'runit' -C ${temp_dir} -a armhf -p dist/ghost-${version}_armhf.deb  opt/ghost etc/service var
