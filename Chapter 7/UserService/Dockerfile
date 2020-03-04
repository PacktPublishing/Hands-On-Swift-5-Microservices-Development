FROM swift:5.1.2 as builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env

RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev \
  && rm -r /var/lib/apt/lists/*

ARG env
RUN mkdir /root/.ssh/
RUN apt-get -qq update && apt-get install -y \
libssl-dev zlib1g-dev \
&& rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib
RUN swift package --enable-pubgrub-resolver resolve && \
    swift build -c release --verbose && \
    mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:18.04
ARG env
# DEBIAN_FRONTEND=noninteractive for automatic UTC configuration in tzdata
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
libatomic1 libicu60 libxml2 libcurl4 libz-dev libbsd0 tzdata \
&& rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/bin/Run .
#COPY --from=builder /build/bin/*.so /usr/lib/
COPY --from=builder /build/lib/* /usr/lib/

ENTRYPOINT ./Run serve --hostname 0.0.0.0 --port 8080
