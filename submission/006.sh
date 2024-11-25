# Which tx in block 257,343 spends the coinbase output of block 256,128?

# 1 Get the block info
block_hash=$(bitcoin-cli getblockhash 256128)
block_json=$(bitcoin-cli getblock ${block_hash})

# 2 extract the first transaction (coinbase from it)
coinbase_txid=$(echo ${block_json} | jq -r ".tx[0]")


# 3 Get block 257343 transactions in detailed mode, verbosity 2
block_hash=$(bitcoin-cli getblockhash 257343)
block_json=$(bitcoin-cli getblock ${block_hash} 2)

# 4 Loop through all transactions in block 257343
for outer_txid in $(echo $block_json | jq -r '.tx[] | .txid'); do
    # Loop through the ".vin[]" array to check each input's "txid"
    for vin_txid in $(echo $block_json | jq -r ".tx[] | select(.txid == \"${outer_txid}\") | .vin[].txid"); do
        # If any vin contains "txid" that matches the coinbase_txid, we found the spender
        if [[ "$vin_txid" == "$coinbase_txid" ]]; then
            echo ${outer_txid}
            exit 0
        fi
    done
done

echo "No transaction in block 257343 spends the coinbase output of block 256128"
