FROM debian:stable-slim
# https://github.com/GoogleChrome/puppeteer/blob/a052b9e7740fdc6648ca5241614d10cc29e99fc3/docs/troubleshooting.md
# https://github.com/joelgriffith/browserless/blob/master/Dockerfile
# https://github.com/GoogleChrome/rendertron/blob/master/Dockerfile
# https://github.com/moonlightwork/renderer/blob/master/Dockerfile
# https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
# https://peter.sh/experiments/chromium-command-line-switches/

LABEL name "aichaegh1Piechahz0naeh0z"

ARG DEBIAN_FRONTEND=noninteractive

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /usr/bin/tini

RUN chmod +x /usr/bin/tini

RUN apt-get update -qqy \
  && apt-get -qqy install \
       gnupg wget ca-certificates apt-transport-https unzip \
       libfontconfig1 fonts-liberation ttf-wqy-zenhei \
       fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV CHROME_DIR /opt/google/
ENV CHROME_REVISION 529187
# "/usr/bin/google-chrome-unstable"
ENV CHROME_PATH /opt/google/chrome-linux/chrome

# https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F529187%2Fchrome-linux.zip?generation=1515975355063695&alt=media
# https://github.com/GoogleChrome/puppeteer/blob/b8e0d626f37c6c5e676b144d2b39ee29259d0d8a/lib/BrowserFetcher.js

RUN wget -q -O chrome-linux.zip https://storage.googleapis.com/chromium-browser-snapshots/Linux_x64/$CHROME_REVISION/chrome-linux.zip \
  && mkdir -p $CHROME_DIR \
  && unzip -qq chrome-linux.zip -d $CHROME_DIR \
  && rm chrome-linux.zip

# RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
#   && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
#   && apt-get update -qqy \
#   && apt-get -qqy install google-chrome-stable \
#   && rm /etc/apt/sources.list.d/google-chrome.list \
#   && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN useradd headless --shell /bin/bash --create-home \
  && usermod -a -G sudo headless \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'headless:nopassword' | chpasswd

RUN mkdir -p /data/{core,user,cache,home,crash} && chown -R headless:headless /data

#USER headless

EXPOSE 80

# 65.0.3322.3
# https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/529187/
# https://www.chromium.org/getting-involved/download-chromium
# https://chromium-review.googlesource.com/c/chromium/src/+/952522
# https://omahaproxy.appspot.com/

ENTRYPOINT ["/usr/bin/tini", "--", \
            $CHROME_PATH, \
            "--disable-dev-shm-usage", \
            "--disable-background-networking", \
            "--disable-background-timer-throttling", \
            "--disable-breakpad", \
            "--disable-client-side-phishing-detection", \
            "--disable-default-apps", \
            "--disable-extensions", \
            # TODO: Support OOOPIF. @see https://github.com/GoogleChrome/puppeteer/issues/2548
            "--disable-features=site-per-process", \
            "--disable-hang-monitor", \
            "--disable-popup-blocking", \
            "--disable-prompt-on-repost", \
            "--disable-sync", \
            "--disable-translate", \
            "--metrics-recording-only", \
            "--safebrowsing-disable-auto-update", \
            "--enable-automation", \
            "--password-store=basic", \
            "--use-mock-keychain", \
            "--mute-audio", \
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

            # "--host=", \
            # "--no-first-run", \
            # "--ignore-ssl-errors", \
            # https://groups.google.com/a/chromium.org/forum/#!topic/devtools-reviews/wnCpqPbWqiU
