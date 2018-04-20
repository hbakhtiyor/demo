FROM debian:stable-slim
# https://github.com/GoogleChrome/puppeteer/blob/a052b9e7740fdc6648ca5241614d10cc29e99fc3/docs/troubleshooting.md
# https://github.com/joelgriffith/browserless/blob/master/Dockerfile
# https://github.com/GoogleChrome/rendertron/blob/master/Dockerfile

LABEL name "aichaegh1Piechahz0naeh0z"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qqy \
  && apt-get -qqy install \
       dumb-init gnupg wget ca-certificates apt-transport-https \
       fonts-noto fonts-noto-color-emoji fonts-noto-cjk-extra \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN useradd headless --shell /bin/bash --create-home \
  && usermod -a -G sudo headless \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'headless:nopassword' | chpasswd

RUN mkdir -p /data/{core,user,cache,home,crash} && chown -R headless:headless /data

USER headless

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init", "--", \
            "/usr/bin/google-chrome-stable", \
            "--disable-dev-shm-usage", \
            "--headless", \
            "--hide-scrollbars", \
            "--no-sandbox", \
            "--disable-setuid-sandbox", \
            "--disable-web-security", \
            "--remote-debugging-address=0.0.0.0", \
            "--remote-debugging-port=80", \
            "--ignore-certificate-errors", \
            "--ignore-certificate-errors-spki-list", \
            "--data-path=/data/core", \
            "--homedir=/data/home", \
            "--disk-cache-dir=/data/cache", \
            "--crash-dumps-dir=/data/crash", \
            "--user-data-dir=/data/user"]

            # "--disable-gpu", \
            # "--no-referrers", \
            # "--virtual-time-budget", \
            # "--enable-crash-reporter", \
            # "--deterministic-fetch", \
            # "--use-gl=swiftshader", \
            # "--js-flags=--optimize_for_size --max_old_space_size=460 --gc_interval=100", \
            # "--disable-software-rasterizer", \
            # "--single-process", \
            # "--no-zygote", \
            # "--enable-logging", \
            # "--log-level=0", \
            # "--v=99", \
