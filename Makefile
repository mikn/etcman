# Makefile for managing a bare git repository to track /etc changes and selective package management

# Variables
GIT_DIR := /root/sysconf/git
WORK_TREE := /etc
COMMAND_NAME := etcman
COMMAND_PATH := /usr/local/sbin/$(COMMAND_NAME)
PACKAGE_LIST := $(WORK_TREE)/etcman/package-list.conf
COMPLETION_DIR := /etc/bash_completion.d

DEBUG ?= 0

define ETCMAN_SCRIPT
#!/bin/sh
git --git-dir=$(GIT_DIR) --work-tree=$(WORK_TREE) "$$@"
endef

define COMPLETION_SCRIPT
_etcman() {
    . /usr/share/bash-completion/completions/git
    _git
}
complete -o default -o nospace -F _etcman $(COMMAND_NAME)
endef

define UPDATE_PACKAGE_LIST_SCRIPT
#!/bin/bash
DEBUG=${DEBUG}
log() {
    logger -t update-package-list -p user.info "$$@"
}

log_debug() {
    [ "$$DEBUG" -eq 1 ] && logger -t update-package-list -p user.debug "$$@"
}

log "Script started at $$(date)"
log_debug "PACKAGE_LIST is set to: $(PACKAGE_LIST)"
log_debug "Received arguments: $$@"

action=$$1
shift

log "Updating list for action: $$action"
log_debug "Packages to process: $$@"

# Ensure the package list file exists and has the correct sections
if [ ! -f "$(PACKAGE_LIST)" ]; then
    echo "[installed]" > "$(PACKAGE_LIST)"
    echo "[removed]" >> "$(PACKAGE_LIST)"
fi

for pkg in "$$@"; do
    log_debug "Processing package: $$pkg"
    if [ "$$action" = "install" ]; then
        log_debug "Removing any 'removed' entry for $$pkg"
        sed -i '/^\[removed\]/,/^\[/ { /^'"$$pkg"'$$/d }' "$(PACKAGE_LIST)"
        log_debug "Checking if 'installed' entry exists for $$pkg"
        if ! grep -q "^$$pkg$$" "$(PACKAGE_LIST)"; then
            log "Adding 'installed' entry for $$pkg"
            sed -i '/^\[installed\]/a '"$$pkg" "$(PACKAGE_LIST)"
        fi
    elif [ "$$action" = "remove" ]; then
        log_debug "Removing any 'installed' entry for $$pkg"
        sed -i '/^\[installed\]/,/^\[/ { /^'"$$pkg"'$$/d }' "$(PACKAGE_LIST)"
        log_debug "Checking if 'removed' entry exists for $$pkg"
        if ! grep -q "^$$pkg$$" "$(PACKAGE_LIST)"; then
            log "Adding 'removed' entry for $$pkg"
            sed -i '/^\[removed\]/a '"$$pkg" "$(PACKAGE_LIST)"
        fi
    else
        logger -t update-package-list -p user.error "Invalid action: $$action"
    fi
done

log_debug "Sorting entries in $(PACKAGE_LIST)"
ex -sc 'g/^\[/;/^\[/-sort' -cx $(PACKAGE_LIST)

log "Package list updated. Remember to commit changes manually."
log "Script finished at $$(date)"
endef

define APT_HOOK
DPkg::Pre-Install-Pkgs {
    "/usr/local/bin/apt-hook-wrapper";
};
DPkg::Tools::Options::/usr/local/bin/apt-hook-wrapper::Version "3";
DPkg::Tools::Options::/usr/local/bin/apt-hook-wrapper::InfoFD "3";
endef

define APT_HOOK_WRAPPER
#!/bin/bash
DEBUG=${DEBUG}
log() {
    logger -t apt-hook-wrapper -p user.info "$$@"
}

log_debug() {
    [ "$$DEBUG" -eq 1 ] && logger -t apt-hook-wrapper -p user.debug "$$@"
}

log "APT Hook Wrapper started at $$(date)"

# Function to URL decode
urldecode() {
    local url_encoded="$${1//+/ }"
    printf '%b' "$${url_encoded//%/\\x}"
}

# Read the VERSION line
read -r version_line <&3
log "Version: $$version_line"

if [[ "$$version_line" != "VERSION 3" ]]; then
    logger -t apt-hook-wrapper -p user.error "Unexpected version: $$version_line"
    exit 1
fi

# Read and log configuration
log "Configuration:"
command_line=""
while IFS= read -r config_line <&3; do
    [ -z "$$config_line" ] && break
    log_debug "  $$config_line"
    if [[ "$$config_line" == CommandLine::AsString=* ]]; then
        log_debug "CommandLine detected with contents: $$config_line"
        encoded_command="$${config_line#CommandLine::AsString=}"
        command_line="$$(urldecode "$$encoded_command")"
        log_debug "CommandLine decoded: $$command_line"
    fi
done

# Process command line
tool="$${command_line%% *}"  # Extract the first word (apt, apt-get, aptitude)
command="$${command_line#* }" # Remove the first word
command="$${command%% *}"  # Extract the second word (install, remove, purge)

case "$$command" in
    install) action="install";;
    remove) action="remove";;
    purge) action="remove";;   # Map purge to remove
    *) 
        log "Not a manual install/remove/purge operation: $$command_line"
        exit 0
        ;;
esac
# Extract package names from command_line
packages=()                       # Initialize empty array
read -ra temp_arr <<< "$$command_line"  
for ((i=2; i<$${#temp_arr[@]}; i++)); do  # Start from index 2 (packages)
    packages+=("$${temp_arr[i]}")
done

log "Manual operation detected: $$command_line"
log "Action: $$action"
log "Packages: $${packages[*]}"

# Create an associative array to track manually specified packages
declare -A manual_packages
for pkg in "$${packages[@]}"; do
    manual_packages["$$pkg"]=1
done

# Process package actions
log "Package actions:"
while IFS= read -r action_line <&3; do
    log_debug "  $$action_line"
    read -r pkg old_ver old_arch old_multi direction new_ver new_arch new_multi pkg_action <<< "$$action_line"
    
    if [[ -n "$${manual_packages[$$pkg]}" ]]; then
        if [[ "$$action" == "install" && "$$pkg_action" != "**REMOVE**" && "$$new_ver" != "-" ]]; then
            log "Manually installing: $$pkg ($$new_ver)"
            /usr/local/bin/update-package-list install "$$pkg"
        elif [[ "$$action" == "remove" && "$$pkg_action" == "**REMOVE**" ]]; then
            log "Manually removing: $$pkg"
            /usr/local/bin/update-package-list remove "$$pkg"
        fi
    else
        log_debug "Skipping non-manually specified package: $$pkg"
    fi
done

log "APT Hook Wrapper finished at $$(date)"
endef

# Install the git repository and set up the command
.PHONY: install
install:
	@if [ -z "$(REMOTE_URL)" ]; then \
		echo "Setting up new bare git repository..."; \
		mkdir -p $(GIT_DIR); \
		git init --bare $(GIT_DIR); \
	else \
		echo "Cloning remote repository..."; \
		git clone --bare $(REMOTE_URL) $(GIT_DIR); \
	fi
	@echo "Configuring git..."
	git --git-dir=$(GIT_DIR) --work-tree=$(WORK_TREE) config --local status.showUntrackedFiles no
	@echo "Creating $(COMMAND_NAME) script..."
	$(file > $(COMMAND_PATH),$(ETCMAN_SCRIPT))
	chmod +x $(COMMAND_PATH)
	@echo "Setting up command completion..."
	$(file > $(COMPLETION_DIR)/$(COMMAND_NAME),$(COMPLETION_SCRIPT))
	@if [ -n "$(REMOTE_URL)" ]; then \
		echo "Checking out files from remote repository..."; \
		$(COMMAND_PATH) checkout -f; \
	fi
	@if [ ! -f $(PACKAGE_LIST) ]; then \
		@echo "Creating initial package list..." \
		mkdir -p $$(dirname $(PACKAGE_LIST)); \
		echo "[installed]" > $(PACKAGE_LIST); \
		echo "[removed]" >> $(PACKAGE_LIST); \
	fi
	@echo "Setting up APT hooks..."
	mkdir -p /etc/apt/apt.conf.d
	$(file > /etc/apt/apt.conf.d/80update-package-list,$(APT_HOOK))
	$(file > /usr/local/bin/apt-hook-wrapper,$(APT_HOOK_WRAPPER))
	chmod +x /usr/local/bin/apt-hook-wrapper
	$(file > /usr/local/bin/update-package-list,$(UPDATE_PACKAGE_LIST_SCRIPT))
	chmod +x /usr/local/bin/update-package-list
	@echo "Installation complete."

# Uninstall the git repository and restore original files
.PHONY: uninstall
uninstall:
	@echo "Removing changed files..."
	$(COMMAND_PATH) diff --name-only | xargs -I {} rm -f {}
	@echo "Restoring original files..."
	$(COMMAND_PATH) diff --name-only | xargs -I {} sh -c 'dpkg -S {} | cut -d: -f1 | xargs -I % dpkg -i --force-confmiss %'
	@echo "Removing git repository..."
	rm -rf $(GIT_DIR)
	@echo "Removing $(COMMAND_NAME) script and completion..."
	rm -f $(COMMAND_PATH) $(COMPLETION_DIR)/$(COMMAND_NAME)
	@echo "Removing APT hooks..."
	rm -f /etc/apt/apt.conf.d/80update-package-list /usr/local/bin/update-package-list
	@echo "Uninstallation complete."

# Restore from a remote repository
.PHONY: restore
restore:
	@if [ -z "$(REMOTE_URL)" ]; then \
		echo "Error: REMOTE_URL is not set. Please provide the remote repository URL."; \
		echo "Usage: make restore REMOTE_URL=<repository_url>"; \
		exit 1; \
	fi
	@echo "Cloning remote repository..."
	git clone --bare $(REMOTE_URL) $(GIT_DIR)
	@echo "Checking out files to /etc..."
	$(COMMAND_PATH) checkout -f
	@echo "Restore complete. Please review the changes in /etc."
	@echo "You may need to restart services or reboot for all changes to take effect."
	@echo "To sync installed packages with the restored list, run: make sync-packages"

# Sync installed packages with the package list
.PHONY: sync-packages
sync-packages:
	@echo "Packages to be installed:"
	@sed -n '/^\[installed\]/,/^\[/p' $(PACKAGE_LIST) | sed '1d;$$d'
	@echo "\nPackages to be removed:"
	@sed -n '/^\[removed\]/,$$p' $(PACKAGE_LIST) | sed '1d'
	@echo "\nDo you want to proceed with these changes? [y/N]"
	@read -r response; \
	if [ "$$response" = "y" ] || [ "$$response" = "Y" ]; then \
		echo "Updating package list..."; \
		apt update; \
		echo "Installing packages..."; \
		sed -n '/^\[installed\]/,/^\[/p' $(PACKAGE_LIST) | sed '1d;$$d' | xargs -r apt install -y; \
		echo "Removing packages..."; \
		sed -n '/^\[removed\]/,$$p' $(PACKAGE_LIST) | sed '1d' | xargs -r apt remove -y; \
		echo "Package sync complete. You may want to run 'apt autoremove' to remove unnecessary dependencies."; \
		/usr/local/bin/update-package-list; \
	else \
		echo "Operation cancelled."; \
	fi

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  install [REMOTE_URL=<url>] - Set up the git repository and command, optionally from a remote repository"
	@echo "  uninstall                  - Remove the git repository and restore original files"
	@echo "  restore REMOTE_URL=<url>   - Restore /etc from a remote git repository"
	@echo "  sync-packages              - Sync installed packages with the package list"
	@echo "  help                       - Show this help message"
