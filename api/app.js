require('dotenv').config();
const fs = require("fs");
const path = require("path");
const express = require("express");
const { ethers } = require('ethers');
const { Connection, PublicKey } = require('@solana/web3.js');

const app = express();
const port = process.env.PORT || 3000;

// SEPOLIA SETUP
const stakingABI = JSON.parse(fs.readFileSync(path.join(__dirname, "abi", "stakingABI.json"), "utf8"));
const stakingAddress = process.env.STAKING_ADDRESS;
const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
const stakingContract = new ethers.Contract(stakingAddress, stakingABI, provider);

if (!provider || !stakingAddress) {
    console.error("Missing Sepolia RPC or the staking address");
    process.exit(1);
}

// SOLANA SETUP
const solanaConnection = new Connection(process.env.SOLANA_RPC_URL);
const tokenPublicKey = new PublicKey(process.env.TOKEN_ADDRESS);

app.use(express.json());

// SEPOLIA ROUTE

// Get user staking balance and accumulated rewards
app.get("/staking-info/:address", async (req, res) => {
    const address = req.params.address;
    try {
        const userData = await stakingContract.userData(address);
        res.json({
            address: address,
            stakingBalance: ethers.formatEther(userData.totalStaked),
            accumulatedRewards: ethers.formatEther(userData.unclaimedRewards),
        });
    } catch (error) {
        console.error("Error getting staking info:", error);
        res.status(500).json({ error: "Error getting staking info" });
    }
});

// SOLANA ROUTES

// Get token supply
app.get("/solana/token-supply", async (req, res) => {
    try {
        const totalSupply = await solanaConnection.getSupply(splTokenAddress);

        res.json({
            totalSupply: totalSupply.value.total
        });
    } catch (error) {
      console.error("Error getting token supply:", error);
      res.status(500).json({ error: "Error getting token supply" });
    }
});

// Get token balance for a specific address
app.get('/solana/token-balance/:address', async (req, res) => {
    const address = req.params.address;

    try {
      const walletAddress = new PublicKey(address);
      const tokenAccounts = await solanaConnection.getTokenAccountsByOwner(walletAddress, { mint: tokenPublicKey });
  
      const balance = await solanaConnection.getTokenAccountBalance(tokenAccounts.value[0].pubkey);

      res.json({
        address: address, 
        balance: balance.value.uiAmount 
    });
    } catch (error) {
      console.error('Error fetching token balance:', error);
      res.status(500).json({ error: 'Failed to fetch token balance' });
    }
});

// Start server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
