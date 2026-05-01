There is no formal automated test suite. Typical validation is to run the relevant `./setup` subcommand(s), launch Quickshell (`pkill qs; qs -c ii`), and verify behavior in the live session. `./diagnose` is the troubleshooting entrypoint for bug reports.

Sources: `sdata/subcmd-install/2.setups.sh:23-73`, project instructions from the repo's top-level documentation