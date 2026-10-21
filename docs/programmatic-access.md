# Reaching a Light Touch device programmatically

How to talk to an emulated iPhone from scripts and tools on the Mac, and how to install an app on it. Written for the
Big Sur build of Light Touch on this Mac, with the iPhone 4 (iOS 5.1.1, build 9B208) as the example. Light Touch
emulates the iPhone 4 (n90ap), not the 4S.

Everything below needs the device **running** in Light Touch. The helper script is `tools/lt-device.py` in this
repository (`~/Documents/perso/LightTouchMac-bigsur`). It is one standalone file: copy it along with this page when you
hand this off. It uses only Python's standard library, so Big Sur's own `/usr/bin/python3` (3.8) runs it.

## There is no IP address: the device is reached over (emulated) USB

- The emulated iPhone sits behind QEMU's private NAT. It has no address on the Mac or on your network, so nothing can
  open a connection *to* it by IP.
- What it does have is a USB connection to the Mac. Each running device gets its own **usbmux socket**, a Unix socket
  that Light Touch's own usbmuxd serves. It changes at every boot.
- Any tool that speaks usbmux reaches the device through it, given `USBMUXD_SOCKET_ADDRESS=UNIX:<socket>`. That
  includes Light Touch's bundled `inetcat` and the libimobiledevice tools.
- `lt-device.py` finds the socket and turns it into whatever you need: a pipe, or a `127.0.0.1` port.

Find the running devices:

```console
$ tools/lt-device.py list
iPhone 4  n90ap-9B208  udid 5cfe6bc4f1423ee584f84f2aa32cc1f9d323f546  id 68FCB55C-9B1E-4FA5-8483-79565815DDBB
  socket /var/folders/5k/kkryt98930gbjr2kjt6v_ss80000gn/T/ltm-mux-2472C23A-c.sock
```

With several devices running, every command takes `--device` followed by the device's name, its id (or the start of
it) or its UDID.

## A host and port for the device

To get a TCP endpoint on the Mac that leads to a port on the device (what `iproxy` does for a real iPhone):

```console
$ tools/lt-device.py forward 8080 8080
lt-device: 127.0.0.1:8080 -> iPhone 4 port 8080 (Ctrl-C stops)
```

- **The host is `127.0.0.1` and the port is the first number.** Each connection to it is a fresh TCP connection to the
  second port on the device. This is the address to hand to a test runner, `curl` or a browser, while `forward` runs.
- It listens on loopback only, so nothing else on your network reaches the device through it.
- For a one-off pipe instead (scripts, or an `ssh` ProxyCommand), `connect` joins stdin and stdout to the device's port:

  ```console
  $ tools/lt-device.py connect 8080
  ```

So **a test harness on the Mac connects to your app, not the other way round**: give the app a listening socket (a
small HTTP or command server on some port) and forward to it. Checked on this Mac: through `forward 10078 62078` and
`connect 62078`, the iPhone's lockdown service answers (`com.apple.mobile.lockdown`).

## The device's own network

- Your app's outgoing traffic goes through Light Touch's web proxy and NAT. **Device ▸ Network ▸ Connect to the
  Internet** turns internet access on and off.
- Light Touch never lets the device reach the Mac's loopback (`127.0.0.1`, `::1`).
- With **Device ▸ Network ▸ Attach to Local Network** on, the device may reach your local network, the Mac's own LAN
  address included. A test server on the Mac is then reachable from the app at the Mac's LAN IP (System Preferences ▸
  Network), not at `127.0.0.1`.

## Installing an app (AppSync)

AppSync is part of the guest tools Light Touch installs on the device at boot. It makes the device's installer accept
apps without a valid Apple signature, so your own builds install as they are.

```console
$ tools/lt-device.py install ~/Builds/MyApp.ipa
```

That is the same as dragging the `.ipa` onto the device's window, or `open -a "/Applications/Light Touch.app"
MyApp.ipa`. Light Touch installs it on **the device its window is showing**, so start that device first.

The `.ipa` must:
- hold `Payload/<Name>.app` with its `Info.plist`;
- have a `MinimumOSVersion` no higher than the device's iOS (5.1.1 here); Light Touch warns otherwise;
- have an armv7 or armv6 binary, which is what the iPhone 4 runs.

Light Touch makes the binary executable if the archive lost that bit.

Light Touch doesn't log a successful install. Watch the home screen, or use the tools below (`ideviceinstaller -l`
lists the installed apps).

## libimobiledevice tools (logs, app list, files, screenshots)

The standard tools work through the same socket. Install them with Homebrew (`brew install libimobiledevice
ideviceinstaller`); on Big Sur Homebrew builds them from source. Then:

```console
$ export USBMUXD_SOCKET_ADDRESS=UNIX:$(tools/lt-device.py socket)
$ idevicesyslog                      # the device's log, your app's NSLog output included
$ ideviceinfo                        # the device's lockdown values
$ ideviceinstaller -l                # installed apps; -i App.ipa installs, -U com.example.app removes
$ idevicecrashreport -e ./crashes    # crash reports
$ idevicescreenshot shot.png         # needs the Developer Disk Image: the Tweaks panel's Developer Settings
```

These aren't installed or tried on this Mac yet. The socket changes at every boot, so set the variable again after a
restart. The Developer Settings switch (iOS 4.2 to 7.1.2) mounts the Developer Disk Image on `/Developer`, which has
the screenshot service.

## SSH and SFTP (some iOS versions only)

Light Touch can run an SSH server on the device, but only on these builds:

| Device | iOS | Build |
|---|---|---|
| iPod touch (2nd generation) | 2.2, 3.0, 3.1.3 | 5F138, 7A341, 7E18 |
| iPad | 3.2 | 7B500 |
| iPhone 4 | 4.2.1 | 8C148 |

So the iPhone 4 on iOS 5.1.1 has no SSH. For a shell on an iPhone 4, add one on **iOS 4.2.1 (8C148)**: Add Device, with
Show experimental ticked.

To turn it on for a device (upstream's `tools/device-access` does the same, but needs a newer Swift than Big Sur has):

```console
$ ID=$(tools/lt-device.py list | sed -n 's/.* id \([0-9A-F-]*\)$/\1/p' | tr A-Z a-z)   # the device's id, lowercased
$ D="$HOME/Library/Application Support/Light Touch/DeveloperSSH/$ID"
$ mkdir -p "$D" && chmod 700 "$D" && echo 1 > "$D/enabled"
```

Restart the device. Light Touch then creates the device's keys (`id_ecdsa`, `known_hosts`) and, while it runs,
`connection.json` in that folder. Then:

```console
$ ssh -o HostName=localhost -o Port=22 -o User=root -o HostKeyAlias=lighttouch-$ID \
      -o UserKnownHostsFile="$D/known_hosts" -o IdentityFile="$D/id_ecdsa" -o IdentitiesOnly=yes \
      -o ProxyCommand="$PWD/tools/lt-device.py connect 22 --device $ID" lighttouch-$ID
```

`sftp` and `scp` take the same options. Deleting `enabled` and restarting turns it off again. This hasn't been tried
on this Mac yet: no device here runs a supported build.

## What isn't scriptable

- Taps, swipes and the hardware buttons from a script: Light Touch's input comes from its window, and it has no
  command-line or AppleScript interface.
- The QEMU debug port (Device ▸ Debugging ▸ Debug Port…) debugs the whole emulated machine, not an app.
