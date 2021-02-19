# Bee cheque management scripts

This script install a [systemd timer](https://wiki.archlinux.org/index.php/Systemd/timers) in your bee node to perform daily (or weekly) cashouts of your cheques.

It installs the scripts at `/usr/local/bin` and defines a current threshold of 5 cheques to trigger the cashout action. If the threshold is not satisfied when the timer activates, no cashout will be performed.

You can change the threshold in the script `dailycash.sh`. If you prefer to run it weekly you can change the `./systemd/bee_cashout.timer` accordingly (i.e. `OnCalendar=weekly`).

## How to run

Se the options running the command below.
```sh
./beemgmt.sh --help
```
