#!/bin/bash
#
# Example of how to run two things "simultaneously"
# Two processes are run: read, and update.
# 'Read' runs in the foreground and reads user input (arrow keys, here).
# 'Update' is in the background and just outputs data to the terminal.
# The two communicate with each other by trapping/killing signals.

# These two numbers mean something and shouldn't be changed.
# At the time of writing, I don't know what they mean exactly.
LEFT=38
RIGHT=36

COUNT=0
update()
{
        # If the "LEFT" signal is killed, the move_down function will execute.
        # If the "RIGHT" signal is killed, the move_up function will execute.
        trap "move_down;" $LEFT
        trap "move_up;" $RIGHT

        # Background loop: outputs date and value of 'COUNT'
        while true; do
                clear
                date
                echo "${COUNT}"
                echo "Use ctrl-c to exit."
                sleep .05
        done
}

move()
{
        # Traps ctrl-c so you can escape the infinite loop. Returns to main program.
        trap "return;" SIGINT SIGQUIT
        
        # Loop that constantly reads, character by character.
        # Only arrow keys (or C/D) will have an effect on the update loop.
        while true; do
                read -s -n 1 key
                # This case statement kills the right/left signals to trigger the traps.
                case "$key" in
                        [cC]) kill -$RIGHT $game_pid ;;
                        [dD]) kill -$LEFT $game_pid ;;
                esac
        done
}

move_down()
{
        let COUNT=$(($COUNT-1))
}

move_up()
{
        let COUNT=$(($COUNT+1))
}

# Run update in the background and read in the foreground.
update & 
game_pid=$!
move

# This kill command is necessary if the background process is still running an infinite loop.
kill -9 $game_pid
