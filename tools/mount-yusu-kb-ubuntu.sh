#!/usr/bin/env bash
set -euo pipefail

uuid="${1:-}"
mount_point="${2:-/mnt/yusu-f}"
link_path="${3:-$HOME/YUSU-KB}"

if [[ -z "$uuid" ]]; then
  cat >&2 <<'EOF'
Usage: mount-yusu-kb-ubuntu.sh <F_DRIVE_UUID> [mount_point] [link_path]

Find the UUID first:
  lsblk -f

Example:
  sudo bash mount-yusu-kb-ubuntu.sh 1234ABCD5678EF90
EOF
  exit 2
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run with sudo because mounting requires root." >&2
  exit 1
fi

real_user="${SUDO_USER:-$USER}"
real_uid="$(id -u "$real_user")"
real_gid="$(id -g "$real_user")"
real_home="$(getent passwd "$real_user" | cut -d: -f6)"

if ! command -v ntfs-3g >/dev/null 2>&1; then
  apt update
  apt install -y ntfs-3g
fi

mkdir -p "$mount_point"
mount -t ntfs-3g -o "uid=$real_uid,gid=$real_gid,windows_names,big_writes" "UUID=$uuid" "$mount_point"

resolved_link="${link_path/#\~/$real_home}"
ln -sfn "$mount_point/AcademicHub/0#YUSU" "$resolved_link"

echo "Mounted UUID=$uuid at $mount_point"
echo "Linked $resolved_link -> $mount_point/AcademicHub/0#YUSU"
echo "Add this to $real_home/.bashrc if wanted:"
echo "export YUSU_KB_ROOT=\"$resolved_link\""

