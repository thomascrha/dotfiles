#!/bin/bash

SYSTEMD_UNITS_PATH="${HOME}/dotfiles/.config/systemd/user"

check_services() {
    echo "Checking services..."
    for service in $(find $SYSTEMD_UNITS_PATH -maxdepth 1 -name '*.service'); do
        service_name=$(basename "$service" .service)
        is_active=$(systemctl --user is-active "$service_name")
        is_enabled=$(systemctl --user is-enabled "$service_name")
        is_failed=$(systemctl --user is-failed "$service_name")
        printf "%-30s Active=%-10s Enabled=%-10s Failed=%-10s\n" "$service_name:" "$is_active" "$is_enabled" "$is_failed"
    done
}

disable_services() {
    echo "Disabling all services..."
    for service in $(find $SYSTEMD_UNITS_PATH -maxdepth 1 -name '*.service'); do
        service_name=$(basename "$service" .service)
        echo "Disabling $service_name..."
        systemctl --user disable --now "$service_name"
        status=$(systemctl --user is-active "$service_name")
    done
}

enable_services() {
    echo "Enabling all services..."
    for service in $(find $SYSTEMD_UNITS_PATH -maxdepth 1 -name '*.service'); do
        service_name=$(basename "$service" .service)
        echo "Enabling $service_name..."
        systemctl --user enable --now "$service_name"
        status=$(systemctl --user is-active "$service_name")
    done
}

show_usage() {
    echo "Usage: $0 [check|disable|enable]"
    echo "Options:"
    echo "  check   - Check service status and enable inactive ones"
    echo "  disable - Disable all services"
    echo "  enable  - Enable all services"
    exit 1
}

operation=${1:-help}
operation=$(echo "$operation" | tr '[:upper:]' '[:lower:]')
case "$operation" in
    "check")
        check_services
        ;;
    "disable")
        disable_services
        ;;
    "enable")
        enable_services
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        echo "Invalid option: $operation"
        show_usage
        ;;
esac
