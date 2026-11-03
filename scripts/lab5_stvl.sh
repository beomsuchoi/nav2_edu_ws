#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
source "$(dirname "$(readlink -f "$0")")/edu_env.sh"
# =====================================================================
# 실습 5: STVL (Spatio-Temporal Voxel Layer)
#  - local costmap의 장애물 레이어를 STVL로 바꿔 실행합니다.
#  - STVL은 관측된 장애물을 일정 시간(voxel_decay) 후 지워서, 움직이는 사람/물체가
#    지나간 자리에 '유령 장애물'이 남지 않게 합니다.
#  - 파라미터: ~/nav2_edu_ws/params/nav2_params_stvl.yaml 의 "[LAB5]" 주석 참고
#  사용법: ./lab5_stvl.sh   (HEADLESS / USE_RVIZ 환경변수는 lab1과 동일)
# =====================================================================
HEADLESS="${HEADLESS:-False}"
USE_RVIZ="${USE_RVIZ:-True}"
PARAMS="${NAV2_EDU_WS}/params/nav2_params_stvl.yaml"

if ! ros2 pkg prefix spatio_temporal_voxel_layer >/dev/null 2>&1; then
  cat <<MSG
[lab5] STVL(spatio_temporal_voxel_layer) 패키지가 설치되어 있지 않습니다.
       이 실습은 STVL이 설치된 경우에만 동작합니다.
       설치 (Jazzy apt 패키지 있음):
         sudo apt install ros-jazzy-spatio-temporal-voxel-layer
       설치 후 다시 실행하세요.
MSG
  exit 0
fi

if [ ! -f "$PARAMS" ]; then
  echo "[lab5] 파라미터 파일이 없습니다: $PARAMS"
  exit 1
fi

echo "[lab5] STVL 사용, params_file:=$PARAMS"
echo "[lab5] RViz: Add → By topic → /local_costmap/voxel_grid (PointCloud2) 로 복셀 확인"
nav2_edu_require_free
exec ros2 launch nav2_bringup tb3_simulation_launch.py \
  params_file:="$PARAMS" headless:="${HEADLESS}" use_rviz:="${USE_RVIZ}" "$@"
