# Which public key signed input 0 in this tx:
#   `e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163`

# Extra considerations for the solution:
# 1- For this exercise solution we must rely on the human interpretaion of the decoded script and execution path.
# 2- We can confirm the result by using the aditional informaiton provided in the witness structure.
# 3- A complete generic code to solve this would require logic to evaluate automatically the bitcoin script language stack with parameters
# 3.1 some guidelines on how to do that are here: https://github.com/BlockchainCommons/Learning-Bitcoin-from-the-Command-Line/blob/master/09_3_Testing_a_Bitcoin_Script.md

# 1 get transaction details
raw_tx=$(bitcoin-cli getrawtransaction e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163 1)

# 2. Parse the txwitness structure: Get the signature, optional stack parameters, and redeem script
# Inside the 'vin' tag we have this sctructure:

# "txinwitness": [
#     "3044022050b45d29a3f2cf098ad0514dff940c78046c377a7e925ded074ad927363dc2dd02207c8a8ca7d099483cf3b50b00366ad2e2771805d6be900097c2c57bc58b4f34a501",
#     "01",
#     "6321025d524ac7ec6501d018d322334f142c7c11aa24b9cffec03161eca35a1e32a71f67029000b2752102ad92d02b7061f520ebb60e932f9743a43fee1db87d2feb1398bf037b3f119fc268ac"
# ]

signature=$(echo "$raw_tx" | jq -r '.vin[0].txinwitness[0]')
script_parameter=$(echo "$raw_tx" | jq -r '.vin[0].txinwitness[1]')
redeem_script=$(echo "$raw_tx" | jq -r '.vin[0].txinwitness[2]')

# 3. Decode the redeem script to identify public keys
decoded_script=$(bitcoin-cli decodescript "$redeem_script")

# The resulting decoded script is the following:
# OP_IF 
#     025d524ac7ec6501d018d322334f142c7c11aa24b9cffec03161eca35a1e32a71f 
# OP_ELSE 
#     144 OP_CHECKSEQUENCEVERIFY OP_DROP 02ad92d02b7061f520ebb60e932f9743a43fee1db87d2feb1398bf037b3f119fc2 
# OP_ENDIF 
# OP_CHECKSIG

# It has a conditional block, but we know that the first condition is executed because the script_parameter is "01"
# This way we can be sure that the script will evaluate to: <signature> <pubkey1> OP_CHECKSIG

# 4 Extract the first public key from the decoded script. Assuming the compressed format that uses 32 bytes plus a prefix '02' or '03'
public_key=$(echo "$decoded_script" | jq -r '.asm' | grep -oP '02[0-9a-f]{64}|03[0-9a-f]{64}' | head -n 1)

echo ${public_key}  