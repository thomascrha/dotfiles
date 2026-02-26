#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_FOLDERS 256
#define MAX_PATH 2048
#define MAX_NAME 256

typedef enum { NESTED, SINGLE } ProjectType;

typedef struct {
  char path[MAX_PATH];
  ProjectType type;
} Project;

typedef struct {
  char name[MAX_NAME];
  char path[MAX_PATH];
  int is_open;
} FolderInfo;

Project projects[] = {
    {"/home/tcrha/dotfiles", SINGLE},
    {"/home/tcrha/qbe", NESTED},
};
int num_projects = sizeof(projects) / sizeof(projects[0]);

FolderInfo folders[MAX_FOLDERS];
int num_folders = 0;

char active_sessions[MAX_FOLDERS][MAX_NAME];
int num_sessions = 0;

char *basename_path(const char *path) {
  char *last_slash = strrchr(path, '/');
  return last_slash ? last_slash + 1 : (char *)path;
}

void replace_dots(char *str) {
  for (int i = 0; str[i]; i++) {
    if (str[i] == '.')
      str[i] = '_';
  }
}

int session_is_active(const char *name) {
  char session_name[MAX_NAME];
  strncpy(session_name, name, MAX_NAME - 1);
  session_name[MAX_NAME - 1] = '\0';
  replace_dots(session_name);

  for (int i = 0; i < num_sessions; i++) {
    if (strcmp(active_sessions[i], session_name) == 0) {
      return 1;
    }
  }
  return 0;
}

void get_active_sessions() {
  FILE *fp = popen("tmux list-sessions -F '#{session_name}' 2>/dev/null", "r");
  if (!fp)
    return;

  char line[MAX_NAME];
  while (fgets(line, sizeof(line), fp) && num_sessions < MAX_FOLDERS) {
    line[strcspn(line, "\n")] = '\0';
    if (strlen(line) > 0) {
      strncpy(active_sessions[num_sessions++], line, MAX_NAME - 1);
    }
  }
  pclose(fp);
}

int is_tmux_running() { return system("pgrep tmux >/dev/null 2>&1") == 0; }

int tmux_session_exists(const char *name) {
  char cmd[MAX_PATH];
  snprintf(cmd, sizeof(cmd), "tmux has-session -t=%s 2>/dev/null", name);
  return system(cmd) == 0;
}

int compare_folders(const void *a, const void *b) {
  return strcmp(((FolderInfo *)a)->name, ((FolderInfo *)b)->name);
}

char *run_fzf(char **items, int count) {
  static char result[MAX_NAME];

  // Clear the result buffer
  memset(result, 0, sizeof(result));

  // Create temp file for fzf input
  FILE *tmp = fopen("/tmp/fzf_input_c", "w");
  if (!tmp)
    return NULL;

  for (int i = 0; i < count; i++) {
    fprintf(tmp, "%s\n", items[i]);
  }
  fflush(tmp);
  fclose(tmp);

  // Run fzf with the temp file
  FILE *fzf = popen(
      "cat /tmp/fzf_input_c | fzf --layout=reverse --tmux center --ansi", "r");
  if (!fzf) {
    unlink("/tmp/fzf_input_c");
    return NULL;
  }

  if (fgets(result, sizeof(result), fzf)) {
    result[strcspn(result, "\n")] = '\0';
    pclose(fzf);
    unlink("/tmp/fzf_input_c");
    return result;
  }

  pclose(fzf);
  unlink("/tmp/fzf_input_c");
  return NULL;
}

void add_folder(const char *name, const char *path) {
  if (num_folders >= MAX_FOLDERS)
    return;

  strncpy(folders[num_folders].name, name, MAX_NAME - 1);
  strncpy(folders[num_folders].path, path, MAX_PATH - 1);
  folders[num_folders].is_open = session_is_active(name);
  num_folders++;
}

int main() {
  printf("tmux-sessionizer c\n");

  get_active_sessions();

  // Build folders list
  for (int i = 0; i < num_projects; i++) {
    if (projects[i].type == SINGLE) {
      add_folder(basename_path(projects[i].path), projects[i].path);
    } else {
      DIR *dir = opendir(projects[i].path);
      if (!dir)
        continue;

      struct dirent *entry;
      while ((entry = readdir(dir)) != NULL) {
        if (entry->d_name[0] == '.')
          continue;

        char full_path[MAX_PATH];
        int path_len = snprintf(full_path, sizeof(full_path), "%s/%s",
                                projects[i].path, entry->d_name);
        if (path_len >= MAX_PATH)
          continue; // Skip if path is too long

        struct stat st;
        if (stat(full_path, &st) == 0 && S_ISDIR(st.st_mode)) {
          add_folder(entry->d_name, full_path);
        }
      }
      closedir(dir);
    }
  }

  if (num_folders == 0) {
    fprintf(stderr, "No folders found\n");
    return 1;
  }

  // Separate open and closed, then sort each group
  FolderInfo open_folders[MAX_FOLDERS];
  FolderInfo closed_folders[MAX_FOLDERS];
  int num_open = 0, num_closed = 0;

  for (int i = 0; i < num_folders; i++) {
    if (folders[i].is_open) {
      open_folders[num_open++] = folders[i];
    } else {
      closed_folders[num_closed++] = folders[i];
    }
  }

  qsort(open_folders, num_open, sizeof(FolderInfo), compare_folders);
  qsort(closed_folders, num_closed, sizeof(FolderInfo), compare_folders);

  // Build fzf input
  char *names[MAX_FOLDERS];
  int total = 0;

  for (int i = 0; i < num_open; i++) {
    names[total] = malloc(MAX_NAME + 16);
    snprintf(names[total], MAX_NAME + 16, "🟢 %s", open_folders[i].name);
    total++;
  }
  for (int i = 0; i < num_closed; i++) {
    names[total] = malloc(MAX_NAME + 16);
    snprintf(names[total], MAX_NAME + 16, "   %s", closed_folders[i].name);
    total++;
  }

  char *selected = run_fzf(names, total);

  // Free allocated memory
  for (int i = 0; i < total; i++)
    free(names[i]);

  if (!selected || strlen(selected) == 0)
    return 0;

  // Strip prefix - 🟢 is 4 bytes in UTF-8, plus space = 5 bytes
  char *name = selected;
  if (strncmp(name, "🟢 ", 5) == 0)
    name += 5;
  else if (strncmp(name, "   ", 3) == 0)
    name += 3;

  // Find the folder
  char *selected_path = NULL;
  for (int i = 0; i < num_open; i++) {
    if (strcmp(open_folders[i].name, name) == 0) {
      selected_path = open_folders[i].path;
      break;
    }
  }
  if (!selected_path) {
    for (int i = 0; i < num_closed; i++) {
      if (strcmp(closed_folders[i].name, name) == 0) {
        selected_path = closed_folders[i].path;
        break;
      }
    }
  }

  if (!selected_path) {
    fprintf(stderr, "Folder not found\n");
    return 1;
  }

  char selected_name[MAX_NAME];
  memset(selected_name, 0, sizeof(selected_name));
  strncpy(selected_name, name, MAX_NAME - 1);
  selected_name[MAX_NAME - 1] = '\0';
  replace_dots(selected_name);

  char *tmux_env = getenv("TMUX");
  int in_tmux = tmux_env && strlen(tmux_env) > 0;
  int tmux_running = is_tmux_running();

  char cmd[MAX_PATH * 2];

  if (!in_tmux && !tmux_running) {
    snprintf(cmd, sizeof(cmd), "tmux new-session -s %s -c '%s'", selected_name,
             selected_path);
    system(cmd);
    return 0;
  }

  if (!tmux_session_exists(selected_name)) {
    snprintf(cmd, sizeof(cmd), "tmux new-session -ds %s -c '%s'", selected_name,
             selected_path);
    system(cmd);
  }

  if (!in_tmux) {
    snprintf(cmd, sizeof(cmd), "tmux attach -t %s", selected_name);
    system(cmd);
  } else {
    execlp("tmux", "tmux", "switch-client", "-t", selected_name, NULL);
  }

  return 0;
}
