# Nav2 시뮬레이션 교육 실습 (ROS 2 Jazzy + Gazebo gz sim)

TurtleBot3 시뮬레이션(`nav2_minimal_tb3_sim`)과 `nav2_bringup`의 `tb3_simulation_launch.py`를 사용합니다.
Gazebo Classic / `turtlebot3_gazebo` / `TURTLEBOT3_MODEL` 환경변수는 사용하지 않습니다.

## 설치 (Ubuntu 24.04 + ROS 2 Jazzy)

ROS 2 Jazzy(desktop)가 먼저 설치되어 있어야 합니다. 없다면 [공식 설치 가이드](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html)를 따라 설치하세요.

```bash
cd ~
git clone https://github.com/beomsuchoi/nav2_edu_ws.git
cd nav2_edu_ws
./install.sh          # 빠진 패키지만 확인 후 설치 (sudo 비밀번호 필요)
./scripts/lab1_basic.sh
```

- `./install.sh --check`: 설치 없이 확인만 합니다.
- `install.sh`는 `apt upgrade`, `autoremove`, 그래픽 드라이버를 건드리지 않습니다.
- 아래 설명은 `~/nav2_edu_ws`에 clone했다고 가정합니다. 다른 위치에 clone해도 스크립트는 동작합니다.

```
nav2_edu_ws/
├── README.md
├── install.sh                 # 필요한 apt 패키지 확인/설치
├── maps/                      # lab2에서 저장한 지도
├── params/
│   ├── nav2_params.yaml       # lab3용 (기본값 복사본 + [LAB3] 주석)
│   ├── nav2_params.orig.yaml  # 수정 전 원본 (비교/복구용)
│   └── nav2_params_stvl.yaml  # lab5용 (local costmap을 STVL로 교체)
└── scripts/
    ├── edu_env.sh             # 공용 환경 (도메인 분리, NVIDIA 렌더링 옵션)
    ├── lab1_basic.sh
    ├── lab2_slam.sh
    ├── lab3_params.sh
    ├── lab4_commander.py
    └── lab5_stvl.sh
```

## 시작 전에 꼭 알아둘 것

- **실습 전용 ROS 도메인**: 모든 실습은 `ROS_DOMAIN_ID=42`, `ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST`로 실행됩니다.
  같은 PC나 네트워크에서 도는 다른 ROS 시스템(실제 로봇 등)과 `/cmd_vel`, `/tf`, `/clock`이 섞이지 않게 하기 위해서입니다.
  **새 터미널에서 `ros2` 명령(토픽 확인, 지도 저장, teleop)을 쓸 때는 항상 먼저 아래를 실행하세요.**
  ```bash
  source /opt/ros/jazzy/setup.bash && source ~/nav2_edu_ws/scripts/edu_env.sh
  ```
  Gazebo 내부 통신도 `GZ_PARTITION=nav2_edu_42`, `GZ_IP=127.0.0.1`로 분리합니다. ROS 도메인과 별개라서, 이게 없으면 다른 `gz sim`과 `/scan`, `/cmd_vel`이 섞입니다.
  이걸 빼먹으면 `ros2 topic list`에 아무것도 안 보입니다. 도메인 번호를 바꾸려면 `NAV2_EDU_DOMAIN_ID=43 ./lab1_basic.sh`처럼 실행합니다.
- **공통 옵션** (모든 `.sh` 스크립트)
  - `HEADLESS=True` : Gazebo 창 없이 실행 (기본 `False` = 창 표시)
  - `USE_RVIZ=False` : RViz 없이 실행
  - `USE_NVIDIA=1` : Gazebo/RViz를 NVIDIA GPU로 렌더링 (기본은 Intel 내장 GPU)
  - 런치 인자 추가: `./lab1_basic.sh map:=/경로/지도.yaml`
- 종료는 실행한 터미널에서 `Ctrl+C`. 완전히 꺼지는 데 10~20초 걸릴 수 있습니다.

---

## 실습 1: 기본 내비게이션 (AMCL + 기본 지도)

```bash
~/nav2_edu_ws/scripts/lab1_basic.sh
```

1. Gazebo 창(로봇과 육각형 벽 + 기둥 9개)과 RViz가 뜹니다.
2. RViz 상단 **2D Pose Estimate**를 누르고, 로봇의 실제 위치(약 x=-2.0, y=-0.5)를 클릭한 다음 오른쪽(+x 방향)으로 드래그합니다.
3. **Nav2 Goal**로 목표 지점을 찍으면 로봇이 이동합니다.

**정상 동작 시 확인할 것**
- 초기 위치를 찍기 전에는 RViz에 지도가 안 보이거나 "Global Status: Error"가 보일 수 있습니다. **정상입니다.**
- 초기 위치를 찍으면 레이저 스캔(빨간 점)이 지도 벽과 겹치고, 초록 파티클(AMCL)이 로봇 주변에 모입니다.
- 목표를 주면 전역 경로(선)가 그려지고 로봇이 따라가며, 파티클 구름이 점점 작아집니다.
- 터미널에 `Managed nodes are active`가 2번(localization, navigation) 출력됩니다.

## 실습 2: SLAM (지도 만들기)

```bash
~/nav2_edu_ws/scripts/lab2_slam.sh
```

- slam_toolbox가 지도를 실시간으로 만듭니다. 초기 위치 지정은 필요 없습니다.
- **Nav2 Goal**로 아직 회색(미탐색)인 영역 근처를 찍거나, 키보드로 직접 운전합니다.
  ```bash
  source /opt/ros/jazzy/setup.bash && source ~/nav2_edu_ws/scripts/edu_env.sh
  ros2 run teleop_twist_keyboard teleop_twist_keyboard
  ```
- **지도 저장** (lab2는 켜 둔 채로 새 터미널에서):
  ```bash
  source /opt/ros/jazzy/setup.bash && source ~/nav2_edu_ws/scripts/edu_env.sh
  ros2 run nav2_map_server map_saver_cli -f ~/nav2_edu_ws/maps/my_map
  ```
- 저장한 지도로 AMCL 실습: `~/nav2_edu_ws/scripts/lab1_basic.sh map:=$HOME/nav2_edu_ws/maps/my_map.yaml`

**정상 동작 시**: 로봇이 움직일수록 RViz의 지도(흰색=빈 공간, 검정=벽)가 넓어집니다. 지도를 저장하면 `maps/`에 `my_map.yaml`과 `my_map.pgm`이 생깁니다.

## 실습 3: 파라미터 튜닝

```bash
~/nav2_edu_ws/scripts/lab3_params.sh
```

`params/nav2_params.yaml`에서 `### [LAB3]` 주석이 붙은 곳을 수정하고, `Ctrl+C`로 끈 뒤 다시 실행해서 비교합니다.

| 바꿀 것 | 위치 | 해 볼 것 |
|---|---|---|
| `inflation_radius` | local_costmap, global_costmap | 0.30 / 0.70(기본) / 1.00 |
| `FollowPath.plugin` | controller_server | MPPI(기본) → Regulated Pure Pursuit |

- **재시작 없이** 팽창 반경만 바꿔보기 (lab3 실행 중, 새 터미널에서):
  ```bash
  source /opt/ros/jazzy/setup.bash && source ~/nav2_edu_ws/scripts/edu_env.sh
  ros2 param set /global_costmap/global_costmap inflation_layer.inflation_radius 0.3
  ros2 param set /local_costmap/local_costmap inflation_layer.inflation_radius 0.3
  ```
  컨트롤러 플러그인은 실행 중에 바꿀 수 없으므로 재시작해야 합니다.
- 원본과 비교: `diff ~/nav2_edu_ws/params/nav2_params.orig.yaml ~/nav2_edu_ws/params/nav2_params.yaml`
- 원본으로 되돌리기: `cp ~/nav2_edu_ws/params/nav2_params.orig.yaml ~/nav2_edu_ws/params/nav2_params.yaml`

**RPP로 바꿨을 때 정상적으로 보이는 현상**: lab4를 돌리면 1번 → 2번 웨이포인트 구간(기둥 사이 좁은 틈)에서
`RegulatedPurePursuitController detected collision ahead!` 경고와 `[ERROR] Controller patience exceeded`가 몇 번 나오고,
로봇이 잠깐 멈췄다가(costmap 초기화·경로 재계산 복구 동작) 다시 출발해 결국 성공합니다.
Pure Pursuit은 경로 코너를 질러가는 성질이 있어 좁은 틈에서 충돌 검사에 걸리기 쉽기 때문이며, MPPI(기본값)에서는 나오지 않습니다.
→ **두 컨트롤러의 차이를 관찰하는 포인트**로 활용하세요. (`lookahead_dist`, `desired_linear_vel`을 바꿔가며 경고 횟수 비교)

**정상 동작 시**: 실행할 때 터미널에 현재 `inflation_radius`와 컨트롤러 plugin 값이 출력됩니다. RViz costmap에서 벽 주변의 색칠된 띠 두께가 반경에 따라 달라지고, 경로가 벽에서 떨어지는 거리도 달라집니다.

## 실습 4: Python으로 웨이포인트 순회 (nav2_simple_commander)

```bash
# 터미널 1
~/nav2_edu_ws/scripts/lab1_basic.sh
# 터미널 2 (lab1이 다 뜬 뒤)
source /opt/ros/jazzy/setup.bash
python3 ~/nav2_edu_ws/scripts/lab4_commander.py
```

스크립트가 초기 위치 설정 → Nav2 활성화 대기 → 웨이포인트 3개 순회 → 결과 출력까지 자동으로 진행합니다. 도메인 42도 스크립트 안에서 자동으로 맞춥니다.
웨이포인트를 바꾸려면 `lab4_commander.py`의 `WAYPOINTS`를 수정하세요. 좌표는 지도의 빈 공간이어야 합니다.

**정상 출력 예**
```
[lab4] 초기 위치 설정: (-2.0, -0.5, 0.0)
[lab4] Nav2 활성화 완료
[lab4] 웨이포인트 1/3 (0.5, -1.5) 로 이동 중...
[lab4] 웨이포인트 2/3 (1.8, 0.0) 로 이동 중...
[lab4] 웨이포인트 3/3 (0.5, 1.8) 로 이동 중...
[lab4] 결과: 성공 - 모든 웨이포인트 순회 완료
```

## 실습 5: STVL (시간에 따라 사라지는 장애물 레이어)

```bash
~/nav2_edu_ws/scripts/lab5_stvl.sh
```

- STVL이 설치되어 있지 않으면 설치 방법을 안내하고 종료합니다 (`sudo apt install ros-jazzy-spatio-temporal-voxel-layer`).
- `params/nav2_params_stvl.yaml`의 `voxel_decay`(초)를 바꿔 보세요. 로봇 앞에 Gazebo에서 물체를 놓았다가 치웠을 때 costmap에서 사라지는 시간이 달라집니다.
- RViz: **Add → By topic → `/local_costmap/voxel_grid`**로 복셀을 확인합니다.

---

## 자주 나는 에러와 해결

| 증상 | 원인 | 해결 |
|---|---|---|
| `Timed out waiting for transform from base_link to map` 가 계속 출력됨 | AMCL 초기 위치를 아직 안 줌 | RViz **2D Pose Estimate**로 초기 위치 지정 (lab4는 자동) |
| `AMCL cannot publish a pose ... Please set the initial pose` | 위와 같음 | 위와 같음 |
| 다른 터미널에서 `ros2 topic list`에 `/scan` 등이 안 보임 | 도메인 불일치 | `source ~/nav2_edu_ws/scripts/edu_env.sh` 후 다시 확인 |
| Gazebo 창이 검은 화면이거나 매우 느림 | 기본으로 Intel 내장 GPU로 렌더링됨 (PRIME on-demand) | `USE_NVIDIA=1 ./lab1_basic.sh` (드라이버 변경 없이 NVIDIA로 렌더링) |
| Gazebo 창이 아예 안 뜸 / Qt·OpenGL 에러 (Wayland 세션) | Wayland 세션 | 로그인 화면 톱니바퀴에서 **"Ubuntu on Xorg"** 선택, 또는 `QT_QPA_PLATFORM=xcb ./lab1_basic.sh` |
| 로봇이 혼자 움직이거나 odom/스캔이 튀는 등 이상하게 동작함 | 같은 PC의 다른 `gz sim`과 Gazebo 토픽이 섞임 (ROS_DOMAIN_ID로는 분리 안 됨) | 스크립트로 실행하면 자동 분리됨. `ros2 launch`를 직접 쓸 때는 `edu_env.sh`를 먼저 source |
| `[중단] 이미 실습이 실행 중입니다` | 다른 터미널에서 실습이 이미 실행 중 (두 개를 같이 띄우면 서로의 노드가 섞여 둘 다 망가짐) | 실행 중인 실습을 `Ctrl+C`로 끄고 다시 실행 |
| `Failed to bring up all requested nodes` / `Publisher already registered for node name` | 같은 도메인에서 Nav2가 2개 실행됨 (`ros2 launch`를 직접 실행한 경우 등) | 모두 끄고(아래 정리 명령) 하나만 실행 |
| 이전 실습이 덜 꺼져서 로봇이 2대이거나 이상하게 동작함 | 남아 있는 `gz sim` 프로세스 | `pkill -f "gz sim"; pkill -f component_container_isolated` 후 재실행 |
| `Ctrl+C`로 끌 때 `Magick: abort due to signal 11` / `process has died ... exit code -6` | Nav2 컨테이너가 종료 단계에서 크래시 (실행 중 동작에는 영향 없음) | 무시해도 됩니다. Ubuntu가 "시스템 프로그램 문제 발생" 창을 띄우면 닫으세요 |
| lab3 실행 시 `YAML 문법 오류` | 수정하면서 들여쓰기가 깨짐 (탭 사용 등) | 스페이스 2칸 들여쓰기 확인. 안 되면 orig로 복구 |
| lab4가 `Nav2 활성화 완료`에서 멈추거나 `실패`로 끝남 | lab1이 안 떠 있음 / 다른 지도 사용 | lab1 먼저 실행. 다른 지도면 `WAYPOINTS` 수정 |
| `Package 'nav2_bringup' not found` | ROS 환경 미설정 | `source /opt/ros/jazzy/setup.bash` |

---

## 라이선스

Apache License 2.0 (`LICENSE`). `params/`의 YAML 파일은 [Nav2](https://github.com/ros-navigation/navigation2) `nav2_bringup`의 `nav2_params.yaml`(Apache-2.0)을 바탕으로 수정한 것입니다.
