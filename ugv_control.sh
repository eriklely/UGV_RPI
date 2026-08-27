#!/bin/bash

APP_CMD="XDG_RUNTIME_DIR=/run/user/1000 $HOME/ugv_rpi/ugv-env/bin/python $HOME/ugv_rpi/app.py"
APP_LOG="$HOME/ugv.log"
JUPYTER_CMD="/bin/bash $HOME/ugv_rpi/start_jupyter.sh"
JUPYTER_LOG="$HOME/jupyter_log.log"

start_app() {
    echo "Starting app.py ..."
    nohup bash -c "$APP_CMD" >> "$APP_LOG" 2>&1 &
    echo "app.py started (PID $!)"
}

stop_app() {
    echo "Stopping app.py ..."
    pkill -f "ugv_rpi/app.py"
    # Also free the ports just in case
    fuser -k 5000/tcp >/dev/null 2>&1
    fuser -k 11123/tcp >/dev/null 2>&1
    sleep 1
    echo "app.py stopped"
}

restart_app() {
    stop_app
    sleep 1
    start_app
}

start_jupyter() {
    echo "Starting Jupyter ..."
    nohup bash -c "$JUPYTER_CMD" >> "$JUPYTER_LOG" 2>&1 &
    echo "Jupyter started"
}

case "$1" in
    start)
        start_app
        start_jupyter
        ;;
    stop)
        stop_app
        pkill -f "start_jupyter.sh"
        pkill -f jupyter
        ;;
    restart)
        restart_app
        ;;
    restart-app)
        restart_app
        ;;
    status)
        echo "=== app.py ==="
        pgrep -af "ugv_rpi/app.py" || echo "Not running"
        echo ""
        echo "=== Jupyter ==="
        pgrep -af jupyter || echo "Not running"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|restart-app|status}"
        exit 1
        ;;
esac
