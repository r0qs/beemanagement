# Bee cheque management scripts

This script install a [systemd timers](https://wiki.archlinux.org/index.php/Systemd/timers) in your bee node to perform daily (or weekly) cashout of the node cheques.

It install the scripts at `/usr/local/bin` and defined a current threshold of 5 cheques. If the threshold is not satisfied when the timer triggers, no cashout will be performed.

You can change the threshold in the script `dailycash.sh`. If you prefer to run it weekly you can change the `./systemd/bee_cashout.timer` accordingly (i.e. `OnCalendar=weekly`)

## How to run

Se the options running the command below.
```sh
./beemgmt.sh --help
```
