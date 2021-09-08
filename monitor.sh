#!/bin/bash

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

MSG=""
LOG_FILE=$(dirname $(readlink -e $0))/$LOG_FILE
REAL_BLOCK=$(curl -# "$SIDE_RPC/status" | jq '.result.sync_info.latest_block_height' | xargs )
STATUS=$(curl -# "$NODE_RPC/status")
CATCHING_UP=$(echo $STATUS | jq '.result.sync_info.catching_up')
LATEST_BLOCK=$(echo $STATUS | jq '.result.sync_info.latest_block_height' | xargs )
VOTING_POWER=$(echo $STATUS | jq '.result.validator_info.voting_power' | xargs )
ADDRESS=$(echo $STATUS | jq '.result.validator_info.address' | xargs )
POSITION=$(expr $(curl -# "$SIDE_RPC/validators?per_page=256" | jq "[.result.validators[].address] | index(\"$ADDRESS\")") + 1)
source $LOG_FILE

#echo $POSITION $CATCHING_UP $LAST_BLOCK $LATEST_BLOCK $REAL_BLOCK $VOTING_POWER

echo 'LAST_BLOCK="'"$LATEST_BLOCK"'"' > $LOG_FILE
echo 'LAST_POWER="'"$VOTING_POWER"'"' >> $LOG_FILE
echo 'LAST_POSITION="'"$POSITION"'"' >> $LOG_FILE

if [[ $LAST_POSITION != $POSITION ]]; then
    MSG="position changed $LAST_POSITION -> $POSITION"
fi

if [[ $LAST_POWER -ne $VOTING_POWER ]]; then
    DIFF=$(($VOTING_POWER - $LAST_POWER))
    if [[ $DIFF -gt 0 ]]; then
        DIFF="%2B$DIFF"
    fi
    MSG="voting power changed $DIFF%0A($LAST_POWER -> $VOTING_POWER)"
fi

if [[ $LAST_BLOCK -ge $LATEST_BLOCK ]]; then
    MSG="node is probably stuck at block $LATEST_BLOCK"
fi

if [[ $VOTING_POWER -lt 1 ]]; then
    MSG="validator inactive. Voting power $VOTING_POWER"
fi

if [[ $LATEST_BLOCK < $REAL_BLOCK ]]; then
    MSG="node is unsync, not catching up. $LATEST_BLOCK -> $REAL_BLOCK"
fi

if [[ $CATCHING_UP = "true" ]]; then
    MSG="node is unsync, catching up. $LATEST_BLOCK -> $REAL_BLOCK"
fi

if [[ $REAL_BLOCK -eq 0 ]]; then
    MSG="can't connect to $SIDE_RPC"
fi

if [[ $MSG != "" ]]; then
    MSG="$NODE_NAME $MSG"
    SEND=$(curl -s -X POST -H "Content-Type:multipart/form-data" "https://api.telegram.org/bot$TG_BOT/sendMessage?chat_id=$TG_ID&text=$MSG")
fi
