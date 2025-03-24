#!/usr/bin/env python3
# -*- coding: utf-8 -*-

## This script moves to the workspace to the left or right of the current workspace
## Usage: move_workspace_direction.py <direction>
## where direction is either 'left' or 'right'

import sys
from i3ipc.aio import Connection
import asyncio

async def move_workspace_direction(direction: str) -> None:
    # Connect to sway
    i3 = await Connection().connect()

    # Get current workspace
    tree = await i3.get_tree()
    current_workspace = tree.find_focused().workspace()
    current_num = current_workspace.num

    # Calculate target workspace number
    if direction.lower() == 'left':
        target_num = max(1, current_num - 1)  # Don't go below workspace 1
    elif direction.lower() == 'right':
        target_num = current_num + 1
    else:
        print("Invalid direction. Use 'left' or 'right'")
        return

    # Move to target workspace
    print(target_num)
    await i3.command(f'workspace number {target_num}')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: move_workspace_direction.py <direction>')
        print('where direction is either "left" or "right"')
        sys.exit(1)

    direction = sys.argv[1]

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(move_workspace_direction(direction=direction))

