#!/bin/bash

root=$(dirname "$(dirname "$0")")
agent="$root/agent.jar"
pid_file="/var/run/agent.pid"

function start() {
    if [[ -f "$pid_file" ]]; then
      pid=$(_pid)
      if _pid_exists "$pid"; then
        echo "agent process already exists. pid: ${pid}"
        return 2
      else
        echo "previous agent process not exit normally"
      fi
    fi

    echo "starting agent"
    (
        java -jar "$agent" </dev/null &>/dev/null &
        pid="$!"
        echo "$pid" >"$pid_file"
        wait "$pid"
        rm "$pid_file"
    ) </dev/null &>/dev/null &
    for (( i=0; $i<10; i++ )); do
        pid=$(_pid)
        if _pid_exists "$pid"; then
            echo "agent started"
            return
        fi
        sleep 1
    done
    echo "starting agent failed"
    return 2
}

function stop() {
    pid=$(_pid)
    if [[ "$?" != 0 ]]; then
        echo "can not found pid"
        return 1
    fi
    if _pid_exists "$pid"; then
        echo "stopping agent"
        kill -TERM "$pid" &>/dev/null
        for (( i=0; $i<10; i++ )); do
            if ! _pid_exists "$pid"; then
                echo "agent stopped"
                return
            fi
            sleep 1
        done
        echo "stopping agent failed"
        return 2
    else
        echo "agent process not exists"
    fi
}

function _pid_exists() {
    pid=$1
    if [[ -z "$pid" ]]; then
        return 1
    fi
    cmd="$(ps -p "$pid" | grep agent | grep -v grep)"
    if [[ "$cmd" != "" ]]; then
        return 0
    else
        return 3
    fi
}

function _pid() {
    if [[ ! -f "$pid_file" ]]; then
        return 1
    fi
    pid="$(cat "$pid_file" 2>/dev/null)"
    if [[ -z "$pid" ]]; then
        return 2
    fi
    echo "$pid"
}

function status() {
    pid=$(_pid)
    _pid_exists "$pid"
    case "$?" in
    0)
        echo "running"
        ;;
    1)
        echo "stopped"
        ;;
    *)
        echo "stopped but pid file exists"
        ;;
    esac
}

function help() {
    echo "agent.sh (start|stop|restart|status|help)"
    return 1
}

cmd=$1
case "$cmd" in
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    stop && start
    ;;
status)
    status
    ;;
*)
    help
    ;;
esac