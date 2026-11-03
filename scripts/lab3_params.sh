#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
source "$(dirname "$(readlink -f "$0")")/edu_env.sh"
# =====================================================================
# 실습 3: 파라미터 튜닝
#  - 워크스페이스의 params/nav2_params.yaml (기본값 복사본)을 params_file로 사용합니다.
#  - 파일 안의 "### [LAB3]" 주석 위치에서 inflation_radius, 컨트롤러 플러그인을
#    바꾼 뒤 이 스크립트를 다시 실행해 차이를 비교하세요.
#  - 원본과 비교:   diff ~/nav2_edu_ws/params/nav2_params.orig.yaml ~/nav2_edu_ws/params/nav2_params.yaml
#  - 원본으로 복구: cp ~/nav2_edu_ws/params/nav2_params.orig.yaml ~/nav2_edu_ws/params/nav2_params.yaml
#  사용법: ./lab3_params.sh   (HEADLESS / USE_RVIZ 환경변수는 lab1과 동일)
# =====================================================================
set -e
HEADLESS="${HEADLESS:-False}"
USE_RVIZ="${USE_RVIZ:-True}"
PARAMS="${NAV2_EDU_WS}/params/nav2_params.yaml"

if [ ! -f "$PARAMS" ]; then
  echo "[lab3] $PARAMS 가 없습니다. 원본에서 복사합니다."
  mkdir -p "$(dirname "$PARAMS")"
  cp /opt/ros/jazzy/share/nav2_bringup/params/nav2_params.yaml "$PARAMS"
fi

# 실행 전에 YAML 문법 확인 (들여쓰기 실수 잡기)
python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$PARAMS" \
  || { echo "[lab3] YAML 문법 오류! 들여쓰기(스페이스 2칸)를 확인하세요: $PARAMS"; exit 1; }

echo "[lab3] params_file:=$PARAMS"
grep -nE "inflation_radius|FollowPath:|^\s+plugin: \"nav2_.*Controller\"" "$PARAMS" | grep -v "#" || true

nav2_edu_require_free
exec ros2 launch nav2_bringup tb3_simulation_launch.py \
  params_file:="$PARAMS" headless:="${HEADLESS}" use_rviz:="${USE_RVIZ}" "$@"
