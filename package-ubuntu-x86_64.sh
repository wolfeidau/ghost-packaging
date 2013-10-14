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
mkdir -p ${temp_dir}/etc/init
mkdir -p ${temp_dir}/var/lib/ghost 
mkdir -p ${temp_dir}/var/log/ghost 

# copy package files
cp -r ${base_dir}/ubuntu/ghost.upstart ${temp_dir}/etc/init/ghost.conf

# build ghost
grunt

# clear out development modules
rm -r node_modules || true
npm install --production

# sync over the data from the current directory to the build path
rsync -axvr --exclude .git --exclude dist --exclude content/data --exclude .sass-cache . ${install_path}

# set the package revision along with the app version
revision="1"
version="$(node -e "console.log(require('./package.json').version)")-${revision}"

# use fpm to build the package
fpm -s dir -t deb -n ghost \
  --after-install ${base_dir}/ubuntu/ghost.postinst \
  --deb-compression xz --deb-user root --deb-group root \
  -v "${version}-${revision}" --category web  -m "Mark Wolfe<mark@wolfe.id.au>" \
  --url http://tryghost.org --description "Just a blogging platform." \
  -d 'nodejs' -C ${temp_dir} -a amd64 \
  -p dist/ghost-${version}ubuntu_amd64.deb  opt/ghost etc/init var

npm install
