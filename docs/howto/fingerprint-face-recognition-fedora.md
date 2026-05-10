
# Howdy (Face Unlock) & Fingerprint Setup on Fedora

**OS:** Fedora Linux  
**Hardware:** Laptop with IR Camera & Fingerprint Reader  
**Goal:** Face unlock for Login/Lock Screen, Fingerprint for `sudo` (Terminal).

---

## 1. Install Dependencies & Build Howdy

Fedora requires compiling Howdy from source.

### System Dependencies
```bash
sudo dnf install -y git python3-devel cmake gcc-c++ pam-devel inih-devel opencv opencv-devel python3-opencv python3-numpy python3-dlib v4l-utils
```

### Python Dependencies
Howdy needs specific Python libraries. While DNF installs some, `pip` ensures `face_recognition` is present.
```bash
sudo pip3 install face_recognition opencv-python
```

### Clone & Compile
```bash
git clone https://github.com/boltgolt/howdy ~/src/howdy
cd ~/src/howdy

# Clean previous builds if re-installing
rm -rf build 

meson setup build
meson compile -C build
sudo meson install -C build
```

---

## 2. Fix Library Paths (The "Module Not Found" Fix)

Fedora's PAM runs in a strict environment and often cannot see libraries installed in `/usr/local`. To fix `ModuleNotFoundError: No module named 'dlib'` or `cv2`:

Create a path link file so the system finds the custom libraries:
```bash
# Replace 'python3.X' with your current python version (e.g., python3.12 or python3.13)
PYTHON_VER=$(python3 -c "import sys; print(f'python{sys.version_info.major}.{sys.version_info.minor}')")

sudo sh -c "echo '/usr/local/lib64/$PYTHON_VER/site-packages' > /usr/lib64/$PYTHON_VER/site-packages/howdy_local_libs.pth"
sudo sh -c "echo '/usr/local/lib/$PYTHON_VER/site-packages' >> /usr/lib64/$PYTHON_VER/site-packages/howdy_local_libs.pth"
```

---

## 3. Configure Hardware (IR Camera)

Using the IR Emitter is required for security and low-light performance.

### Enable IR Emitters
Linux drivers often don't fire the IR LEDs by default.
```bash
sudo dnf install linux-enable-ir-emitter
# If not in repos, compile from: https://github.com/EmixamPP/linux-enable-ir-emitter

# Configure patterns (Say 'No' until lights flash, then 'Yes')
sudo linux-enable-ir-emitter configure
```

### Configure Howdy
Identify the IR camera path (usually `/dev/video2` or whichever shows up as black/purple in `ffplay`):
```bash
sudo howdy config
```

**Key Settings:**
```ini
device_path = /dev/video2  # Adjust based on v4l2-ctl --list-devices
dark_background = true     # Required for IR
certainty = 4.2            # 3.5 is too strict, 4.5 is loose. 4.2 is the sweet spot.
timeout = 8                # Give it time to scan
snapshots = true           # (Optional) Save photos of failed login attempts
force_mjpeg = false        # Change to true if camera is slow
frame_width = 640          # Match camera native resolution for speed
frame_height = 480
```

---

## 4. Add Face Models

Do this **after** configuring the IR camera. Add 3-4 models in different positions.

```bash
sudo howdy clear
sudo howdy add  # Look straight
sudo howdy add  # Typing position (looking down slightly)
sudo howdy add  # Leaning back in chair
```

**Test it:**
```bash
sudo howdy test
```
*   **Green Circle:** Success.
*   **Red Circle:** Face detected but not recognized (Lower certainty or add better models).

---

## 5. PAM Configuration (The Security Rules)

We want **Face** for Login, and **Fingerprint** for Sudo (safer intentionality).

### A. Enable for Login (GDM)
Edit the fingerprint PAM file to check Face *before* Fingerprint.

`sudo nano /etc/pam.d/gdm-fingerprint`

Add the Howdy line at the **very top**:
```text
#%PAM-1.0
auth      sufficient    pam_howdy.so
auth      include       system-auth
...
```

*(Optional Backup)* Edit `sudo nano /etc/pam.d/gdm-password`:
```text
auth     [success=done ignore=ignore default=bad] pam_selinux_permit.so
auth     sufficient    pam_howdy.so  <-- Add here
auth     substack      password-auth
```

### B. Configure Sudo (Terminal)
**Goal:** Disable Face Unlock for `sudo`, require Fingerprint.

`sudo nano /etc/pam.d/sudo`

Ensure `pam_howdy.so` is **NOT** present or is commented out. The file should rely on `system-auth` (which handles fingerprint).

```text
#%PAM-1.0
# auth      sufficient    pam_howdy.so   <-- Commented out to disable face
auth      include       system-auth      <-- Triggers Fingerprint
account   include       system-auth
password  include       system-auth
```

---

## 6. Fix SELinux (The "Access Denied" Fix)

SELinux often blocks Howdy from accessing the camera or config files during Login.

1.  **Set Permissive Mode temporarily:**
    ```bash
    sudo setenforce 0
    ```
2.  **Trigger the event:** Lock screen (`Super+L`) and unlock with face.
3.  **Generate Policy:**
    ```bash
    sudo setenforce 1
    sudo ausearch -m avc -ts recent | audit2allow -M howdy_custom
    sudo semodule -i howdy_custom.pp
    ```

---

## 7. Troubleshooting & Maintenance

**Command to check logs:**
```bash
sudo journalctl -xe | grep howdy
```

**Quick Disable/Enable:**
If traveling or needing to disable face unlock globally:
```bash
sudo howdy disable 1  # Turn OFF
sudo howdy disable 0  # Turn ON
```

**Permissions Fix:**
If `sudo` or login fails silently, re-apply permissions to the local python libs:
```bash
sudo restorecon -vR /usr/local/lib/python3.*/site-packages/
sudo restorecon -vR /usr/local/lib64/python3.*/site-packages/
```