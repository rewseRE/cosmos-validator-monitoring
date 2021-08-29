# Simple shell script for monitoring Cosmos-SDK based networks validators.
This shell script checks node health, voting power, validator position and sent warnings to Telegram chat if the node is unsynced or something changed.
<br/>
#### Requirements
bash, curl, jq
<br/>
#### Installation
Set the variables in file monitor.sh and run script.
```bash
# Node name, e.g. "Cosmos"
NODE_NAME=""
# File name for saving parameters, e.g. "cosmos.log"
LOG_FILE=""
# Your node RPC address, e.g. "http://127.0.0.1:26657"
NODE_RPC=""
# Trusted node RPC address, e.g. "https://rpc.cosmos.network:26657"
SIDE_RPC=""
# Telegram bot API
TG_BOT=""
# Telegram chat ID
TG_ID=""
```

