#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
source "$(dirname "$(readlink -f "$0")")/edu_env.sh"
# =====================================================================
# 실습 1: 기본 내비게이션 (AMCL 위치추정 + 기본 지도 tb3_sandbox)
#  - Gazebo(gz sim) + RViz + Nav2 전체를 한 번에 실행합니다.
#  - 실행 후 RViz에서 "2D Pose Estimate"로 초기 위치를 찍고,
#    "Nav2 Goal"로 목표를 주면 로봇이 이동합니다.
#  사용법:
#    ./lab1_basic.sh                     # Gazebo 화면 표시
#    HEADLESS=True ./lab1_basic.sh       # Gazebo 화면 없이 (RViz만)
#    HEADLESS=True USE_RVIZ=False ./lab1_basic.sh   # 화면 없이 (검증용)
#  추가 런치 인자는 뒤에 그대로 붙이면 됩니다. 예) ./lab1_basic.sh log_level:=debug
# =====================================================================
set -e
HEADLESS="${HEADLESS:-False}"
USE_RVIZ="${USE_RVIZ:-True}"

echo "[lab1] headless:=${HEADLESS} use_rviz:=${USE_RVIZ}"
echo "[lab1] 초기 위치(2D Pose Estimate)는 대략 x=-2.0, y=-0.5, 오른쪽(+x) 방향입니다."
nav2_edu_require_free
exec ros2 launch nav2_bringup tb3_simulation_launch.py \
  headless:="${HEADLESS}" use_rviz:="${USE_RVIZ}" "$@"
