#!/usr/bin/env python3

from i3ipc.aio import Connection, Con
import asyncio
import argparse
import sys


DEFAULT_NUM_MONITORS = 2


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

    args = parser.parse_args()
    if args.command == 'switch':
        await change_workspace_maintain_mouse_pos(workspace_index=args.workspace_index, num_monitors=args.num_monitors)
    elif args.command == 'move':
        await move_container_workspace_most_likely_monitor(target_index=args.target_index, move_to_workspace=args.move_to_workspace, num_monitors=args.num_monitors)
    else:
        parser.print_help()
        return 1

    return 0


if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    sys.exit(loop.run_until_complete(main()))

