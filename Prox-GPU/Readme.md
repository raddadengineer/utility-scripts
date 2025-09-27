# 🎛️ Proxmox Installation with GPU Passthrough for LXC Containers

Setting up Proxmox with GPU passthrough for LXC containers allows the maximum and best performance. 🚀

---

## 🛠️ Host Node Setup

1. **Update system and install required packages:**
    ```bash
    apt update && apt upgrade -y
    apt install pve-headers-$(uname -r) build-essential software-properties-common make nvtop htop -y
    update-initramfs -u
    ```
2. **Download the Ubuntu LXC template for your container.**

---

## 📦 LXC Container Setup

To create a new Proxmox VE Docker LXC, simply run:
```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/docker.sh)"
```

---

## 🎮 GPU Driver Installation

1. **Find and download the latest driver for your GPU:**
    ```bash
    wget HTTP://URLHERE
    chmod +x driver.run
    ./driver.run --dkms
    ```
2. **Follow the installation prompts.**

---

## 🔍 Cgroups Setup

1. **Check available GPU devices:**
    ```bash
    ls -al /dev/nvidia*
    ```
2. **Note down the IDs for:** `nvidia0`, `nvidiactl`, `nvidia-uvm`, `nvidia-uvm-tools`, and `nvidia-caps`.

---

## ⚙️ Configure LXC Container for GPU Passthrough

1. **Edit the container configuration:**
    ```bash
    nano /etc/pve/lxc/100.conf
    ```
2. **Add these lines (replace IDs accordingly):**
    ```bash
    lxc.mount.entry: /dev/nvidia1 dev/nvidia1 none bind,optional,create=file
    lxc.cgroup2.devices.allow: c 195:* rwm
    lxc.cgroup2.devices.allow: c 234:* rwm
    lxc.cgroup2.devices.allow: c 509:* rwm
    lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
    lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
    lxc.mount.entry: /dev/nvidia-modeset dev/nvidia-modeset none bind,optional,create=file
    lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
    lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
    lxc.mount.entry: /dev/nvidia-caps/nvidia-cap1 dev/nvidia-caps/nvidia-cap1 none bind,optional,create=file
    lxc.mount.entry: /dev/nvidia-caps/nvidia-cap2 dev/nvidia-caps/nvidia-cap2 none bind,optional,create=file
    ```
3. **Transfer the `.run` installer into the container:**
    ```bash
    pct push 100 NVIDIA-Linux-x86_64-550.107.02.run /root/NVIDIA-Linux-x86_64-550.107.02.run
    ```
4. **Install the driver inside the container:**
    ```bash
    ./NVIDIA-Linux-x86_64-550.107.02.run --no-kernel-modules
    ```
5. **Verify the installation inside the container:**
    ```bash
    nvidia-smi
    ```
    This should display GPU information if passthrough is configured correctly.

---

## 🖥️ Install NVIDIA Container Toolkit

1. **Install dependencies and add the repository:**
    ```bash
    apt install gpg curl -y
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
        | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
        | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    ```
2. **Update and install NVIDIA Container Toolkit:**
    ```bash
    apt update
    apt install nvidia-container-toolkit -y
    ```

---

🎉 **Success!** Proxmox should now supports GPU passthrough for LXC containers. 🚀
