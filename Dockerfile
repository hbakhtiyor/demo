FROM debian:stable-slim

LABEL name "demo"

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

RUN mkdir /data

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--", \
            "/usr/bin/google-chrome-unstable", \
            "--disable-gpu", \
            "--headless", \
            "--hide-scrollbars", \
            "--no-sandbox", \
            "--deterministic-fetch", \
            "--js-flags='--max-old-space-size=500'", \
            "--remote-debugging-address=0.0.0.0", \
            "--remote-debugging-port=80", \
            "--user-data-dir=/data"]
