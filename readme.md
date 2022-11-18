# Simple server report script

Highly configurable bash script which generates report in html format which can be:
- piped to another command
- returned in eml wrapper
- sent as an email immediately

It can be used to provide very simple server monitoring. Parts of the report are designed as plugins. There are few already prepared plugins:
- Disks space report
- Disks health report
- Processess with highest load
- Available updates
- Users logged in the system
- Two directories differences

## Usage
```bash
# Generates html email and sends it
./sendreport -o=sendmail

# Prints html report to stdout
./sendreport -o=html

# Prints eml message with html report to stdout
./sendreport -o=eml
```

## Email example
<img src="images/email_screenshot.png" width="401" height="548" alt="Email screenshot" title="Email screenshot">

## Installation
You need to have installed GIT before running this command. To install run:
```bash
git clone https://github.com/tomasklement/simple-server-report.git && git -C simple-server-report submodule update --init --recursive
```
This will create directory "simple-server-report" and clone the latest version with its submodules from github.

## Upgrade
To upgrade to the latest version simply run:
```bash
./upgrade
```
This will pull the latest version with its submodules from github.

## Configuration

- Create `config.sh` in the script root directory and place your configuration values to it.
- Check `base_config.sh` for available basic configuration values
- Do not change values directly in `base_config.sh` file (your changes would be overwritten by update of the script)
- Check plugins in `reports` directory. They have their own configuration values located at the top of each script.
- Configuration of plugins is also placed into `config.sh`

### Example of config.sh

```bash
#!/usr/bin/env bash

EMAIL_RECIPIENT="john.doe@gmail.com"
EMAIL_RECIPIENT_NAME="John Doe"
EMAIL_SENDER="noreply@myserver"
EMAIL_SENDER_NAME="My server"
```

## Writing own plugin

### Create plugin script

Lets name our plugin **"example"**. Create script `./reports/example.sh` with following content:
```bash
#!/usr/bin/env bash

# All the logic should be in this function to avoid possible conflicts in variable names with main script. Also the
# function must have the same name as the plugin and should start with "ssr::" prefix.
function ssr::example {
    local dfReport

    dfReport=$( df -h )

    echo "${dfReport}"
}
```

Add the name of the script (without the extension) to the configuration variable `REPORTS` in your `config.sh`
```bash
REPORTS=( "updates" "example" )
```
Well done. Your report is now part of the report email.