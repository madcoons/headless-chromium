FROM ubuntu:22.04

RUN apt-get update -y
RUN apt-get install -y curl git lsb-core python3 sudo
WORKDIR /app
RUN git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH=$PATH:/app/depot_tools
RUN mkdir /app/chromium
WORKDIR /app/chromium
RUN fetch --nohooks --no-history chromium
WORKDIR /app/chromium/src
RUN sed -i s/snapcraft/curl/ ./build/install-build-deps.sh
RUN ./build/install-build-deps.sh --no-prompt

RUN sed -i "s/'-C', sysroot/'-C', sysroot, '--no-same-owner'/" ./build/linux/sysroot_scripts/install-sysroot.py
RUN ./build/linux/sysroot_scripts/install-sysroot.py --arch=amd64

RUN gclient runhooks

RUN mkdir -p out/Headless
RUN echo 'import("//build/args/headless.gn")' > out/Headless/args.gn
RUN echo "is_debug = false" >> out/Headless/args.gn
RUN echo "enable_gpu_client_logging = true" >> out/Headless/args.gn
RUN echo "enable_nacl = false" >> out/Headless/args.gn
RUN echo "use_v8_context_snapshot = false" >> out/Headless/args.gn
RUN gn gen out/Headless
RUN chmod +x /app/chromium/src/third_party/node/linux/node-linux-x64/bin/node
# RUN ls -l /app/chromium/src/third_party/node/linux/node-linux-x64/bin/node && exit 1
RUN ninja -C out/Headless headless_shell
# RUN ls out/Headless && exit 1
EXPOSE 9222
ENTRYPOINT out/Headless/headless_shell --no-sandbox --disable-dev-shm-usage --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 http://www.google.com
