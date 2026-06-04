# Bazzite Surface Pro 9 (linux-surface kernel)

Custom bootc image for **Microsoft Surface Pro 9** (Intel version) based on [Bazzite](https://bazzite.gg) + the full [linux-surface](https://github.com/linux-surface/linux-surface) patched kernel and drivers.

This gives you the best possible Linux support for the Surface-specific hardware (SAM embedded controller, touch, pen via iptsd, keyboard/touchpad, etc.) on top of Bazzite's excellent gaming/desktop experience.

## Prerequisites

- You are (or will be) running a uBlue/Bazzite system (this image is designed to be a drop-in replacement).
- GitHub account.
- Follow the excellent step-by-step video tutorial for creating your own uBlue variant:
  **https://www.youtube.com/watch?v=IxBl11Zmq5w**

## Quick Start (High Level)

1. Create a new GitHub repository from the official template:
   - Go to https://github.com/ublue-os/image-template
   - Click **"Use this template"**
   - Name it something like `bazzite-surface-pro9`
   - Create the repo.

2. Clone your new repo locally.

3. **Replace the default files with these custom ones** (copy the entire contents of this directory into your cloned repo, overwriting):
   - `Containerfile`
   - `build_files/build.sh`
   - (Optional) Add this README or keep the original.

4. Complete the setup from the video:
   - Install `cosign`
   - `COSIGN_PASSWORD="" cosign generate-key-pair`
   - Add `SIGNING_SECRET` in repo Settings → Secrets and variables → Actions (paste the content of `cosign.key`)
   - Commit `cosign.pub` + your changes and `git push`

5. Watch the Actions tab — it will build and push your custom image to GHCR.

6. On your Surface Pro 9 (running Bazzite or another bootc image):
   ```bash
   sudo bootc switch ghcr.io/YOUR_GITHUB_USERNAME/bazzite-surface-pro9:latest
   ```
   Enter password when prompted, then reboot.

7. On first boot into the new image:
   - You should see your custom image in the boot menu.
   - If using Secure Boot, you will likely be prompted by mokutil/MOK manager to enroll keys (password is usually `surface`).
   - Log in — your home directory and users are preserved.

8. Verify:
   ```bash
   sudo bootc status
   uname -r   # should show something with "surface"
   systemctl status iptsd
   lsmod | grep surface
   ```

## Making Changes Later

- Edit `build_files/build.sh` (add more packages, tweak configs).
- Edit `Containerfile` only if you change the base image or advanced build options.
- `git add` → commit → push.
- On your running system: `sudo bootc update && reboot`

## Rollback

If something is broken:
```bash
sudo bootc rollback
reboot
```

## Important Notes for Surface Pro 9

- **Secure Boot**: The image includes `surface-secureboot`. Enroll with the password `surface` the first time.
  - Many people simply disable Secure Boot in the Surface UEFI (hold Volume Up while powering on) for simplicity.
- **Module ordering fix**: We ship `/etc/modules-load.d/10-surface-pro9.conf` to ensure `pinctrl_tigerlake` loads before the Surface Aggregator modules. This fixes keyboard/touchpad/pen issues seen on some recent kernels for Pro 9 / 7+ / Laptop Studio etc.
- **Touch & Pen**: `iptsd` is installed and enabled. This is critical for the touchscreen and pen.
- **Stylus**: `libwacom-surface` improves pen support in apps.
- **Base Image**: Currently based on `bazzite:stable`. Bazzite includes a lot of gaming/Steam/Deck-focused bits. If you want a cleaner desktop experience, change the `FROM` line in `Containerfile` to `ghcr.io/ublue-os/aurora:stable` (KDE) or `bluefin:stable` (GNOME) and rebuild.
- **Fedora release**: The surface repo uses `f$releasever`. Make sure your base image matches a supported Fedora release in the linux-surface repo. As of now it targets recent Fedora.

## Troubleshooting

- **No keyboard/touch after switch**: Check `lsmod | grep surface` and the modules-load file. You may need to `sudo bootc rollback` and investigate.
- **Build fails on kernel install**: The surface repo sometimes lags behind new Fedora releases. Check https://pkg.surfacelinux.com/ and the linux-surface issues.
- **Camera / other hardware**: Some features (especially cameras) still have limitations even with linux-surface. See the feature matrix in the linux-surface wiki.
- **Local testing** (advanced): With `just` installed (it is on uBlue images):
  ```bash
  just build
  ```
  Then you can test the local image with podman or advanced bootc flows.

## Useful Links

- Video tutorial this is based on: https://www.youtube.com/watch?v=IxBl11Zmq5w
- Official template: https://github.com/ublue-os/image-template
- linux-surface project + installation wiki: https://github.com/linux-surface/linux-surface
- Feature matrix (what works on Pro 9): https://github.com/linux-surface/linux-surface/wiki/Supported-Devices-and-Features
- Universal Blue / Bazzite docs and support: https://universal-blue.discourse.group/ and Bazzite Discord

## Credits

- The linux-surface maintainers for the incredible driver/kernel work.
- Universal Blue / Bazzite teams for the amazing immutable desktop images and the image-template.
- TesterTech for the clear tutorial video.

Have fun with your Surface Pro 9 on a fully customized immutable Linux desktop!
