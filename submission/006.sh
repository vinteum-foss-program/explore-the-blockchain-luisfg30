# Which tx in block 257,343 spends the coinbase output of block 256,128?

# 1 Get the block info
block_hash=$(bitcoin-cli getblockhash 256128)
block_json=$(bitcoin-cli getblock ${block_hash})

# 2 extract the first transaction (coinbase from it)
coinbase_txid=$(echo ${block_json} | jq -r ".tx[0]")


# 3 Get block 257343 transactions in detailed mode, verbosity 2
block_hash=$(bitcoin-cli getblockhash 257343)
block_json=$(bitcoin-cli getblock ${block_hash} 2)

# 3 Loop on all transactions in block 247343 checking the vin values
for txid in $(echo $block_json | jq -r '.tx[]'); do
	#...
done


