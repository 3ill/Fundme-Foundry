-include .env

build:; forge build

deploy-goerli:; forge script script/FundMe.s.sol:FundMeDeploy --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API) -vvvv