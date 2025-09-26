#!/usr/bin/env bash
set -euo pipefail

# === CÁC BIẾN CÓ THỂ CẤU HÌNH ===
# Thay đổi các biến dưới đây để tùy chỉnh quá trình build.
# KERNEL_REPO: Địa chỉ repo kernel. Sử dụng repo chính để linh hoạt hơn với tags.
KERNEL_REPO=${KERNEL_REPO:-https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git}
# KERNEL_TAG: Tag kernel cần build. Ví dụ: v6.1, v6.6.1. Để trống để build từ nhánh chính.
KERNEL_TAG=${KERNEL_TAG:-v6.1}
# TARGET_DIR: Thư mục chứa code nguồn kernel.
TARGET_DIR=${TARGET_DIR:-/work/linux}
# DEFCONFIG: File cấu hình cho bo mạch mục tiêu (ví dụ: am335x_evm_defconfig cho BeagleBone Black)
DEFCONFIG=${DEFCONFIG:-versatile_defconfig}
# ARCH: Kiến trúc (arm, arm64, x86, ...)
ARCH=arm
# CROSS_COMPILE: Prefix cho bộ biên dịch chéo
CROSS_COMPILE=${CROSS_COMPILE:-arm-linux-gnueabihf-}

# --- Bắt đầu quá trình Build ---

# Tạo thư mục làm việc và di chuyển vào đó
echo "Setting up working directory..."
mkdir -p /work
cd /work

# Luôn clone lại để đảm bảo môi trường sạch sẽ và code mới nhất
echo "Performing a fresh clone of the kernel repository..."
if [ -d "${TARGET_DIR}" ]; then
    rm -rf "${TARGET_DIR}"
fi
git clone --depth 1 ${KERNEL_REPO} ${TARGET_DIR}

cd ${TARGET_DIR}

# Lấy về các tags và checkout tag được chỉ định (nếu có)
if [ -n "${KERNEL_TAG}" ]; then
    echo "Fetching tags and checking out tag ${KERNEL_TAG}..."
    git fetch --tags
    git checkout "${KERNEL_TAG}"
else
    # Mặc định, checkout nhánh chính (main)
    echo "Checking out the main branch..."
    git checkout main || git checkout master
fi

# Dọn dẹp build cũ
echo "Cleaning old build files..."
make ARCH=${ARCH} distclean || true

# Cấu hình kernel bằng defconfig
echo "Configuring kernel with ${DEFCONFIG}..."
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${DEFCONFIG}

# Bắt đầu biên dịch
echo "Starting kernel compilation..."
make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} zImage dtbs

# In ra các artifacts đã tạo
echo "✅ Kernel build completed successfully!"
echo "Artifacts:"
echo " - zImage: ${TARGET_DIR}/arch/arm/boot/zImage"
echo " - dtbs: $(ls -1 ${TARGET_DIR}/arch/arm/boot/dts/*.dtb 2>/dev/null || true)"
