#!/usr/bin/env python3

import sys
from i3ipc.aio import Connection, Con
import asyncio

APPLICATIONS = {
    # 'firefox': 'MOZ_ENABLE_WAYLAND=1 firefox',
#     'obsidian': 'flatpak run md.obsidian.Obsidian',
#     'wezterm': 'flatpak run org.wezfurlong.wezterm --config-file ~/.config/wezterm/wezterm.lua'
}

def get_container(tree: Con, window_name: str):
    container = tree.find_named(rf'.*{window_name}|{window_name.capitalize()}*')
    if container:
        return container

    container = tree.find_classed(rf'.*{window_name}|{window_name.capitalize()}*')
    if container:
        return container

    container = tree.find_titled(rf'.*{window_name}|{window_name.capitalize()}*')
    if container:
        return container

    container = tree.find_instanced(rf'.*{window_name}|{window_name.capitalize()}*')
    if container:
        return container

    # look in app_id
    for c in tree.descendants():
        if not c.app_id:
            continue
        if window_name in c.app_id:
            container = [c]

    return container

async def exec_or_move(window_name: str) -> None:
    i3 = await Connection().connect()
    tree = await i3.get_tree()

    container = get_container(tree, window_name)

    if not container:
        print('Window not found')

        # create application window
        container = await i3.command(f'exec {APPLICATIONS.get(window_name.lower(), window_name.lower())}')

        return

    container = container[0]

    if container.workspace().num == tree.find_focused().workspace().num:
        # do nothing if window is already on current workspace
        print('Window is already on current workspace')
        return

    # move to current workspace
    _ = await i3.command(f'[con_id={container.id}] move container to workspace current')
    # focus on newly created window
    _ = await i3.command(f'[con_id={container.id}] focus')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: exec_or_move.py <window_name>')
        sys.exit(1)

    window_name = sys.argv[1]

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(exec_or_move(window_name=window_name))

