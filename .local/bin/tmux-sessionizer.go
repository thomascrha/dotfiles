package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
)

type ProjectType string

const (
	Nested ProjectType = "nested"
	Single ProjectType = "single"
)

type Project struct {
	Path string
	Type ProjectType
}

var projects = []Project{
	{Path: "/home/tcrha/dotfiles", Type: Single},
	{Path: "/home/tcrha/Projects", Type: Nested},
	{Path: "/home/tcrha/qbe", Type: Nested},
}

type FolderInfo struct {
	Path   string
	IsOpen bool
}

func main() {
	activeSessions := getActiveTmuxSessions()

	folders := make(map[string]FolderInfo)

	for _, project := range projects {
		if project.Type == Single {
			name := filepath.Base(project.Path)
			sessionName := strings.ReplaceAll(name, ".", "_")
			folders[name] = FolderInfo{
				Path:   project.Path,
				IsOpen: activeSessions[sessionName],
			}
		} else {
			entries, err := os.ReadDir(project.Path)
			if err != nil {
				continue
			}
			for _, entry := range entries {
				if entry.IsDir() {
					fullPath := filepath.Join(project.Path, entry.Name())
					sessionName := strings.ReplaceAll(entry.Name(), ".", "_")
					folders[entry.Name()] = FolderInfo{
						Path:   fullPath,
						IsOpen: activeSessions[sessionName],
					}
				}
			}
		}
	}

	if len(folders) == 0 {
		os.Exit(1)
	}

	var openNames []string
	var closedNames []string
	for name, info := range folders {
		if info.IsOpen {
			openNames = append(openNames, name)
		} else {
			closedNames = append(closedNames, name)
		}
	}

	sort.Strings(openNames)
	sort.Strings(closedNames)

	// Add prefixes after sorting
	var names []string
	for _, name := range openNames {
		names = append(names, "🟢 "+name)
	}
	for _, name := range closedNames {
		names = append(names, "   "+name)
	}

	selected, err := runFzf(names)
	if err != nil {
		os.Exit(1)
	}

	if selected == "" {
		os.Exit(0)
	}

	// Strip the prefix (green circle or spaces) from the selection
	selected = strings.TrimPrefix(selected, "🟢 ")
	selected = strings.TrimPrefix(selected, "   ")

	selectedPath := folders[selected].Path
	selectedName := strings.ReplaceAll(filepath.Base(selected), ".", "_")

	inTmux := os.Getenv("TMUX") != ""
	tmuxRunning := isTmuxRunning()

	if !inTmux && !tmuxRunning {
		// Start new tmux session and attach
		cmd := exec.Command("tmux", "new-session", "-s", selectedName, "-c", selectedPath)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Run()
		os.Exit(0)
	}

	// Check if session exists
	if !tmuxSessionExists(selectedName) {
		// Create detached session
		cmd := exec.Command("tmux", "new-session", "-ds", selectedName, "-c", selectedPath)
		cmd.Run()
	}

	if !inTmux {
		// Attach to session
		cmd := exec.Command("tmux", "attach", "-t", selectedName)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Run()
	} else {
		// Switch client to session
		cmd := exec.Command("tmux", "switch-client", "-t", selectedName)
		cmd.Run()
	}
}

func runFzf(items []string) (string, error) {
	cmd := exec.Command("fzf", "--layout=reverse", "--tmux", "center", "--ansi")
	cmd.Stdin = strings.NewReader(strings.Join(items, "\n"))
	cmd.Stderr = os.Stderr

	output, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			// fzf returns exit code 130 when user cancels with Ctrl-C
			if exitErr.ExitCode() == 130 || exitErr.ExitCode() == 1 {
				return "", nil
			}
		}
		return "", err
	}

	return strings.TrimSpace(string(output)), nil
}

func isTmuxRunning() bool {
	cmd := exec.Command("pgrep", "tmux")
	err := cmd.Run()
	return err == nil
}

func tmuxSessionExists(name string) bool {
	cmd := exec.Command("tmux", "has-session", "-t="+name)
	err := cmd.Run()
	return err == nil
}

func getActiveTmuxSessions() map[string]bool {
	sessions := make(map[string]bool)

	cmd := exec.Command("tmux", "list-sessions", "-F", "#{session_name}")
	output, err := cmd.Output()
	if err != nil {
		// tmux might not be running, return empty map
		return sessions
	}

	for _, name := range strings.Split(strings.TrimSpace(string(output)), "\n") {
		if name != "" {
			sessions[name] = true
		}
	}

	return sessions
}
