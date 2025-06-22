# Set the base image to use for subsequent instructions
#checkov:skip=CKV_DOCKER_7: allow use of latest tag
FROM cgr.dev/chainguard/rust:latest AS build

LABEL org.opencontainers.image.source=https://github.com/yonasBSD/toolkit

#RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk --no-cache add cosign bash curl

# Run curl installs
RUN mkdir -p /usr/local/bin
RUN curl -fsSL https://get.comtrya.dev > comtrya.sh && sh comtrya.sh
RUN curl -fsSL https://just.systems/install.sh > just.sh && bash just.sh --to /usr/local/bin
RUN curl -fsSL https://taskfile.dev/install.sh > task.sh && sh task.sh -d -b /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh > trufflehog.sh && sh trufflehog.sh -v -b /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh > trivy.sh && sh trivy.sh -b /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh > binstall.sh && bash binstall.sh && mv /root/.cargo/bin/cargo-binstall /usr/local/bin

# Download from release assets
RUN curl -sL -o docker-assets-rcl.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-rcl.zip && unzip -jo docker-assets-rcl.zip -d /usr/local/bin
RUN curl -sL -o docker-assets-kcl.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-kcl.zip && unzip -jo docker-assets-kcl.zip -d /usr/local/bin
RUN curl -sL -o docker-assets-pipelight.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-pipelight.zip && unzip -jo docker-assets-pipelight.zip -d /usr/local/bin
RUN curl -sL -o docker-assets-hurl.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-hurl.zip && unzip -jo docker-assets-hurl.zip -d /usr/local/bin
RUN curl -sL -o docker-assets-dra.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-dra.zip && unzip -jo docker-assets-dra.zip -d /usr/local/bin
RUN curl -sL -o docker-assets-cargo-auditable.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-cargo-auditable.zip && unzip -jo docker-assets-cargo-auditable.zip -d /usr/local/bin
RUN curl -sL -o docker-assets-venom.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets-venom.zip && unzip -jo docker-assets-venom.zip -d /usr/local/bin

# Run cargo installs
#RUN cargo install --git https://github.com/ruuda/rcl rcl && mv /root/.cargo/bin/rcl /usr/local/bin
#RUN cargo install --git https://github.com/pipelight/pipelight && mv /root/.cargo/bin/pipelight /usr/local/bin
#RUN cargo install --git https://github.com/Orange-OpenSource/hurl hurl hurlfmt && mv /root/.cargo/bin/hurl* /usr/local/bin
#RUN cargo install --locked --git https://github.com/devmatteini/dra && mv /root/.cargo/bin/dra /usr/local/bin

# Run cargo-binstall
RUN cargo binstall -y --install-path /usr/local/bin cargo-about
RUN cargo binstall -y --install-path /usr/local/bin cargo-audit
RUN cargo binstall -y --install-path /usr/local/bin cargo-deny
RUN cargo binstall -y --install-path /usr/local/bin cargo-license
RUN cargo binstall -y --install-path /usr/local/bin dirstat-rs

# Run dra installs
# Some projects don't have binaries for arch that chainguard/wolfi-base uses
RUN dra download --automatic --install --output /usr/local/bin/b3sum BLAKE3-team/BLAKE3
RUN dra download --automatic typst/typst && mkdir typst && tar -xvf typst*tar.xz --directory typst --strip-components 1 && mv typst/typst /usr/local/bin && rm -rf typst
RUN dra download --automatic mitsuhiko/minijinja && mkdir minijinja && tar -xvf minijinja*tar.xz --directory minijinja --strip-components 1 && mv minijinja/minijinja-cli /usr/local/bin/minijinja && rm -rf minijinja
RUN dra download --automatic numtide/treefmt && mkdir treefmt && tar -xvf treefmt*tar.gz --directory treefmt && mv treefmt/treefmt /usr/local/bin && rm -rf treefmt


#checkov:skip=CKV_DOCKER_7: allow use of latest tag
FROM cgr.dev/chainguard/wolfi-base:latest

COPY --from=build /usr/local/bin /usr/local/bin
RUN chmod +x /usr/local/bin/*

RUN apk update && apk --no-cache add cosign bash curl libxml2

# Set the working directory inside the container
WORKDIR /usr/src

# Copy any source file(s) required for the action
COPY entrypoint.sh .

# Configure the container to be run as an executable
ENTRYPOINT ["/usr/src/entrypoint.sh"]
