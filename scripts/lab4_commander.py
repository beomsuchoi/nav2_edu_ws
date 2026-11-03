#!/usr/bin/env python3
# 실행 전: source /opt/ros/jazzy/setup.bash
# =====================================================================
# 실습 4: nav2_simple_commander로 웨이포인트 3개 순회
#  1) 다른 터미널에서 lab1_basic.sh 를 먼저 실행 (AMCL + 기본 지도 tb3_sandbox)
#  2) 이 터미널에서:
#       source /opt/ros/jazzy/setup.bash
#       python3 ~/nav2_edu_ws/scripts/lab4_commander.py
#  흐름: 초기 위치 설정 → Nav2 활성화 대기 → 웨이포인트 순회 → 결과 출력
#  웨이포인트 좌표는 tb3_sandbox 지도의 빈 공간(장애물에서 0.45m 이상)입니다.
#  다른 지도를 쓰면 WAYPOINTS 좌표를 바꿔야 합니다.
# =====================================================================
import math
import os
import sys

# edu_env.sh 와 같은 실습 전용 도메인 (rclpy.init() 전에 설정해야 적용됨)
os.environ['ROS_DOMAIN_ID'] = os.environ.get('NAV2_EDU_DOMAIN_ID', '42')
os.environ['ROS_AUTOMATIC_DISCOVERY_RANGE'] = 'LOCALHOST'

try:
    import rclpy
    from geometry_msgs.msg import PoseStamped
    from nav2_simple_commander.robot_navigator import BasicNavigator, TaskResult
except ImportError as e:
    sys.exit(f'[lab4] ROS 2 모듈을 찾을 수 없습니다 ({e}).\n'
             '       먼저 "source /opt/ros/jazzy/setup.bash" 를 실행하세요.')

# tb3_simulation_launch.py 의 로봇 스폰 위치 (x_pose=-2.0, y_pose=-0.5)
INITIAL_POSE = (-2.0, -0.5, 0.0)  # x, y, yaw(rad)

# 순회할 웨이포인트 (x, y, yaw[rad]) - map 좌표계
WAYPOINTS = [
    (0.5, -1.5, 0.0),
    (1.8, 0.0, math.pi / 2),
    (0.5, 1.8, math.pi),
]


def make_pose(navigator, x, y, yaw):
    pose = PoseStamped()
    pose.header.frame_id = 'map'
    pose.header.stamp = navigator.get_clock().now().to_msg()
    pose.pose.position.x = x
    pose.pose.position.y = y
    pose.pose.orientation.z = math.sin(yaw / 2.0)
    pose.pose.orientation.w = math.cos(yaw / 2.0)
    return pose


def main():
    rclpy.init()
    navigator = BasicNavigator()

    # 1) 초기 위치 설정 (RViz의 "2D Pose Estimate"와 같은 역할)
    navigator.setInitialPose(make_pose(navigator, *INITIAL_POSE))
    print(f'[lab4] 초기 위치 설정: {INITIAL_POSE}')

    # AMCL과 bt_navigator가 active 될 때까지 대기
    navigator.waitUntilNav2Active()
    print('[lab4] Nav2 활성화 완료')

    # 2) 웨이포인트 순회
    goals = [make_pose(navigator, *wp) for wp in WAYPOINTS]
    navigator.followWaypoints(goals)

    last_index = -1
    while not navigator.isTaskComplete():
        feedback = navigator.getFeedback()
        if feedback and feedback.current_waypoint != last_index:
            last_index = feedback.current_waypoint
            print(f'[lab4] 웨이포인트 {last_index + 1}/{len(goals)} '
                  f'{WAYPOINTS[last_index][:2]} 로 이동 중...')

    # 3) 결과 출력
    result = navigator.getResult()
    if result == TaskResult.SUCCEEDED:
        print('[lab4] 결과: 성공 - 모든 웨이포인트 순회 완료')
    elif result == TaskResult.CANCELED:
        print('[lab4] 결과: 취소됨')
    elif result == TaskResult.FAILED:
        print('[lab4] 결과: 실패 - 초기 위치/웨이포인트 좌표, Nav2 로그를 확인하세요')
    else:
        print(f'[lab4] 결과: 알 수 없음 ({result})')

    navigator.destroyNode()
    rclpy.shutdown()
    return 0 if result == TaskResult.SUCCEEDED else 1


if __name__ == '__main__':
    sys.exit(main())
