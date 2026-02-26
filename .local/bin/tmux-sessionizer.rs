use std::collections::{HashMap, HashSet};
use std::env;
use std::fs;
use std::io::Write;
use std::process::{Command, Stdio};

#[derive(Clone, Copy)]
enum ProjectType {
    Nested,
    Single,
}

struct Project {
    path: &'static str,
    project_type: ProjectType,
}

struct FolderInfo {
    path: String,
    is_open: bool,
}

const PROJECTS: &[Project] = &[
    Project {
        path: "/home/tcrha/dotfiles",
        project_type: ProjectType::Single,
    },
    Project {
        path: "/home/tcrha/qbe",
        project_type: ProjectType::Nested,
    },
];

fn get_active_sessions() -> HashSet<String> {
    let output = Command::new("tmux")
        .args(["list-sessions", "-F", "#{session_name}"])
        .output();

    match output {
        Ok(out) if out.status.success() => {
            String::from_utf8_lossy(&out.stdout)
                .lines()
                .filter(|s| !s.is_empty())
                .map(String::from)
                .collect()
        }
        _ => HashSet::new(),
    }
}

fn is_tmux_running() -> bool {
    Command::new("pgrep")
        .arg("tmux")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn tmux_session_exists(name: &str) -> bool {
    Command::new("tmux")
        .args(["has-session", &format!("-t={}", name)])
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn run_fzf(items: &[String]) -> Option<String> {
    let mut child = Command::new("fzf")
        .args(["--layout=reverse", "--tmux", "center", "--ansi"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit())
        .spawn()
        .ok()?;

    if let Some(mut stdin) = child.stdin.take() {
        let _ = stdin.write_all(items.join("\n").as_bytes());
    }

    let output = child.wait_with_output().ok()?;

    if output.status.success() {
        let selected = String::from_utf8_lossy(&output.stdout).trim().to_string();
        if selected.is_empty() {
            None
        } else {
            Some(selected)
        }
    } else {
        None
    }
}

fn basename(path: &str) -> &str {
    path.rsplit('/').next().unwrap_or(path)
}

fn main() {
    println!("tmux-sessionizer rust");

    let active_sessions = get_active_sessions();

    let mut folders: HashMap<String, FolderInfo> = HashMap::new();

    for project in PROJECTS {
        match project.project_type {
            ProjectType::Single => {
                let name = basename(project.path).to_string();
                let session_name = name.replace('.', "_");
                folders.insert(
                    name,
                    FolderInfo {
                        path: project.path.to_string(),
                        is_open: active_sessions.contains(&session_name),
                    },
                );
            }
            ProjectType::Nested => {
                if let Ok(entries) = fs::read_dir(project.path) {
                    for entry in entries.flatten() {
                        if let Ok(file_type) = entry.file_type() {
                            if file_type.is_dir() {
                                let name = entry.file_name().to_string_lossy().to_string();
                                let session_name = name.replace('.', "_");
                                folders.insert(
                                    name,
                                    FolderInfo {
                                        path: entry.path().to_string_lossy().to_string(),
                                        is_open: active_sessions.contains(&session_name),
                                    },
                                );
                            }
                        }
                    }
                }
            }
        }
    }

    if folders.is_empty() {
        eprintln!("No folders found");
        std::process::exit(1);
    }

    // Separate and sort open/closed sessions
    let mut open_names: Vec<&String> = folders
        .iter()
        .filter(|(_, info)| info.is_open)
        .map(|(name, _)| name)
        .collect();
    let mut closed_names: Vec<&String> = folders
        .iter()
        .filter(|(_, info)| !info.is_open)
        .map(|(name, _)| name)
        .collect();

    open_names.sort();
    closed_names.sort();

    // Build fzf input with prefixes
    let mut names: Vec<String> = Vec::new();
    for name in &open_names {
        names.push(format!("🟢 {}", name));
    }
    for name in &closed_names {
        names.push(format!("   {}", name));
    }

    let selected = match run_fzf(&names) {
        Some(s) => s,
        None => std::process::exit(0),
    };

    // Strip the prefix
    let selected = selected
        .strip_prefix("🟢 ")
        .or_else(|| selected.strip_prefix("   "))
        .unwrap_or(&selected);

    let folder_info = match folders.get(selected) {
        Some(info) => info,
        None => {
            eprintln!("Folder not found");
            std::process::exit(1);
        }
    };

    let selected_path = &folder_info.path;
    let selected_name = basename(selected).replace('.', "_");

    let in_tmux = env::var("TMUX").map(|v| !v.is_empty()).unwrap_or(false);
    let tmux_running = is_tmux_running();

    if !in_tmux && !tmux_running {
        // Start new tmux session and attach with nvim
        Command::new("tmux")
            .args(["new-session", "-s", &selected_name, "-c", selected_path, "nvim"])
            .status()
            .ok();
        std::process::exit(0);
    }

    // Check if session exists
    if !tmux_session_exists(&selected_name) {
        // Create detached session with nvim
        Command::new("tmux")
            .args(["new-session", "-ds", &selected_name, "-c", selected_path, "nvim"])
            .status()
            .ok();
    }

    if !in_tmux {
        // Attach to session
        Command::new("tmux")
            .args(["attach", "-t", &selected_name])
            .status()
            .ok();
    } else {
        // Switch client to session
        Command::new("tmux")
            .args(["switch-client", "-t", &selected_name])
            .status()
            .ok();
    }
}

