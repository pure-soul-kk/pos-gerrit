#!/usr/bin/env python3
"""
Fetch the latest open (unmerged) Gerrit changes for each PixelOS-AOSP repo
referenced in the "picks" list, so you can spot new candidates for repopick.

Gerrit change numbers ARE the ids repopick.py -P expects, so the output of
this script maps directly onto the "picks:" section of your manifest.

Usage:
    python3 fetch_gerrit_picks.py
    python3 fetch_gerrit_picks.py --days 14        # only changes touched recently
    python3 fetch_gerrit_picks.py --status merged  # look at merged history instead
    python3 fetch_gerrit_picks.py --debug          # print raw HTTP/project info
"""

import argparse
import json
import time
import urllib.error
import urllib.parse
import urllib.request

GERRIT_URL = "https://review.pixelos.net"

# Repo names as they appear after "PixelOS-AOSP/" in your picks comments.
# Edit this list to match whatever repos you care about tracking.
REPOS = [
    "android_system_memory_libmeminfo",
    "android_frameworks_av",
    "android_external_zstd",
    "android_vendor_custom",
    "android_bionic",
    "android_bootable_deprecated-ota",
    "android_bootable_recovery",
    "android_build",
    "android_build_soong",
    "android_development",
    "android_external_avb",
    "android_external_dng_sdk",
    "android_external_dtc",
    "android_external_e2fsprogs",
    "android_external_gptfdisk",
    "android_external_libjxl",
    "android_external_bouncycastle",
    "android_external_mksh",
    "android_external_tinycompress",
    "android_frameworks_base",
    "android_frameworks_native",
    "android_frameworks_opt_telephony",
    "android_hardware_broadcom_libbt",
    "android_hardware_google_pixel",
    "android_hardware_google_pixel-sepolicy",
    "android_hardware_interfaces",
    "android_hardware_libhardware",
    "android_packages_apps_Updater",
    "android_hardware_nxp_nfc",
    "android_hardware_st_nfc",
    "android_kernel_configs",
    "android_packages_apps_Settings",
    "android_packages_modules_Bluetooth",
    "android_packages_modules_Connectivity",
    "android_packages_modules_Permission",
    "android_packages_modules_Wifi",
    "android_packages_modules_adb",
    "android_packages_services_Telecomm",
    "android_packages_services_Telephony",
    "android_system_bpf",
    "android_system_chre",
    "android_system_core",
    "android_system_fs_fs_mgr",
    "android_system_libziparchive",
    "android_system_logging",
    "android_system_media",
    "android_system_netd",
    "android_system_sepolicy",
    "android_system_update_engine",
    "android_system_vold",
]

# Exact-name variants to try directly if the substring search comes up empty.
NAME_PREFIXES_TO_PROBE = ["", "PixelOS-AOSP/"]

XSSI_PREFIX = ")]}'"
DEBUG = False


class GerritHTTPError(Exception):
    def __init__(self, url, code, reason):
        self.url, self.code, self.reason = url, code, reason
        super().__init__(f"{code} {reason} for {url}")


def gerrit_get(path):
    """GET a Gerrit REST path and return parsed JSON (or None on 404)."""
    url = f"{GERRIT_URL}{path}"
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise GerritHTTPError(url, e.code, e.reason)
    if DEBUG:
        print(f"    [debug] GET {url} -> {len(body)} bytes")
    if body.startswith(XSSI_PREFIX):
        body = body.split("\n", 1)[1]
    return json.loads(body) if body.strip() else {}


def substring_search(repo):
    """Ask Gerrit for any project whose name CONTAINS repo as a substring."""
    q = urllib.parse.quote(repo, safe="")
    data = gerrit_get(f"/projects/?m={q}") or {}
    # Keep only names that actually END with the repo name (avoids false
    # positives like "android_frameworks_av" matching "...frameworks_avb").
    return [name for name in data if name.rstrip("/").split("/")[-1] == repo]


def direct_probe(repo):
    """Try a few exact candidate project names directly against Gerrit."""
    found = []
    for prefix in NAME_PREFIXES_TO_PROBE:
        candidate = f"{prefix}{repo}"
        encoded = urllib.parse.quote(candidate, safe="")
        data = gerrit_get(f"/projects/{encoded}")
        if data:
            found.append(candidate)
    return found


def resolve_project(repo):
    matches = substring_search(repo)
    if matches:
        return matches
    return direct_probe(repo)


def query_changes(project, status, days):
    parts = [f"project:{project}", f"status:{status}"]
    if days:
        parts.append(f"-age:{days}d")
    query = urllib.parse.quote(" ".join(parts), safe="")
    return gerrit_get(f"/changes/?q={query}&o=CURRENT_REVISION&n=25") or []


def main():
    global DEBUG
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--status", default="open", choices=["open", "merged"],
                     help="Gerrit change status to list (default: open)")
    ap.add_argument("--days", type=int, default=None,
                     help="Only show changes touched in the last N days")
    ap.add_argument("--debug", action="store_true",
                     help="Print raw HTTP calls for troubleshooting")
    args = ap.parse_args()
    DEBUG = args.debug

    unresolved = []

    for repo in REPOS:
        try:
            projects = resolve_project(repo)
        except GerritHTTPError as e:
            print(f"# {repo}: lookup failed ({e})")
            continue

        if not projects:
            unresolved.append(repo)
            print(f"# {repo}: no matching Gerrit project found")
            continue

        for project in projects:
            try:
                changes = query_changes(project, args.status, args.days)
            except GerritHTTPError as e:
                print(f"# {project}: query failed ({e})")
                continue

            print(f"# PixelOS-AOSP/{repo}  (gerrit project: {project})")
            if not changes:
                print("    # (none)")
            else:
                last_c = sorted(changes, key=lambda c: c["_number"])[-1]
                print(f"    - id: {last_c['_number']}  # {last_c['subject']}")
            print()

        time.sleep(0.2)  # be polite to the public Gerrit instance

    if unresolved:
        print(f"\n# {len(unresolved)} repo(s) could not be resolved. To debug, run e.g.:")
        print(f"#   curl -s '{GERRIT_URL}/projects/?m={unresolved[0]}' | tail -n +2 | python3 -m json.tool")
        print("# and check whether it returns an empty {} (Gerrit truly has no such project,")
        print("# or anonymous project listing is disabled) or a real project entry (naming mismatch).")


if __name__ == "__main__":
    main()
