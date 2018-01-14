FROM debian:stable-slim

LABEL name "aichaegh1Piechahz0naeh0z"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qqy \
  && apt-get -qqy install \
       dumb-init gnupg wget ca-certificates apt-transport-https \
       ttf-wqy-zenhei \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-unstable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN useradd headless --shell /bin/bash --create-home \
  && usermod -a -G sudo headless \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'headless:nopassword' | chpasswd

#USER headless

RUN mkdir -p /data/{path,user,cache}

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--", \
            "/usr/bin/google-chrome-unstable", \
            "--disable-dev-shm-usage", \
            "--use-gl=swiftshader", \
            "--headless", \
            "--hide-scrollbars", \
            "--no-sandbox", \
            "--deterministic-fetch", \
            "--remote-debugging-address=0.0.0.0", \
            "--remote-debugging-port=80", \
            "--ignore-certificate-errors", \
            "--data-path=/data", \
            "--homedir=/data", \
            "--disk-cache-dir=/data", \
            "--user-data-dir=/data"]

            # "--user-data-dir=/data/user"
            # "--js-flags=--optimize_for_size --max_old_space_size=460 --gc_interval=100", \
            # "--disable-software-rasterizer", \
            # "--single-process", \
            # "--no-zygote", \
            # "--enable-logging", \
            # "--log-level=0", \
            # "--v=99", \
