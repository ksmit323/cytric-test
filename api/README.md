# API to Read from the Smart Contract and Solana
Express.js API provides endpoints for Sepolia contracts and Solana token

## Prerequisites
- Node.js

## Installation
1. Make sure you are in the `api` directory:
```shell
cd api
```
2. Install dependencies:
```shell
npm install
```

## Configuration
Create a `.env` file in the `api/` directory with the following content:
```shell
ETHEREUM_RPC_URL=your_ethereum_rpc_url
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
CONTRACT_ADDRESS=your_staking_contract_address
```
There's a `.env.example` file with all the variables filled out!

## Usage
Start the server:
```shell
node app.js
```
The server will start on http://localhost:3000 (or the port specified by the PORT environment variable).

### API Endpoints
Sepolia Staking Contract Endpoints

 - GET /staking-info/:address: Get staking balance and accumulated rewards for a given address

Solana SPL Token Endpoints

 - GET /solana/token-supply: Get the total supply of the specified SPL token
 - GET /solana/token-balance/:address: Get the token balance of the specified address

## Deployment
API is configured for deployment on Render:
- https://cytric-test-wy70.onrender.com/
