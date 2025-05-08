#!/usr/bin/env python3

from i3ipc.aio import Connection, Con
import asyncio
import os
import argparse
import sys
from enum import Enum


DEFAULT_NUM_MONITORS = 2
# DEFAULT_STATE_FILE = """
# left active
# right active
# """

async def change_workspace_maintain_mouse_pos(workspace_index: int, num_monitors: int = DEFAULT_NUM_MONITORS):
    # Function behavior:
    # bindsym --no-warn --no-repeat $mod+1 workspace number 10; workspace number 11; exec "echo 1 > $SOV_SOCK"
    # Get the tree and work out which workspace currently has the focussed window
    # change the workspace to the one provided (workspace index)
    # so there a 2 monitors with each workspace making up workspace names
    # 10 11, 20 21, 30 31, 40 41 ....
    # where 10 11 has an workspace_index of 1, 20 21 has an workspace_index of 2 ....

    # Move to a workspace
    i3 = await Connection().connect()
    tree: Con = await i3.get_tree()

    focused_window = tree.find_focused()
    assert focused_window is not None
    focused_workspace = focused_window.workspace().name
    focused_index = int(focused_workspace[-1:])

    commands = [f"workspace {workspace_index}{focused_index}"]
    for monitor_index in range(num_monitors):
        if f"workspace {workspace_index}{monitor_index}" not in commands:
            commands.insert(0, f"workspace {workspace_index}{monitor_index}")

    for command in commands:
        await i3.command(command)


def get_workspace_leaves(workspaces: list[Con], workspace_name: str) -> list[Con]:
    # Get the leaves of a workspace by name
    for workspace in workspaces:
        if workspace.name == workspace_name:
            return len(workspace.leaves())
    return 0

async def move_container_workspace_most_likely_monitor(target_index: int, move_to_workspace: bool = False, num_monitors: int = DEFAULT_NUM_MONITORS):
    i3 = await Connection().connect()

    # work out which wokspace within the target_index has the leasrt number of windows for if target_index is 2
    # then the workspace names are 20 21 - check each workspace and get the number of windows then send the window
    # to the workspace with the least number of windows
    # bindsym --no-warn $mod+Ctrl+Shift+1 move container to workspace number 1, workspace number 1

    tree: Con = await i3.get_tree()
    workspaces = tree.workspaces()
    target_workspaces = [{"name": f"{target_index}{i}"} for i in range(num_monitors)]
    # get each workspace leaves
    for workspace in target_workspaces:
        workspace["leaves"] = get_workspace_leaves(workspaces, workspace["name"])

    # sort the workspaces by the number of leaves
    target_workspaces.sort(key=lambda x: x["leaves"])

    target_workspace = target_workspaces[0]["name"] if len(target_workspaces) > 0 else f"{target_index}0"
    target_workspaces_names = [f"{target_index}{i}" for i in range(num_monitors)]

    target_workspaces_names.remove(target_workspace)

    command = f"move container to workspace number {target_workspace}"
    if move_to_workspace:
        for workspace in target_workspaces_names:
            if workspace != target_workspace:
                command += f"; workspace number {workspace}"

        # make sure at end
        command += f"; workspace number {target_workspace}"

    # print(command)
    await i3.command(command)

# class MonitorPosition(int, Enum):
#     left = 0
#     right = 1
#
# def save_state(monitor_state_fp: str = "/tmp/monitor.state", monitor_state: str = DEFAULT_STATE_FILE):
#     with open(monitor_state_fp, "w") as state_file:
#         state_file.write(monitor_state)
#
# def load_state(monitor_state_fp: str = "/tmp/monitor.state"):
#     # assumie its the fist time running and wrtite the default state
#     if not os.path.exists(monitor_state_fp):
#         save_state(monitor_state_fp=monitor_state_fp, monitor_state=DEFAULT_STATE_FILE)
#
#     _monitor_state = dict(
#         left=None,
#         right=None
#     )
#     with (monitor_state_fp, "r") as state:
#         line_state = state.readline()
#         if line_state.startswith("left"):
#             _, left_state = line_state.split(" ")
#             if left_state == "active":
#                 left_state = True
#             elif left_state == "disabled":
#                 left_state = False
#             else:
#                 raise ValueError("Invalid state file format")
#             _monitor_state["left"] = left_state
#
#         elif line_state.startswith("right"):
#             _, right_state = line_state.split(" ")
#             if right_state == "active":
#                 right_state = True
#             elif right_state == "disabled":
#                 right_state = False
#             else:
#                 raise ValueError("Invalid state file format")
#             _monitor_state["right"] = right_state
#
#     if any(v is None for v in _monitor_state.values()):
#         raise ValueError("Invalid state file format")
#
#     return _monitor_state

def get_monitor_position(monitor_serial: str):
    # Left
    # set $first "Dell Inc. DELL U3023E 66YJ4H3"
    # Right
    # set $second "Dell Inc. DELL U3023E 40G15H3"
    monitors = {
        "40G15H3": "right",
        "66YJ4H3": "left"
    }
    return monitors.get(monitor_serial)

async def toggle_monitor(monitor_pos: str):
    # NOTE: this only works for 2 monitors
    i3 = await Connection().connect()

    # set $first "Dell Inc. DELL U3023E 66YJ4H3" == left
    # set $second "Dell Inc. DELL U3023E 40G15H3" == right
    outputs_state = {get_monitor_position(output.serial) : {"active": output.active, "monitor_id": f"{output.make} {output.model} {output.serial}"} for output in await i3.get_outputs()}

    outputs_state[monitor_pos]["active"] = not outputs_state[monitor_pos]["active"]

    # check if both not active - and exit early
    if not outputs_state["left"]["active"] and not outputs_state["right"]["active"]:
        raise ValueError("Both monitors will be inactive")

    # toggle the monitor
    print(f"output '{outputs_state[monitor_pos]['monitor_id']}' toggle")
    await i3.command(f"output '{outputs_state[monitor_pos]['monitor_id']}' toggle")

    # are we disabling a monitor
    if not outputs_state[monitor_pos]["active"]:
        # move all the windows within the monitor_index to the other monitor

        # source here is the monitor we are disabling
        source_monitor_index = 0 if monitor_pos == "left" else 1
        target_monitor_index = int(not source_monitor_index)

        tree: Con = await i3.get_tree()
        for workspace in tree.workspaces():
            # i.e. 10 11 and target_monitor_index is 1 then move all the windows to 11
            if workspace.name.endswith(str(source_monitor_index)):
                for window in workspace.leaves():
                    print(f"[app_id={window.app_id}] move container to workspace number {workspace.name[0]}{target_monitor_index}")
                    await i3.command(f"[app_id={window.app_id}] move container to workspace number {workspace.name[0]}{target_monitor_index}")


async def main():
    parser = argparse.ArgumentParser(description="Multi workspace helper for Sway/i3")
    subparsers = parser.add_subparsers(dest='command', help='Subcommand to run')

    switch_parser = subparsers.add_parser('switch', help='Switch to workspace')
    switch_parser.add_argument('workspace_index', type=int, help='Workspace index to switch to')
    switch_parser.add_argument('--num-monitors', '-n', type=int, default=DEFAULT_NUM_MONITORS,
                              help=f'Number of monitors (default: {DEFAULT_NUM_MONITORS})')

    move_parser = subparsers.add_parser('move', help='Move container to workspace')
    move_parser.add_argument('target_index', type=int, help='Target workspace index')
    move_parser.add_argument("--move-to-workspace", action='store_true', help="Move to the workspace after moving the container", default=False)
    move_parser.add_argument('--num-monitors', '-n', type=int, default=DEFAULT_NUM_MONITORS,
                              help=f'Number of monitors (default: {DEFAULT_NUM_MONITORS})')

    toggle_parser = subparsers.add_parser('toggle', help='Toggle monitor state')
    toggle_parser.add_argument("monitor_position", type=str, choices=["left", "right"], help="Monitor position to toggle")

    args = parser.parse_args()
    if args.command == 'switch':
        await change_workspace_maintain_mouse_pos(workspace_index=args.workspace_index, num_monitors=args.num_monitors)
    elif args.command == 'move':
        await move_container_workspace_most_likely_monitor(target_index=args.target_index, move_to_workspace=args.move_to_workspace, num_monitors=args.num_monitors)
    elif args.command == "toggle":
        await toggle_monitor(monitor_pos=args.monitor_position)
    else:
        parser.print_help()
        return 1

    return 0


if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    sys.exit(loop.run_until_complete(main()))

