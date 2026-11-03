#!/usr/bin/env bash
# =====================================================================
# nav2_edu_ws 설치 스크립트 (Ubuntu 24.04 + ROS 2 Jazzy)
#  - 이미 설치된 패키지는 건너뛰고, 빠진 apt 패키지만 설치합니다.
#  - apt upgrade / autoremove / 그래픽 드라이버는 건드리지 않습니다.
#  사용법:
#    ./install.sh          # 빠진 패키지 확인 → 확인 후 설치
#    ./install.sh --check  # 확인만 (설치 안 함)
#    ./install.sh -y       # 묻지 않고 설치
# =====================================================================
set -e
WS_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CHECK_ONLY=0
ASSUME_YES=0
for a in "$@"; do
  case "$a" in
    --check) CHECK_ONLY=1 ;;
    -y|--yes) ASSUME_YES=1 ;;
    *) echo "알 수 없는 옵션: $a"; exit 1 ;;
  esac
done

PACKAGES=(
  ros-jazzy-desktop
  ros-jazzy-navigation2
  ros-jazzy-nav2-bringup
  ros-jazzy-nav2-minimal-tb3-sim
  ros-jazzy-nav2-minimal-tb4-sim
  ros-jazzy-nav2-minimal-tb4-description
  ros-jazzy-ros-gz-sim
  ros-jazzy-ros-gz-bridge
  ros-jazzy-slam-toolbox
  ros-jazzy-spatio-temporal-voxel-layer
  ros-jazzy-teleop-twist-keyboard
)

# 1) OS 확인
. /etc/os-release
if [ "${VERSION_ID}" != "24.04" ]; then
  echo "[경고] Ubuntu ${VERSION_ID} 입니다. 이 실습은 Ubuntu 24.04 + ROS 2 Jazzy 기준입니다."
fi

# 2) ROS 2 Jazzy 확인 (본체 설치는 공식 가이드를 따름)
if [ ! -f /opt/ros/jazzy/setup.bash ]; then
  cat <<MSG
[중단] ROS 2 Jazzy가 설치되어 있지 않습니다 (/opt/ros/jazzy 없음).
       공식 가이드의 "Set up sources" → "Install ROS 2 packages (desktop)" 까지 진행한 뒤
       이 스크립트를 다시 실행하세요.
       https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
MSG
  exit 1
fi

# 3) 빠진 패키지 확인
MISSING=()
for p in "${PACKAGES[@]}"; do
  if dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed"; then
    printf "  [설치됨] %s\n" "$p"
  else
    printf "  [없음]   %s\n" "$p"
    MISSING+=("$p")
  fi
done

chmod +x "$WS_DIR"/scripts/*.sh "$WS_DIR"/scripts/*.py

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "모든 패키지가 설치되어 있습니다."
elif [ $CHECK_ONLY -eq 1 ]; then
  echo "빠진 패키지 ${#MISSING[@]}개 (--check 모드라 설치하지 않음)"
  exit 0
else
  echo
  echo "다음 명령을 실행합니다:"
  echo "  sudo apt-get update"
  echo "  sudo apt-get install --no-upgrade -y ${MISSING[*]}"
  if [ $ASSUME_YES -eq 0 ]; then
    read -r -p "진행할까요? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "취소했습니다."; exit 1; }
  fi
  sudo apt-get update
  sudo apt-get install --no-upgrade -y "${MISSING[@]}"
fi

mkdir -p "$WS_DIR/maps"
cat <<MSG

설치 확인 완료. 첫 실습 실행:
  $WS_DIR/scripts/lab1_basic.sh
자세한 내용은 $WS_DIR/README.md 를 보세요.
MSG
