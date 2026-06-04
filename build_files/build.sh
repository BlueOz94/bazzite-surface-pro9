#!/bin/bash

set -ouex pipefail

echo "=== Surface Pro 9 Custom Image Build ==="

### 1. Add linux-surface repository (provides patched kernel + supporting packages)
# Official repo: https://github.com/linux-surface/linux-surface
# Packages for current Fedora release (Bazzite is based on Fedora 43)
dnf5 config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo

### 2. Remove stock kernel packages (to allow clean swap to kernel-surface)
# This follows patterns used in uBlue custom Surface images.
# We use rpm --erase --nodeps because dnf remove can be finicky with kernel metapackages on ostree builds.
echo "Removing stock kernel packages..."
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
    rpm -e --nodeps "$pkg" 2>/dev/null || true
done

### 3. Install linux-surface kernel and Surface-specific userspace packages
# Core packages:
#   - kernel-surface (and its split packages): the patched kernel with full Surface support (SAM, touch, etc.)
#   - iptsd: Intel Precise Touch & Stylus Daemon (required for multitouch + pen on most Surface devices)
#   - libwacom-surface: Surface-specific Wacom configuration for better pen/stylus support
#
# Optional but recommended:
#   - surface-secureboot: Helps with Secure Boot (enrolls MOK key "surface" password). Include if you use Secure Boot.
#   - surface-control: Command-line tool for Surface performance modes, etc.
#   - surface-dtx-daemon: For devices with detachable keyboards (less critical for Pro 9)
#
# Note: DNF5 kernel installation on ostree/bootc images is not officially supported by Fedora but works reliably at *build time*.
echo "Installing linux-surface kernel and drivers..."
dnf5 install -y --allowerasing \
    kernel-surface \
    kernel-surface-core \
    kernel-surface-modules \
    kernel-surface-modules-core \
    iptsd \
    libwacom-surface \
    surface-secureboot \
    surface-control

# Uncomment if you want more Surface tools:
# dnf5 install -y --allowerasing surface-dtx-daemon

### 4. Fix module load order for Surface Pro 9 (and similar Intel 12th-gen devices)
# Some kernels (around 6.12+) have issues with surface_serial_hub / aggregator IRQ setup
# if pinctrl_tigerlake is not loaded early enough.
# This ensures the correct order so keyboard, touchpad, and other SAM devices work reliably.
echo "Configuring Surface module load order..."
mkdir -p /etc/modules-load.d
cat > /etc/modules-load.d/10-surface-pro9.conf << 'EOCONF'
# Surface Pro 9 (and similar) module load ordering fix
# pinctrl_tigerlake must come before surface_aggregator* modules.
pinctrl_tigerlake
surface_aggregator
surface_aggregator_hub
surface_aggregator_tabletsw
surface_fan
surface_temp
surface_battery
surface_charger
surface_platform_profile
surface_hotplug
surfacepro3_button
EOCONF

### 5. Enable iptsd service (touch + pen)
echo "Enabling iptsd service..."
systemctl enable iptsd

### 6. (Optional) Other Surface / hardware tweaks
# Example: ensure good firmware is present (usually already in Bazzite)
# dnf5 install -y linux-firmware

# You can add any other packages here (e.g. your favorite tools, codecs, etc.)
# dnf5 install -y htop neovim ...

echo "=== Surface Pro 9 customizations complete ==="
