#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

enum class ProjectType { Nested, Single };

struct Project {
    std::string path;
    ProjectType type;
};

struct FolderInfo {
    std::string path;
    bool is_open;
};

const std::vector<Project> projects = {
    { "/home/tcrha/dotfiles", ProjectType::Single },
    { "/home/tcrha/qbe", ProjectType::Nested },
};

std::string basename_path(const std::string& path) {
    size_t pos = path.rfind('/');
    return pos != std::string::npos ? path.substr(pos + 1) : path;
}

std::string replace_dots(std::string str) {
    std::replace(str.begin(), str.end(), '.', '_');
    return str;
}

std::set<std::string> get_active_sessions() {
    std::set<std::string> sessions;
    FILE* fp = popen("tmux list-sessions -F '#{session_name}' 2>/dev/null", "r");
    if (!fp) return sessions;

    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        line[strcspn(line, "\n")] = '\0';
        if (strlen(line) > 0) {
            sessions.insert(line);
        }
    }
    pclose(fp);
    return sessions;
}

bool is_tmux_running() {
    return system("pgrep tmux >/dev/null 2>&1") == 0;
}

bool tmux_session_exists(const std::string& name) {
    std::string cmd = "tmux has-session -t=" + name + " 2>/dev/null";
    return system(cmd.c_str()) == 0;
}

std::string run_fzf(const std::vector<std::string>& items) {
    FILE* tmp = fopen("/tmp/fzf_input_cpp", "w");
    if (!tmp) return "";

    for (const auto& item : items) {
        fprintf(tmp, "%s\n", item.c_str());
    }
    fclose(tmp);

    FILE* fzf = popen("cat /tmp/fzf_input_cpp | fzf --layout=reverse --tmux center --ansi", "r");
    if (!fzf) {
        unlink("/tmp/fzf_input_cpp");
        return "";
    }

    char result[256];
    std::string selected;
    if (fgets(result, sizeof(result), fzf)) {
        result[strcspn(result, "\n")] = '\0';
        selected = result;
    }

    pclose(fzf);
    unlink("/tmp/fzf_input_cpp");
    return selected;
}

std::vector<std::string> read_directory(const std::string& path) {
    std::vector<std::string> dirs;
    DIR* dir = opendir(path.c_str());
    if (!dir) return dirs;

    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        if (entry->d_name[0] == '.') continue;

        std::string full_path = path + "/" + entry->d_name;
        struct stat st;
        if (stat(full_path.c_str(), &st) == 0 && S_ISDIR(st.st_mode)) {
            dirs.push_back(entry->d_name);
        }
    }
    closedir(dir);
    return dirs;
}

int main() {
    std::cout << "tmux-sessionizer c++" << std::endl;

    auto active_sessions = get_active_sessions();
    std::map<std::string, FolderInfo> folders;

    for (const auto& project : projects) {
        if (project.type == ProjectType::Single) {
            std::string name = basename_path(project.path);
            std::string session_name = replace_dots(name);
            folders[name] = {
                project.path,
                active_sessions.count(session_name) > 0
            };
        } else {
            for (const auto& entry : read_directory(project.path)) {
                std::string full_path = project.path + "/" + entry;
                std::string session_name = replace_dots(entry);
                folders[entry] = {
                    full_path,
                    active_sessions.count(session_name) > 0
                };
            }
        }
    }

    if (folders.empty()) {
        std::cerr << "No folders found" << std::endl;
        return 1;
    }

    // Separate and sort open/closed sessions
    std::vector<std::string> open_names, closed_names;
    for (const auto& [name, info] : folders) {
        if (info.is_open) {
            open_names.push_back(name);
        } else {
            closed_names.push_back(name);
        }
    }

    std::sort(open_names.begin(), open_names.end());
    std::sort(closed_names.begin(), closed_names.end());

    // Build fzf input with prefixes
    std::vector<std::string> names;
    for (const auto& name : open_names) {
        names.push_back("🟢 " + name);
    }
    for (const auto& name : closed_names) {
        names.push_back("   " + name);
    }

    std::string selected = run_fzf(names);
    if (selected.empty()) return 0;

    // Strip prefix - 🟢 is 4 bytes in UTF-8, plus space = 5 bytes
    if (selected.size() >= 5 && selected.substr(0, 5) == "🟢 ") {
        selected = selected.substr(5);
    } else if (selected.size() >= 3 && selected.substr(0, 3) == "   ") {
        selected = selected.substr(3);
    }

    auto it = folders.find(selected);
    if (it == folders.end()) {
        std::cerr << "Folder not found" << std::endl;
        return 1;
    }

    const std::string& selected_path = it->second.path;
    std::string selected_name = replace_dots(basename_path(selected));

    const char* tmux_env = std::getenv("TMUX");
    bool in_tmux = tmux_env && strlen(tmux_env) > 0;
    bool tmux_running = is_tmux_running();

    if (!in_tmux && !tmux_running) {
        std::string cmd = "tmux new-session -s " + selected_name + " -c '" + selected_path + "'";
        system(cmd.c_str());
        return 0;
    }

    if (!tmux_session_exists(selected_name)) {
        std::string cmd = "tmux new-session -ds " + selected_name + " -c '" + selected_path + "'";
        system(cmd.c_str());
    }

    if (!in_tmux) {
        std::string cmd = "tmux attach -t " + selected_name;
        system(cmd.c_str());
    } else {
        std::string cmd = "tmux switch-client -t " + selected_name;
        system(cmd.c_str());
    }

    return 0;
}

