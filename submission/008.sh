# Which public key signed input 0 in this tx:
#   `e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163`

# 1 get transaction details
raw_tx=$(bitcoin-cli getrawtransaction e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163 1)

# 2. Parse the txwitness structure: Get the signature, witness type, and redeem script
signature=$(echo "$raw_tx" | jq -r '.vin[0].txinwitness[0]')
witness_type=$(echo "$raw_tx" | jq -r '.vin[0].txinwitness[1]')
redeem_script=$(echo "$raw_tx" | jq -r '.vin[0].txinwitness[2]')

# 3. Decode the redeem script to identify public keys
decoded_script=$(bitcoin-cli decodescript "$redeem_script")

# 4 Extract the fgirst public key from the decoded script. Assuming the compressed format that uses 32 bytes plus a prefix
public_key=$(echo "$decoded_script" | jq -r '.asm' | grep -oP '([0-9a-f]{66})' | head -n 1)

echo ${public_key}