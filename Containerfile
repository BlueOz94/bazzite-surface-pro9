# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image - Bazzite (good for gaming + desktop on Surface Pro 9)
# You can change to other uBlue images if preferred, e.g.:
#   ghcr.io/ublue-os/aurora:stable     (KDE, more traditional desktop)
#   ghcr.io/ublue-os/bluefin:stable    (GNOME)
#   ghcr.io/ublue-os/bazzite-deck:stable
FROM ghcr.io/ublue-os/bazzite:stable

## Other possible base images include:
# FROM ghcr.io/ublue-os/aurora:stable
# FROM ghcr.io/ublue-os/bluefin:stable
# FROM ghcr.io/ublue-os/bazzite-gnome:stable
#
# Universal Blue Images: https://github.com/orgs/ublue-os/packages

### MODIFICATIONS
## Surface Pro 9 + linux-surface kernel and drivers are installed via build.sh
## See build_files/build.sh for the Surface-specific setup.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
