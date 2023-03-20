FROM ubuntu:22.04
WORKDIR /var/task

RUN apt-get update -y && apt-get install -y libicu-dev ca-certificates curl libnspr4 libnss3 libexpat1 libfontconfig1 libuuid1 && apt-get clean

# RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome-stable_current_x86_64.deb \
#   && apt-get update -y && apt-get install -y ./google-chrome-stable_current_x86_64.deb \
#   && rm google-chrome-stable_current_x86_64.deb \
#   && apt-get clean

COPY chromium_headless chromium_headless
RUN chmod +x chromium_headless/headless_shell
# RUN ./chromium_headless/headless_shell --disable-dev-shm-usage --no-sandbox --use-gl=angle --use-angle=swiftshader https://www.google.com && exit 1
# RUN ls /tmp/google.pdf && exit 1

ENV HOME=/tmp/home
ENTRYPOINT ./chromium_headless/headless_shell --disable-dev-shm-usage --no-sandbox https://www.google.com
