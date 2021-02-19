# Bee cheque management scripts

This script install a [systemd timer](https://wiki.archlinux.org/index.php/Systemd/timers) in your bee node to perform daily (or weekly) cashouts of your cheques.

It installs the scripts at `/usr/local/bin` and defines a current threshold of 5 cheques to trigger the cashout action. If the threshold is not satisfied when the timer activates, no cashout will be performed.

You can change the threshold in the script `dailycash.sh`. If you prefer to run it weekly you can change the `./systemd/bee_cashout.timer` accordingly (i.e. `OnCalendar=weekly`).

## How to run

Se the options running the command below.
```sh
./beemgmt.sh --help
```

*You need to run the script as root* since it installs the timers system-wide.

## Install

```sh
sudo ./beemgmt.sh --install
```

### Checking Installation

List the current system timers and see if `bee_cashout.service` appears in the list like in the example below:
```
$ systemctl list-timers
NEXT                        LEFT          LAST                        PASSED       UNIT                         ACTIVATES                     
Sat 2021-02-20 00:00:00 CET 2h 50min left n/a                         n/a          bee_cashout.timer            bee_cashout.service           
...
```

Check if the timer is active:
```
sudo systemctl status bee_cashout.timer
```

Check if the service is present and marked to be trigger by the timer:
```
sudo systemctl status bee_cashout.service
```

### Troubleshooting

In case of problems, you can inspect the system logs:
```
sudo journalctl --unit bee_cashout.timer -n 100
sudo journalctl --unit bee_cashout.service -n 100
```

## Uninstall

```sh
sudo ./beemgmt.sh --remove
```