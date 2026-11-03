#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
source "$(dirname "$(readlink -f "$0")")/edu_env.sh"
# =====================================================================
# 실습 2: SLAM (slam_toolbox로 지도 작성하면서 내비게이션)
#  - 기본 지도 대신 slam_toolbox가 /map 을 실시간으로 만듭니다.
#  - SLAM 모드에서는 AMCL을 쓰지 않으므로 2D Pose Estimate가 필요 없습니다.
#  - RViz의 "Nav2 Goal"로 미탐색 영역 근처를 찍거나, 키보드로 직접 몰아서 지도를 넓혀보세요.
#  사용법: ./lab2_slam.sh   (HEADLESS / USE_RVIZ 환경변수는 lab1과 동일)
# =====================================================================
set -e
HEADLESS="${HEADLESS:-False}"
USE_RVIZ="${USE_RVIZ:-True}"
MAP_DIR="${NAV2_EDU_WS}/maps"
mkdir -p "$MAP_DIR"

cat <<MSG
[lab2] ---------------------------------------------------------------
 지도를 다 그렸으면 "새 터미널"에서 아래 명령으로 저장하세요 (이 창은 끄지 말 것):

   source /opt/ros/jazzy/setup.bash && source ${NAV2_EDU_WS}/scripts/edu_env.sh
   ros2 run nav2_map_server map_saver_cli -f ${MAP_DIR}/my_map

   → ${MAP_DIR}/my_map.yaml, my_map.pgm 생성

 키보드로 로봇 몰기 (새 터미널):
   source /opt/ros/jazzy/setup.bash && source ${NAV2_EDU_WS}/scripts/edu_env.sh
   ros2 run teleop_twist_keyboard teleop_twist_keyboard

 저장한 지도로 AMCL 실행 (lab1과 동일, 지도만 교체):
   ${NAV2_EDU_WS}/scripts/lab1_basic.sh map:=${MAP_DIR}/my_map.yaml
[lab2] ---------------------------------------------------------------
MSG

exec ros2 launch nav2_bringup tb3_simulation_launch.py \
  slam:=True headless:="${HEADLESS}" use_rviz:="${USE_RVIZ}" "$@"
