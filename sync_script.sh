#!/usr/bin/env bash
#
# Re-creates the "extra_deps" repos and applies the "pulls" (repopick)
# entries from the manifest.
#
# Usage: run from the root of your ROM source tree.
#   ./setup_deps_and_pulls.sh

set -euo pipefail

REPOPICK="./vendor/custom/build/tools/repopick.py"

if [[ ! -f "${REPOPICK}" ]]; then
    echo "Error: repopick.py not found at ${REPOPICK}" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# extra_deps: rm -rf path && git clone --depth=1 url -b branch path
# ---------------------------------------------------------------------------

clone_dep() {
    local url="$1" branch="$2" path="$3"
    echo "==> [extra_deps] ${path}  (${url}, branch: ${branch})"
    rm -rf "${path}"
    git clone --depth=1 "${url}" -b "${branch}" "${path}"
}

clone_dep "https://github.com/PixelOS-17/android_vendor_lineage" "seventeen" "vendor/lineage"
clone_dep "https://github.com/PixelOS-17/android_system_fs_fs_mgr" "seventeen-2" "system/fs/fs_mgr"

# ---------------------------------------------------------------------------
# pull: repopick.py -p id   (comment = originating repo, for reference)
# ---------------------------------------------------------------------------

pull() {
    local id="$1" comment="$2"
    echo "==> [pull] #${id}  (${comment})"
    "${REPOPICK}" -p "${id}"
}

pull 9697 "PixelOS-AOSP/android_external_wpa_supplicant_8"
pull 9783 "PixelOS-AOSP/android_external_bouncycastle"
pull 9775 "PixelOS-AOSP/android_art"
pull 9746 "PixelOS-AOSP/android_system_memory_libmeminfo"
pull 10441 "PixelOS-AOSP/android_frameworks_av"
pull 9633 "PixelOS-AOSP/android_external_zstd"
pull 10488 "PixelOS-AOSP/android_vendor_custom"
pull 9604 "PixelOS-AOSP/android_bionic"
pull 9578 "PixelOS-AOSP/android_bootable_deprecated-ota"
pull 9774 "PixelOS-AOSP/android_bootable_recovery"
pull 10482 "PixelOS-AOSP/android_build"
pull 9212 "PixelOS-AOSP/android_build_soong"
pull 9605 "PixelOS-AOSP/android_development"
pull 9580 "PixelOS-AOSP/android_external_avb"
pull 9595 "PixelOS-AOSP/android_external_dng_sdk"
pull 9575 "PixelOS-AOSP/android_external_dtc"
pull 9597 "PixelOS-AOSP/android_external_e2fsprogs"
pull 9559 "PixelOS-AOSP/android_external_gptfdisk"
pull 9606 "PixelOS-AOSP/android_external_libjxl"
pull 9583 "PixelOS-AOSP/android_external_mksh"
pull 9599 "PixelOS-AOSP/android_external_tinycompress"
pull 9837 "PixelOS-AOSP/android_frameworks_base"
pull 9379 "PixelOS-AOSP/android_frameworks_native"
pull 9485 "PixelOS-AOSP/android_frameworks_opt_telephony"
pull 9552 "PixelOS-AOSP/android_hardware_broadcom_libbt"
pull 9436 "PixelOS-AOSP/android_hardware_google_pixel"
pull 9440 "PixelOS-AOSP/android_hardware_google_pixel-sepolicy"
pull 9748 "PixelOS-AOSP/android_hardware_interfaces"
pull 9601 "PixelOS-AOSP/android_hardware_libhardware"
pull 9607 "PixelOS-AOSP/android_hardware_nxp_nfc"
pull 9589 "PixelOS-AOSP/android_hardware_st_nfc"
pull 9508 "PixelOS-AOSP/android_kernel_configs"
pull 9045 "PixelOS-AOSP/android_packages_apps_Settings"
pull 9530 "PixelOS-AOSP/android_packages_modules_Bluetooth"
pull 9518 "PixelOS-AOSP/android_packages_modules_Connectivity"
pull 9543 "PixelOS-AOSP/android_packages_modules_Permission"
pull 9608 "PixelOS-AOSP/android_packages_modules_Wifi"
pull 9540 "PixelOS-AOSP/android_packages_modules_adb"
pull 9592 "PixelOS-AOSP/android_packages_services_Telecomm"
pull 9536 "PixelOS-AOSP/android_packages_services_Telephony"
pull 9609 "PixelOS-AOSP/android_system_bpf"
pull 9610 "PixelOS-AOSP/android_system_chre"
pull 9756 "PixelOS-AOSP/android_system_core"
pull 9611 "PixelOS-AOSP/android_system_libziparchive"
pull 9585 "PixelOS-AOSP/android_system_logging"
pull 9603 "PixelOS-AOSP/android_system_media"
pull 9523 "PixelOS-AOSP/android_system_netd"
pull 9830 "PixelOS-AOSP/android_system_security"
pull 9397 "PixelOS-AOSP/android_system_sepolicy"
pull 9497 "PixelOS-AOSP/android_system_update_engine"
pull 9413 "PixelOS-AOSP/android_system_vold"

echo "==> Done: cloned all extra_deps and applied all pulls."

# ---------------------------------------------------------------------------
# Finally, check the whole tree for uncommitted changes
# ---------------------------------------------------------------------------

echo "==> [repo status] Checking for uncommitted changes..."
status_output="$(repo status)"
if [[ -n "${status_output}" ]]; then
    echo "${status_output}"
    echo "WARNING: uncommitted changes detected in the repositories above."
else
    echo "No uncommitted changes found — tree is clean."
fi
