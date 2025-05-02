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

async def list_workspaces(verbose: bool = False):
    i3 = await Connection().connect()
    workspaces = await i3.get_workspaces()

    for ws in workspaces:
        output_info = f" on {ws.output}" if verbose else ""
        focused_marker = "* " if ws.focused else "  "
        print(f"{focused_marker}{ws.name}{output_info}")

    return workspaces

async def move_container(target_workspace: str):
    i3 = await Connection().connect()
    await i3.command(f"move container to workspace {target_workspace}")

async def main():
    parser = argparse.ArgumentParser(description="Multi workspace helper for Sway/i3")
    subparsers = parser.add_subparsers(dest='command', help='Subcommand to run')

    switch_parser = subparsers.add_parser('switch', help='Switch to workspace')
    switch_parser.add_argument('workspace_index', type=int, help='Workspace index to switch to')
    switch_parser.add_argument('--monitors', '-m', type=int, default=DEFAULT_NUM_MONITORS,
                              help=f'Number of monitors (default: {DEFAULT_NUM_MONITORS})')

    list_parser = subparsers.add_parser('list', help='List workspaces')
    list_parser.add_argument('--verbose', '-v', action='store_true', help='Show verbose output')

    move_parser = subparsers.add_parser('move', help='Move container to workspace')
    move_parser.add_argument('target', type=str, help='Target workspace name/number')

    args = parser.parse_args()
    if args.command == 'switch':
        await change_workspace_maintain_mouse_pos(args.workspace_index, args.monitors)
    elif args.command == 'list':
        await list_workspaces(args.verbose)
    elif args.command == 'move':
        await move_container(args.target)
    else:
        parser.print_help()
        return 1

    return 0

if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    sys.exit(loop.run_until_complete(main()))

