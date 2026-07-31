#!/usr/bin/env bash
#
# Re-creates the "extra_deps" repos and applies the "picks" (repopick)
# entries from the manifest.
#
# Usage: run from the root of your ROM source tree.
#   ./setup_deps_and_picks.sh

set -euo pipefail

REPOPICK="./vendor/custom/build/tools/repopick.py"

# ---------------------------------------------------------------------------
# extra_deps: rm -rf path && git clone --depth=1 url -b branch path
# ---------------------------------------------------------------------------

clone_dep() {
    local url="$1" branch="$2" path="$3"
    echo "==> [extra_deps] ${path}  (${url}, branch: ${branch})"
    rm -rf "${path}"
    git clone --depth=1 "${url}" -b "${branch}" "${path}"
}

clone_dep "https://github.com/PixelOS-AOSP/android_packages_apps_ColumbusService" "seventeen" "packages/apps/ColumbusService"
clone_dep "https://github.com/PixelOS-17/android_vendor_lineage" "seventeen" "vendor/lineage"
clone_dep "https://github.com/LineageOS/android_vendor_qcom_opensource_libvmmem" "lineage-23.2" "vendor/qcom/opensource/libvmmem"
clone_dep "https://github.com/LineageOS/android_vendor_qcom_opensource_libqspa" "lineage-24.0" "vendor/qcom/opensource/libqspa"
clone_dep "https://github.com/LineageOS/android_hardware_lineage_interfaces" "lineage-24.0" "hardware/lineage/interfaces"
clone_dep "https://github.com/PixelOS-17/android_system_memory_libion" "seventeen" "system/memory/libion"
clone_dep "https://github.com/LineageOS/android_hardware_lineage_compat" "lineage-24.0" "hardware/lineage/compat"
clone_dep "https://github.com/PixelOS-17/android_vendor_qcom_opensource_wfd-commonsys" "seventeen" "vendor/qcom/opensource/commonsys/wfd"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy" "seventeen" "device/qcom/sepolicy"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy" "seventeen-legacy-um" "device/qcom/sepolicy-legacy-um"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy_vndr" "seventeen-legacy-um" "device/qcom/sepolicy_vndr/legacy-um"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy_vndr" "seventeen-sm8450" "device/qcom/sepolicy_vndr/sm8450"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy_vndr" "seventeen-sm8550" "device/qcom/sepolicy_vndr/sm8550"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy_vndr" "seventeen-sm8650" "device/qcom/sepolicy_vndr/sm8650"
clone_dep "https://github.com/PixelOS-17/android_device_qcom_sepolicy_vndr" "seventeen-sm8750" "device/qcom/sepolicy_vndr/sm8750"
clone_dep "https://github.com/PixelOS-17/android_vendor_qcom_opensource_audio" "seventeen" "vendor/qcom/opensource/commonsys/audio"
clone_dep "https://github.com/PixelOS-17/android_vendor_qcom_opensource_display-commonsys" "seventeen" "vendor/qcom/opensource/commonsys/display"
clone_dep "https://github.com/PixelOS-17/android_hardware_qcom_wlan" "seventeen-caf" "hardware/qcom-caf/wlan"
clone_dep "https://github.com/PixelOS-17/android_hardware_qcom_wlan" "seventeen" "hardware/qcom/wlan"
clone_dep "https://github.com/PixelOS-17/android_external_wpa_supplicant_8" "seventeen" "external/wpa_supplicant_8"
clone_dep "https://github.com/PixelOS-17/android_device_lineage_sepolicy" "seventeen" "device/lineage/sepolicy"
#clone_dep "https://github.com/dsashwin/android_frameworks_base" "seventeen" "frameworks/base"

# ---------------------------------------------------------------------------
# picks: repopick.py -P id   (comment = originating repo, for reference)
# ---------------------------------------------------------------------------

pick() {
    local id="$1" comment="$2"
    echo "==> [picks] #${id}  (${comment})"
    "${REPOPICK}" -p "${id}"
}

pick 9783 "PixelOS-AOSP/android_external_bouncycastle"
pick 9775 "PixelOS-AOSP/android_art"
pick 9746 "PixelOS-AOSP/android_system_memory_libmeminfo"
pick 9282 "PixelOS-AOSP/android_frameworks_av"
pick 9633 "PixelOS-AOSP/android_external_zstd"
# pick 9752 "PixelOS-AOSP/android_vendor_custom"
pick 9604 "PixelOS-AOSP/android_bionic"
pick 9578 "PixelOS-AOSP/android_bootable_deprecated-ota"
pick 9774 "PixelOS-AOSP/android_bootable_recovery"
pick 9639 "PixelOS-AOSP/android_build"
pick 9212 "PixelOS-AOSP/android_build_soong"
pick 9605 "PixelOS-AOSP/android_development"
pick 9644 "PixelOS-AOSP/android_external_avb"
pick 9595 "PixelOS-AOSP/android_external_dng_sdk"
pick 9575 "PixelOS-AOSP/android_external_dtc"
pick 9597 "PixelOS-AOSP/android_external_e2fsprogs"
pick 9559 "PixelOS-AOSP/android_external_gptfdisk"
pick 9606 "PixelOS-AOSP/android_external_libjxl"
pick 9583 "PixelOS-AOSP/android_external_mksh"
pick 9599 "PixelOS-AOSP/android_external_tinycompress"
pick 9837 "PixelOS-AOSP/android_frameworks_base"
# PixelOS-AOSP/android_frameworks_base (id 9792) is commented out in the
# manifest - frameworks/base is sourced from dsashwin's fork via extra_deps
# instead, so it's skipped here too.
pick 9379 "PixelOS-AOSP/android_frameworks_native"
pick 9485 "PixelOS-AOSP/android_frameworks_opt_telephony"
pick 9552 "PixelOS-AOSP/android_hardware_broadcom_libbt"
pick 9436 "PixelOS-AOSP/android_hardware_google_pixel"
pick 9440 "PixelOS-AOSP/android_hardware_google_pixel-sepolicy"
pick 9749 "PixelOS-AOSP/android_hardware_interfaces"
pick 9601 "PixelOS-AOSP/android_hardware_libhardware"
pick 9607 "PixelOS-AOSP/android_hardware_nxp_nfc"
pick 9589 "PixelOS-AOSP/android_hardware_st_nfc"
pick 9751 "PixelOS-AOSP/android_kernel_configs"
pick 9789 "PixelOS-AOSP/android_packages_apps_Settings"
pick 9530 "PixelOS-AOSP/android_packages_modules_Bluetooth"
pick 9518 "PixelOS-AOSP/android_packages_modules_Connectivity"
pick 9829 "PixelOS-AOSP/android_packages_modules_Permission"
pick 9608 "PixelOS-AOSP/android_packages_modules_Wifi"
pick 9540 "PixelOS-AOSP/android_packages_modules_adb"
pick 9592 "PixelOS-AOSP/android_packages_services_Telecomm"
pick 9536 "PixelOS-AOSP/android_packages_services_Telephony"
pick 9609 "PixelOS-AOSP/android_system_bpf"
pick 9610 "PixelOS-AOSP/android_system_chre"
pick 9770 "PixelOS-AOSP/android_system_core"
pick 9457 "PixelOS-AOSP/android_system_fs_fs_mgr"
pick 9611 "PixelOS-AOSP/android_system_libziparchive"
pick 9585 "PixelOS-AOSP/android_system_logging"
pick 9603 "PixelOS-AOSP/android_system_media"
pick 9523 "PixelOS-AOSP/android_system_netd"
pick 9397 "PixelOS-AOSP/android_system_sepolicy"
pick 9497 "PixelOS-AOSP/android_system_update_engine"
pick 9414 "PixelOS-AOSP/android_system_vold"
# PixelOS-AOSP/android_build_release (id 9798) is commented out in the
# manifest, so it's skipped here too.

echo "==> Done: cloned all extra_deps and applied all picks."

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