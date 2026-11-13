#!/bin/bash
set -e
if [ -z "$KASM_PASSWORD" ]; then
  echo "KASM_PASSWORD secret is not set. Add it in Fly (Secrets), then redeploy."
  sleep 60
  exit 1
fi
ME="$(id -un)"
mkdir -p "$HOME/.vnc"

cat > "$HOME/.vnc/kasmvnc.yaml" <<YAML
desktop:
  resolution:
    width: 1280
    height: 720
  allow_resize: true
network:
  protocol: http
  interface: 0.0.0.0
  websocket_port: 6901
  ssl:
    require_ssl: false
YAML

cat > "$HOME/.vnc/xstartup" <<'XS'
#!/bin/sh
xterm -geometry 100x20+20+20 &
( sleep 3; chromium --no-sandbox --disable-dev-shm-usage --disable-gpu --start-maximized --user-data-dir="$HOME/browser-profile" > "$HOME/browser.log" 2>&1 ) &
exec openbox-session
XS
chmod +x "$HOME/.vnc/xstartup"

printf '%s\n%s\n' "$KASM_PASSWORD" "$KASM_PASSWORD" | vncpasswd -u "$ME" -w -r >/dev/null 2>&1

rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
vncserver :1 -select-de manual

# Keep the container alive while the desktop runs; if it dies, exit so Fly restarts it.
while pgrep -x Xvnc >/dev/null 2>&1; do sleep 5; done
echo "Desktop stopped."
exit 1
