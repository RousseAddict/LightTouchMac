#!/usr/bin/env python3
"""Programmatic access to the devices Light Touch is running (docs/programmatic-access.md).

Each running device has its own usbmux socket, which Light Touch's usbmuxd serves; the bundled inetcat opens a TCP
connection to a port on the device through it. This script finds them and wraps the common uses:

  lt-device.py list                                   running devices: name, iOS build, UDID, id, socket
  lt-device.py socket [--device D]                    a device's usbmux socket (USBMUXD_SOCKET_ADDRESS=UNIX:<it>)
  lt-device.py connect DEVICE_PORT [--device D]       stdin/stdout to a port on the device (an ssh ProxyCommand)
  lt-device.py forward LOCAL_PORT DEVICE_PORT [--device D]
                                                      127.0.0.1:LOCAL_PORT forwards to the device's port (as iproxy)
  lt-device.py install APP.ipa                        installs on the device Light Touch's window shows (AppSync)

D is a device's name, its id (or the start of it) or its UDID; it can be left out when one device is running.
Standard library only (Python 3.8, as macOS 11 has).
"""
import argparse
import os
import plistlib
import re
import socket
import subprocess
import sys
import threading

APP = "/Applications/Light Touch.app"
INETCAT = APP + "/Contents/MacOS/inetcat"


def running():
    """The running devices, from their usbmuxd processes (-S the socket, -C the device's usbmuxd-conf folder)."""
    listing = subprocess.run(["ps", "-axww", "-o", "pid=,args="], capture_output=True, text=True).stdout
    devices = []
    for line in listing.splitlines():
        if "/Contents/MacOS/usbmuxd " not in line:
            continue
        sock = re.search(r" -S (\S+)", line)
        conf = re.search(r" -C (.+?/usbmuxd-conf)", line)
        if not sock or not conf:
            continue
        folder = os.path.dirname(conf.group(1))
        try:
            with open(os.path.join(folder, "device.plist"), "rb") as f:
                record = plistlib.load(f)
        except OSError:
            record = {}
        devices.append({
            "name": record.get("name", "?"),
            "firmware": record.get("firmware", "?"),
            "udid": (record.get("identity") or {}).get("udid", "?"),
            "id": record.get("id", os.path.basename(folder)),
            "socket": sock.group(1),
        })
    return devices


def pick(wanted):
    devices = running()
    if not devices:
        sys.exit("lt-device: no device is running (start one in Light Touch)")
    if wanted:
        w = wanted.lower()
        devices = [d for d in devices
                   if d["name"].lower() == w or d["udid"].lower() == w or d["id"].lower().startswith(w)]
        if not devices:
            sys.exit(f"lt-device: no running device matches {wanted!r} (see: lt-device.py list)")
    if len(devices) > 1:
        sys.exit("lt-device: several devices are running; choose one with --device (see: lt-device.py list)")
    return devices[0]


def inetcat(device, port, **streams):
    env = dict(os.environ, USBMUXD_SOCKET_ADDRESS="UNIX:" + device["socket"])
    return subprocess.Popen([INETCAT, str(port)], env=env, **streams)


def forward(device, local, remote):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("127.0.0.1", local))  # loopback only: nothing else on the network reaches the device
    server.listen(16)
    print(f"lt-device: 127.0.0.1:{local} -> {device['name']} port {remote} (Ctrl-C stops)", file=sys.stderr)

    def serve(client):
        pipe = inetcat(device, remote, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

        def upstream():
            try:
                while True:
                    data = client.recv(65536)
                    if not data:
                        break
                    pipe.stdin.write(data)
                    pipe.stdin.flush()
            except OSError:
                pass
            finally:
                try:
                    pipe.stdin.close()
                except OSError:
                    pass

        threading.Thread(target=upstream, daemon=True).start()
        try:
            while True:
                data = pipe.stdout.read1(65536)
                if not data:
                    break
                client.sendall(data)
        except OSError:
            pass
        finally:
            client.close()
            pipe.kill()

    try:
        while True:
            client, _ = server.accept()
            threading.Thread(target=serve, args=(client,), daemon=True).start()
    except KeyboardInterrupt:
        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("list")
    for name in ["socket", "connect", "forward"]:
        command = commands.add_parser(name)
        command.add_argument("--device")
        if name == "forward":
            command.add_argument("local_port", type=int)
        if name in ["connect", "forward"]:
            command.add_argument("device_port", type=int)
    commands.add_parser("install").add_argument("ipa")
    args = parser.parse_args()

    if args.command == "list":
        devices = running()
        if not devices:
            print("no device is running")
        for d in devices:
            print(f"{d['name']}  {d['firmware']}  udid {d['udid']}  id {d['id']}\n  socket {d['socket']}")
    elif args.command == "socket":
        print(pick(args.device)["socket"])
    elif args.command == "connect":
        sys.exit(inetcat(pick(args.device), args.device_port).wait())
    elif args.command == "forward":
        forward(pick(args.device), args.local_port, args.device_port)
    elif args.command == "install":
        if not args.ipa.lower().endswith(".ipa") or not os.path.isfile(args.ipa):
            sys.exit(f"lt-device: {args.ipa} is not an .ipa file")
        if not running():
            sys.exit("lt-device: no device is running (start one in Light Touch)")
        subprocess.run(["open", "-a", APP, os.path.abspath(args.ipa)], check=True)
        print("lt-device: handed to Light Touch, which installs it on the device its window shows", file=sys.stderr)


if __name__ == "__main__":
    main()
