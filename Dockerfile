FROM ubuntu:14.04

MAINTAINER adam.cofer@skuid.com

# Dependencies we need for building phantomjs
ENV buildDependencies\
  wget unzip python build-essential g++ flex bison gperf\
  ruby perl libsqlite3-dev libssl-dev libpng-dev

# Dependencies we need for running phantomjs
ENV phantomJSDependencies\
  libicu-dev libfontconfig1-dev libjpeg-dev libfreetype6

# dependencies for dockerize
ENV dockerizeDependencies\
  python-pip curl git rsync xfonts-base ttf-mscorefonts-installer

ENV noclobberList\
  bin etc/group etc/passwd usr/bin

ENV phantom_version 2.1.1

# Compiling phantomjs
RUN \
    # Installing dependencies
echo 'deb http://br.archive.ubuntu.com/ubuntu/ trusty multiverse' >> /etc/apt/sources.list \
&&  echo 'deb-src http://br.archive.ubuntu.com/ubuntu/ trusty multiverse' >> /etc/apt/sources.list \
&&  apt-get update -yqq \
&&  apt-get install -fyqq ${buildDependencies} ${phantomJSDependencies} ${dockerizeDependencies} \
&&  git clone git://github.com/ariya/phantomjs.git \
&&  cd phantomjs \
&&  git checkout ${phantom_version} \
&&  git submodule init \
&&  git submodule update \
    # Building phantom
&&  python build.py --confirm --release --silent \
    # Removing everything but the binary
&&  ls -A | grep -v bin | xargs rm -rf \
    # Symlink phantom so that we are able to run `phantomjs`
&&  ln -s /phantomjs/bin/phantomjs /usr/local/share/phantomjs \
&&  ln -s /phantomjs/bin/phantomjs /usr/local/bin/phantomjs \
&&  ln -s /phantomjs/bin/phantomjs /usr/bin/phantomjs \
    # Checking if phantom works
&&  phantomjs -v \
# make a 'dockerized' binary using just the static re-linking bits of https://github.com/larsks/dockerize
&&  pip install dockerize \
&&  mkdir /dockerized-phantomjs \
&&  /usr/local/bin/dockerize --no-build --output-dir /dockerized-phantomjs \
  --entrypoint $(which phantomjs) \
  --add-file /bin/dash /bin/sh \
  --add-file /etc/fonts /etc \
  --add-file /etc/ssl /etc \
  --add-file /usr/share/fonts /usr/share \
  --verbose \
  $(which phantomjs) \
  /usr/bin/curl \
&& cd /dockerized-phantomjs \
  # Don't clobber files in alpine
&& rm -r Dockerfile ${noclobberList} \
&& tar --numeric-owner -zcf /dockerized-phantomjs.tar.gz * \
&& cd / \
&& rm -rf dockerized-phantomjs \
    # Removing build dependencies, clean temporary files
&&  apt-get purge -yqq ${buildDependencies} ${dockerizeDependencies} \
&&  apt-get autoremove -yqq \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


CMD \
    echo "phantomjs binary is located at /phantomjs/bin/phantomjs"\
&&  echo "just run 'phantomjs'"\
&&  echo "dockerized phantomjs is at /dockerized-phantomjs.tar.gz"\
&&  echo "docker run --name temp quay.io/skuid/phantomjs-dockerizer && docker cp temp:/dockerized-phantomjs.tar.gz ./"\
&&  echo "  - that tar file should be untarred into root dir with 'tar -xzvf dockerized-phantomjs.tar.gz -C /'"
