#!/bin/bash

# Set strict mode
set -euo pipefail

# trap the ctrl+c signal
trap "echo" INT

# ignore the case
shopt -s nocasematch

# date format used by nwipe & shredos in all logs
date_format="+%Y/%m/%d %H:%M:%S"

# Initialize variables
previous_sha1=""
loop_count=0
exclude_boot_disc=0
exclude_drives=0
transfer_status="SUCCESS"
launcher_options=""
tftp_errors="ERROR\|Transfer Timed out\|Network is unreachable"

# Wait for USB devices to initialize
loop_count_total=30
loop_count_check=5
printf "\n"

while (( loop_count_total > 0 )); do
    sha1=$(dmesg | grep -i USB | sha1sum)
    if [[ "$previous_sha1" == "$sha1" ]]; then
        break
    fi
    previous_sha1=$sha1
    while (( loop_count_check > 0 )); do
        printf "Waiting for all USB devices to be initialized, timeout $loop_count_total \r"
        ((loop_count_total--))
        ((loop_count_check--))
        sleep 1
    done
    loop_count_check=5
done
printf "\n"

echo "[`date "$date_format"`] Transfer log" > transfer.log
echo "[`date "$date_format"`] wget log" > wget.log

# Create necessary directories
mkdir -p /imported
mkdir -p /etc/nwipe
mkdir -p /exported

printf "[`date "$date_format"`] Created necessary directories\n" 2>&1 | tee -a transfer.log

# Function definitions (if any external scripts are missing, define them here or adjust the paths)
# Since we are using systemd, ensure that all paths and dependencies are correctly set

# Placeholder function for kernel_cmdline_extractor
kernel_cmdline_extractor() {
    # Extract value from /proc/cmdline
    local key=$1
    local value=$(cat /proc/cmdline | tr ' ' '\n' | grep "^$key=" | cut -d'=' -f2-)
    if [ -n "$value" ]; then
        echo "$value"
        return 0
    else
        return 1
    fi
}

# Continue with the rest of your script...

# Initialize variables
country_code=""
nwipe_options_string=""
lftp_command_line=""
http_post_url=""
autopoweroff=0
logfile="nwipe_log_$(date +%Y%m%d-%H%M%S).txt"

# Load keyboard layout if specified
country_code=$(kernel_cmdline_extractor loadkeys || true)
if [ -n "$country_code" ]; then
    loadkeys $country_code
fi

# Read nwipe options from kernel command line
nwipe_options_string=$(kernel_cmdline_extractor nwipe_options || true)
if [ -n "$nwipe_options_string" ]; then
    nwipe_options_flag=1

    # Handle --autopoweroff option
    if [[ "$nwipe_options_string" == *"--autopoweroff"* ]]; then
        autopoweroff=1
        nwipe_options_string=${nwipe_options_string//--autopoweroff/--nowait}
    else
        autopoweroff=0
    fi

    # Handle shredos_autoreboot option
    autoreboot=$(kernel_cmdline_extractor shredos_autoreboot || true)
    if [[ "$autoreboot" == "enable" ]]; then
        if [[ "$nwipe_options_string" != *"--nowait"* ]]; then
            launcher_options+=" --nowait"
        fi
    else
        autoreboot=""
    fi
else
    nwipe_options_flag=0
fi

# Short pause before launching nwipe
sleep 2

# Run nwipe with a timestamped log file
while true; do
    if [ $nwipe_options_flag -eq 0 ]; then
        /usr/bin/nwipe --logfile="$logfile" $launcher_options
    else
        /usr/bin/nwipe --logfile="$logfile" $launcher_options $nwipe_options_string
    fi

    # Handle logging, transfers, and archiving here
    # Since this script is now running under systemd, ensure that any commands requiring TTY are handled correctly

    # Check for transfer status and handle auto-reboot or auto-poweroff
    if [ "$autoreboot" == "enable" ] && [ "$transfer_status" == "SUCCESS" ]; then
        systemctl reboot
        sleep 30
    elif [ $autopoweroff -eq 1 ] && [ "$transfer_status" == "SUCCESS" ]; then
        systemctl poweroff
        sleep 30
    else
        # Present options to the user
        while true; do
            printf "\nPaused... Press r to reboot, s to shutdown, n to restart nwipe.\n"
            read -rsn1 input
            case $input in
                r|R)
                    printf "Rebooting...\n"
                    systemctl reboot
                    sleep 10
                    ;;
                s|S)
                    printf "Shutting down...\n"
                    systemctl poweroff
                    sleep 10
                    ;;
                n|N)
                    printf "Restarting nwipe...\n"
                    break
                    ;;
                *)
                    printf "Unknown command.\n"
                    ;;
            esac
        done
    fi
done
