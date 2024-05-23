#!/bin/bash

# client only
# no SSL support

VERSION="1.0"

help() {
printf 'Setup Barrier KVM Software via terminal.

Usage: %s [OPTIONS] [ARGUMENT]

Options:
-h, --help                                                        # Display this help message
-s, --setup [SCREEN_NAME] [IP_HOST] [PORT] (default: 24800)       # Configure barrier via terminal
-l, --list                                                        # Show current configuration
-v, --version                                                     # Show current version

Examples:
%s -h                                     # Display this help message
%s -s screen_left 192.168.1.14           # Configure barrier with given SCREEN_NAME and IP_HOST, using deafult port 
' $0 $0 $0
}

get_current_conf(){
# if barrier is already running, this function will retrieve the current configuration.
    # When 'ps ax | grep barrier' return 3 rows, it means the GUI process is running at the background
    # so process_output=$(ps ax | grep barrier | sed -n '2p') should be used to get the second row  
    # when configuring barrier from this script, the commanand above is not necessary

    local process_output=$(ps ax | grep barrierc | sed -n '1p')
    process_output=$(echo "$process_output" | awk '{$1=""; $2=""; $3=""; $4="";  sub(/^ * /, ""); print}')
    # uses awk 'sub' function to replace the first 4 columns of the $process_output output 
    echo $process_output
}

setup_barrierc_autostart(){
    # create entry on the default autostart directory - $HOME/.config/autostart
    
    local exec=$1
    local auto_start_dir="$HOME/.config/autostart"
    local desktop_entry_file="$auto_start_dir/barrier_autostart_fix.desktop"
    
    mkdir -p "$auto_start_dir"

printf '[Desktop Entry]
Type=Application
Name=barrier_autostart
Exec=%s
Terminal=false
Hidden=false
' "$exec" > "$desktop_entry_file"

    chmod +x "$desktop_entry_file"  
}

setup_barrierc(){ # configure barrier client 
    
    local screen_name=$1
    local ip_host=$2
    local port=$3
    local command="/usr/bin/barrierc -f --no-tray --debug INFO --name SCREEN_NAME --disable-crypto [IP_HOST]:PORT"    
    
    command="${command//SCREEN_NAME/$screen_name}"
    command="${command//IP_HOST/$ip_host}"

    if [ -z "$3" ]; then
        command="${command//PORT/24800}"
    else
        command="${command//PORT/$port}"
    fi

    echo $command
}

test_barrierc(){ # test client configuration, test will timeout in 10 seconds killing all the barrier related processes
   
    local test_process=$1
    local com="ps ax | grep barrierc | sed -n 'ROWCp' | awk '{printf \$1}'"
    local row=1
    
    echo "Testing configuration..."

    # Execute the test process for 10 seconds
    eval "$test_process" & sleep 10 

    # Get the number of active barrier processes 
    local row_count=$(ps ax | grep -c barrierc)
   
    while [ $row -le $row_count ]; do # Kill all barrier processes 
        current_com="${com//ROWC/$row}"
        pid=$(eval "$current_com")
        kill $pid > /dev/null 2>&1
        ((row++))
    done
}

run_process_background(){ 
    local background_process=$1
    nohup ${background_process} > /dev/null 2>&1 & # execute process in background
}

case $1 in
    "" )
        help
        exit
        ;;
    -h | --help )
        help
        exit
        ;;
    -s | --setup )
        
        readonly SETUP_COMMAND=$(setup_barrierc "$2" "$3" "$4")

        read -p "Test current configuration? [y/n]: " answ

        if [ "$answ" = "y" ] || [ "$answ" = "Y" ]; then
            test_barrierc "$SETUP_COMMAND"
        fi

        read -p "Use current configuration and enable autostart? [y/n]: " answ

        if [ "$answ" = "y" ] || [ "$answ" = "Y" ]; then
            setup_barrierc_autostart "$SETUP_COMMAND"
            run_process_background "$SETUP_COMMAND"
        fi
        exit
        ;;
    -v | --version )
        echo $VERSION
        exit
        ;;
    -l | --list )
        get_current_conf
        exit
        ;;
    * )
        echo "Invalid argument, try '-h' or '--help' for help"
        exit
        ;;
esac