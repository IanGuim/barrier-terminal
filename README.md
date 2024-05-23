# Description

Simple Shell Script tool that allows you to configure the KVM Software [barrier](https://github.com/debauchee/barrier) directly from the terminal. The script can also enable the autostart feature, bypassing a known bug in the Barrier GUI that prevents the application from automatically starting in certain Linux desktop environments upon system login.

# Features

Version 1.0

- [x] Client configuration.
- [x] Enable autostart on login.
- [x] Test configuration.

**TODO**
- [ ] Host configuration support.
- [ ] SSL configuration support.

# Usage

Install and configure barrier on the host PC, then on the client PC make sure all barrier related processes are terminated, as this script will start new ones.

```shell 
user@desktop:~$ pkill barrier # Terminate all processes barrier instances 
```
 
```shell
user@desktop:~$ ./barrier-terminal [OPTIONS] [ARGUMENT]

    Options:
    -h, --help                                                        # Display help message
    -s, --setup [SCREEN_NAME] [IP_HOST] [PORT] (default: 24800)       # Configure barrier
    -l, --list                                                        # Show current configuration
    -v, --version                                                     # Show current version
```
**Example**

```shell
user@desktop:~$ ./barrier-terminal --setup screen_left 192.168.1.14      # Configure barrier with given SCREEN_NAME and IP_HOST, using deafult port
```

The script will prompt the user to test the current configuration. If the user agrees, it will create a temporary process with the provided settings to verify everything is working correctly.

**Autostart**

The script will prompt to confirm using the current configuration and, if agreed, create a new entry in the ``$HOME/.config/autostart`` directory.

