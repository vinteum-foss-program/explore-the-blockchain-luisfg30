# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`


# 1 get transaction details 
base_transaction=$(bitcoin-cli getrawtransaction 37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517 1)

# 2. For each input transaction, extract the pubkey value from the witness structure
pub_keys=()

# loop through the .vin array in the base transaction
for i in $(echo "$base_transaction" | jq '.vin | keys | .[]'); do
  # Extract the txinwitness array for the current input
  txinwitness=$(echo "$base_transaction" | jq -r ".vin[$i].txinwitness")

  # Check if the txinwitness array is not empty and contains at least two elements
  if [ "$txinwitness" != "null" ] && [ $(echo "$txinwitness" | jq 'length') -gt 1 ]; then
    # The second item in txinwitness is the public key (after the signature)
    pub_key=$(echo "$txinwitness" | jq -r '.[1]')
    
    # Append the public key to the pub_keys array
    pub_keys+=("$pub_key")
  else
    echo "Error: No valid witness or public key found for input $i"
    exit 1
  fi
done

# 3. Check if the pub_keys array contains exactly 4 values
if [ "${#pub_keys[@]}" -ne 4 ]; then
  echo "Error: The initial txid must have 4 inputs"
  exit 1
fi

# 4 run the createmultisig command with the 4 pub_keys using P2SH type
bitcoin-cli createmultisig 1 "[\"${pub_keys[0]}\",\"${pub_keys[1]}\",\"${pub_keys[2]}\",\"${pub_keys[3]}\"]" "p2sh-segwit" | jq -r ".address"