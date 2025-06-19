# Set the base image to use for subsequent instructions
#checkov:skip=CKV_DOCKER_7: allow use of latest tag
FROM cgr.dev/chainguard/wolfi-base:latest AS build

LABEL org.opencontainers.image.source=https://github.com/yonasBSD/toolkit

#RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk --no-cache add cosign bash curl clang openssl-dev libxml2-dev libcurl-rustls4 pkgconf rust go linux-headers

# Run curl installs
RUN curl -fsSL https://get.comtrya.dev > comtrya.sh && sh comtrya.sh
RUN curl -fsSL https://just.systems/install.sh > just.sh && bash just.sh --to /usr/local/bin
RUN curl -fsSL https://taskfile.dev/install.sh > task.sh && sh task.sh -d -b /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh > trufflehog.sh && sh trufflehog.sh -v -b /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh > trivy.sh && sh trivy.sh -b /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh > binstall.sh && bash binstall.sh && mv /root/.cargo/bin/cargo-binstall /usr/local/bin

# Run Go installs
RUN go install kcl-lang.io/cli/cmd/kcl@latest && mv /root/go/bin/kcl /usr/local/bin

# Download from release assets
RUN curl -sL -o docker-assets.zip https://github.com/yonasBSD/toolkit/releases/latest/download/docker-assets.zip && \
    unzip docker-assets.zip -d /usr/local/bin
# Run cargo installs
#RUN cargo install --git https://github.com/ruuda/rcl rcl && mv /root/.cargo/bin/rcl /usr/local/bin
#RUN cargo install --git https://github.com/pipelight/pipelight && mv /root/.cargo/bin/pipelight /usr/local/bin
#RUN cargo install --git https://github.com/Orange-OpenSource/hurl hurl hurlfmt && mv /root/.cargo/bin/hurl* /usr/local/bin
#RUN cargo install --locked --git https://github.com/devmatteini/dra && mv /root/.cargo/bin/dra /usr/local/bin

# Run cargo-binstall
RUN cargo binstall -y cargo-auditable cargo-audit && mv /root/.cargo/bin/cargo-audit* /usr/local/bin
RUN cargo binstall -y cargo-deny && mv /root/.cargo/bin/cargo-deny /usr/local/bin
RUN cargo binstall -y cargo-license && mv /root/.cargo/bin/cargo-license /usr/local/bin

# Run dra installs
# Some projects don't have binaries for arch that chainguard/wolfi-base uses
RUN dra download --automatic --install --output /usr/local/bin/venom ovh/venom
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
