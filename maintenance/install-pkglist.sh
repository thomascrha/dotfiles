#!/bin/bash

# Pacman can run pre- and post-transaction hooks from the /usr/share/libalpm/hooks/ directory; more directories can be
# specified with the HookDir option in pacman.conf, which defaults to /etc/pacman.d/hooks. Hook file names must be
# suffixed with .hook. Pacman hooks are not interactive.

# Pacman hooks are used, for example, in combination with systemd-sysusers and systemd-tmpfiles to automatically create
# system users and files during the installation of packages. For example, tomcat8 specifies that it wants a system user
# called tomcat8 and certain directories owned by this user. The pacman hooks systemd-sysusers.hook and
# systemd-tmpfiles.hook invoke systemd-sysusers and systemd-tmpfiles when pacman determines that tomcat8 contains files
# specifying users and tmp files.

# For more information on alpm hooks, see alpm-hooks(5).

sudo install ./pkglist.hook /usr/share/libalpm/hooks/
