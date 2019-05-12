#!/bin/bash
# A pomodora timer script to help you manage your time
# Kevin Mostert
# 11/05/2019

# FUNCTIONS:

# Help Function
function help {

cat << _HELP_
Pomodora.sh is a script that you can use to track your work easier and make you more productive.
To stop the timer without saving any logs, pres ctrl+c.

Usage:
pomodora.sh [OPTION] [task_name]

Flags:
-h      Shows this help message.
-c      Removes the log file from your home directory.
-t	Specify a task name, instead of using the default of "Other".

-Kevin Mostert
_HELP_
}

# Check to make sure that this script isnt run as root
function user_check_function {
	if [[ $SUDO_USER != "" ]]
	then
		echo "Please run this as $SUDO_USER, and not as root."
		exit 1
	fi
}

# Creates a log in /home/$USER/
function logcheck_function {
	if [[ ! -f /home/"$USER"/pomodora.log ]]
	then
		echo "# Log file created by pomodora.sh." > /home/"$USER"/pomodora.log
		echo DESCRIPTION"$(printf '\t')"BEGIN"$(printf '\t')""$(printf '\t')""$(printf '\t')""$(printf '\t')"END >> /home/"$USER"/pomodora.log
	fi
}

# Check if a task has been defined
function task_function {
	if [[ "$1" == "" ]]
	then
		description="Other"
	else
		description="$1"
	fi
}

# Resets the timer
function reset_function {
	hour=00
	min=00
	sec=00
}

# Start the timer
function timer_function {
       # begin hour while loop - while hour
       #variable is greater than or equal to 0 do minute loop
       while [ $hour -ge 0 ]; do
                # begin minute loop - while min variable
                #is greater than or equal to 0 do second loop
                while [ $min -ge 0 ]; do
                        # begin second loop - while sec variable is greater
                        # than or equal to 0 print time left
                        while [ $sec -ge 0 ]; do
                                # echo time on same line so it overwrites last                                             # line, makes it look like countdown
                               	echo -ne "$(printf "%02d:%02d:%02d" $hour $min $sec)\r"
                                # Decrease the sec variable by 1
                                #each iteration of loop to countdown
                                (( sec=sec-1 ))
                                # wait a second before removing a second
                                # from the countdown clock
                                sleep 1
                        # End second loop
                        done
                        # Set second timer back to 59 to start new minute
                        sec=59
                        # Decrease min variable by 1 to remove a
                        # minute off the countdown
                        (( min=min-1 ))
                # end minute loop
                done
                # Set minute timer back to 59 to start new hour
                min=59
                # decrease the hour by 1 to remove hour off the countdown
                (( hour=hour-1 ))
        # end hour loop
        done
}

# Prompt the user that the timer is up
function prompt_function {
	read -r -p "It's time for $nexttask, do you wish to save this session? [Y/N]: " response
		if [[ "$response" =~ [nN(o)*] ]]
		then
			exit
		else
			echo -e "$description""$(printf '\t')""$(printf '\t')""$begindate""$(printf '\t')"Ended at: "$(date)" >> /home/"$USER"/pomodora.log
			echo "Session saved, enjoy your $nexttask!"
		fi
}

function clear_log {
	if [[ -f /home/"$USER"/pomodora.log ]]
	then
		rm /home/"$USER"/pomodora.log
		echo /home/"$USER"/pomodora.log has been removed.
	else
		echo "It doesn't seem like you have a log file in /home/$USER/"
	fi
}
# FLAG OPTIONS
#has_c_option=false
while getopts :hct: opt; do
        case $opt in
                h) help; exit;; #echo "Backup and compress files, skip compression with -n flag and restore with the -r flag."; exit;;
                c) clear_log; exit 1 ;;
                t) description="$2";echo $2 ;;
                 :) echo "Missing argument for option -$OPTARG";echo "pomodora.sh -t <task_name>"; exit 1;;
                \?) echo "Unknown option -$OPTARG"; help; exit 1;;
        esac
done

shift $(( OPTIND -1 ))

#START OF SCRIPT
description="Other"	#The default description
user_check_function	#Check that user isnt root
logcheck_function	#Check if a log exists
#task_function
nexttask="a break"
# Task begins
begindate="$(date)"	#Log start time
reset_function
#hour=00
min=25
#sec=00
timer_function
notify-send "Pomodora completed:" "Time for a break!"
prompt_function
# Break begins
begindate="$(date)"
description="Break: "
nexttask="work"
reset_function
#hour=00
min=5
#sec=00
timer_function
notify-send "Break is up:" "Time to work!"
prompt_function
#echo "$description""$(printf '\t')""$(printf '\t')""$begindate""$(printf '\t')"Ended at: "$(date)" >> /home/"$USER"/pomodora.log
echo "" >> /home/"$USER"/pomodora.log
exit 0
