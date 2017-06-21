# Docker-ized PhantomJS

Turns out PhantomJS is really picky about having a full glibc installed.

This is a Dockerfile to build [PhantomJS](https://github.com/ariya/phantomjs) from source, then dockerize it to use on Linices without glibc e.g. Alpine.

#### Acknowledegments ####

This is a mashup of:
https://github.com/rosenhouse/phantomjs2
https://github.com/fgrehm/docker-phantomjs2

## How do I get the image?

Build it yourself, if you have some time on your hands:

```bash
docker build -t phantomjs-dockerizer .
```

Pull it from docker repo, if you're in a hurry:

```bash
docker pull quay.io/skuid/phantomjs-dockerizer:latest
```

## How do I use it?

#### Option 0: Run it from inside a Docker container

```bash
docker run quay.io/skuid/phantomjs-dockerizer phantomjs -v
```


#### Option B: Extract the phantomjs binary so you can run it without Docker

1. Install [run-time dependencies](https://github.com/rosenhouse/phantomjs2/blob/master/Dockerfile#L10)

        apt-get install -y libicu-dev libfontconfig1-dev libjpeg-dev libfreetype6


2. Extract binary

        docker run -name temp quay.io/skuid/phantomjs-dockerizer
        docker cp temp:phantomjs/bin/phantomjs ~/phantomjs


3. Run

        ~/phantomjs -v
        2.0.0


#### Option III: Extract a dockerized phantomjs that can be installed in e.g. Alpine Linux

Nota Bene: the archive contains glibc in its normal habitat: /lib64, /lib, /usr/lib, etc. Also /etc/nsswitch.conf. Etc. If your target already has those directories, performing the below might clobber things your system needs to run. You have been warned.

    docker run -name temp quay.io/skuid/phantomjs-dockerizer
    docker cp temp:/dockerized-phantomjs.tar.gz ./

    # < copy tar.gz file to your container, VM, or sweet linux gaming PC >
    # Untar the contents in root dir BECAUSE YOU DEFINITELY KNOW WHAT YOU'RE DOING

    tar -xzvf dockerized-phantomjs.tar.gz -C /
