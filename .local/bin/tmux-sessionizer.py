#!/usr/bin/env python3

import os
import subprocess
import sys
from dataclasses import dataclass
from enum import Enum
from pathlib import Path


class ProjectType(Enum):
    NESTED = "nested"
    SINGLE = "single"


@dataclass
class Project:
    path: Path
    type: ProjectType


@dataclass
class FolderInfo:
    path: Path
    is_open: bool


PROJECTS = [
    Project(path=Path("/home/tcrha/dotfiles"), type=ProjectType.SINGLE),
    Project(path=Path("/home/tcrha/qbe"), type=ProjectType.NESTED),
]


def get_active_sessions() -> set[str]:
    """Get list of active tmux session names."""
    try:
        result = subprocess.run(
            ["tmux", "list-sessions", "-F", "#{session_name}"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            return set()
        return {name for name in result.stdout.strip().split("\n") if name}
    except FileNotFoundError:
        return set()


def is_tmux_running() -> bool:
    """Check if tmux is running."""
    result = subprocess.run(["pgrep", "tmux"], capture_output=True)
    return result.returncode == 0


def tmux_session_exists(name: str) -> bool:
    """Check if a tmux session with the given name exists."""
    result = subprocess.run(
        ["tmux", "has-session", "-t=" + name],
        capture_output=True,
    )
    return result.returncode == 0


def run_fzf(items: list[str]) -> str | None:
    """Run fzf with the given items and return the selected item."""
    try:
        result = subprocess.run(
            ["fzf", "--layout=reverse", "--tmux", "center", "--ansi"],
            input="\n".join(items),
            capture_output=True,
            text=True,
        )
        if result.returncode in (1, 130):  # No selection or Ctrl-C
            return None
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except FileNotFoundError:
        sys.exit(1)


if __name__ == "__main__":
    active_sessions = get_active_sessions()

    # Build folders map
    folders: dict[str, FolderInfo] = {}

    for project in PROJECTS:
        if project.type == ProjectType.SINGLE:
            name = os.path.basename(project.path)
            session_name = name.replace(".", "_")
            folders[name] = FolderInfo(
                path=project.path,
                is_open=session_name in active_sessions,
            )
        else:
            try:
                for entry in os.scandir(project.path):
                    if entry.is_dir():
                        session_name = entry.name.replace(".", "_")
                        folders[entry.name] = FolderInfo(
                            path=Path(entry.path),
                            is_open=session_name in active_sessions,
                        )
            except FileNotFoundError:
                continue

    if not folders:
        sys.exit(1)

    # Separate and sort open/closed sessions
    open_names = sorted([name for name, info in folders.items() if info.is_open])
    closed_names = sorted([name for name, info in folders.items() if not info.is_open])

    # Build fzf input with prefixes
    names = ["🟢 " + name for name in open_names] + ["   " + name for name in closed_names]

    selected = run_fzf(names)
    if not selected:
        sys.exit(0)

    # Strip the prefix
    selected = selected.removeprefix("🟢 ").removeprefix("   ")

    selected_path = folders[selected].path
    selected_name = os.path.basename(selected).replace(".", "_")

    in_tmux = os.environ.get("TMUX") is not None and os.environ.get("TMUX") != ""
    tmux_running = is_tmux_running()

    if not in_tmux and not tmux_running:
        # Start new tmux session and attach with nvim
        subprocess.run(
            ["tmux", "new-session", "-s", selected_name, "-c", selected_path]
        )
        sys.exit(0)

    # Check if session exists
    if not tmux_session_exists(selected_name):
        # Create detached session with nvim
        subprocess.run(
            ["tmux", "new-session", "-ds", selected_name, "-c", selected_path]
        )

    if not in_tmux:
        # Attach to session
        subprocess.run(["tmux", "attach", "-t", selected_name])
    else:
        # Switch client to session
        subprocess.run(["tmux", "switch-client", "-t", selected_name])

