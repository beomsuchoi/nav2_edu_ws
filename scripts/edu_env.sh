# nav2_edu_ws 공용 환경 (lab 스크립트가 자동으로 source 합니다)
# 다른 터미널(지도 저장, teleop, ros2 topic 등)에서도 반드시 먼저 실행하세요:
#   source /opt/ros/jazzy/setup.bash && source ~/nav2_edu_ws/scripts/edu_env.sh
# 같은 PC에서 돌고 있는 다른 ROS 시스템/실제 로봇과 섞이지 않도록
# 실습 전용 도메인 + 이 PC 내부(LOCALHOST)로만 통신합니다.
# 도메인을 바꾸려면: NAV2_EDU_DOMAIN_ID=43 ./lab1_basic.sh
# 워크스페이스 경로 (이 파일 위치 기준이라 어디에 clone해도 동작)
NAV2_EDU_WS="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
export NAV2_EDU_WS

export ROS_DOMAIN_ID="${NAV2_EDU_DOMAIN_ID:-42}"
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST

# Gazebo/RViz를 NVIDIA GPU로 렌더링 (PRIME on-demand 노트북용, 드라이버 변경 없음)
#   기본: Intel 내장 GPU로 렌더링 → 느리거나 검은 화면이면  USE_NVIDIA=1 ./lab1_basic.sh
if [ "${USE_NVIDIA:-0}" = "1" ]; then
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
fi

# Gazebo(gz-transport) 통신 격리: ROS_DOMAIN_ID와 별개라서 따로 설정해야 합니다.
# 이게 없으면 같은 PC/네트워크의 다른 gz sim과 /scan, /odom, /cmd_vel 이 섞입니다.
export GZ_PARTITION="nav2_edu_${ROS_DOMAIN_ID}"
export GZ_IP=127.0.0.1
