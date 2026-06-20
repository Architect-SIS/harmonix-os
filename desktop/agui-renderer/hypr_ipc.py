"""Hyprland IPC bridge for ag-ui notifications."""
import subprocess
def notify(title: str, body: str):
    subprocess.run(["notify-send", title, body], check=False)
