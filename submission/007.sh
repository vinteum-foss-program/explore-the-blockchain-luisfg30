# Only one single output remains unspent from block 123,321. What address was it sent to?

# 1 Get the block hash and detailed info (verbosity 2)
block_hash=$(bitcoin-cli getblockhash 123321)
block_json=$(bitcoin-cli getblock ${block_hash} 2)


# 2 Loop on all the block transactions and check if it has outputs spent
for outer_txid in $(echo $block_json | jq -r '.tx[] | .txid'); do
    # 3 Loop through the ".vout[]" array to check each output (vout_number)
    for vout_number in $(echo $block_json | jq -r ".tx[] | select(.txid == \"${outer_txid}\") | .vout | keys_unsorted | .[]"); do
        # Get the address associated with the current output
        address=$(echo $block_json | jq -r ".tx[] | select(.txid == \"${outer_txid}\") | .vout[${vout_number}] | .scriptPubKey.address")

        # Check if the output is unspent by calling gettxout
        is_unspent=$(bitcoin-cli gettxout ${outer_txid} ${vout_number} false)

        # If the gettxout returns a value, it means the output is unspent
        if [ -n "$is_unspent" ]; then
            echo "${address}"
            exit 0
        fi
    done
done

echo "No unspent output found in block 123321."