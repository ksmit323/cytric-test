# Custom Staking Smart Contract


## Prerequisites
- Foundry:
   - https://book.getfoundry.sh/

## Installation

1. Make sure you are in the `contracts` directory:

```shell
$ cd contracts
```
2. Install dependencies

```shell
$ forge install
```

3. Compile contracts

```shell
$ forge build
```

## Deployment

### To deploy the contracts to the Sepolia testnet:

1. Set up your `.env` file with your private key and RPC URL:

```shell
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=your_sepolia_rpc_url
```
2. To deploy, run the Makefile script.  Have a look in there for a list of commands:
```shell
$ make deployCytricToken ARGS="--network sepolia"
```

## Contract Addresses
- Cytric Token: 0xF9178b484D2f8956ebC5d2730397E53213A544A7
  - Sepolia Link: https://sepolia.etherscan.io/address/0xF9178b484D2f8956ebC5d2730397E53213A544A7
    
- Cytric Staking: 0x2A0F9D856D4D998639b3Ca58766eB27a2fa28cEF
  - Sepolia Link: https://sepolia.etherscan.io/address/0x2a0f9d856d4d998639b3ca58766eb27a2fa28cef

## Base Rate Calculation
Let’s say we want to distribute 1,000,000 tokens as rewards over one year, and we estimate that 10,000 tokens will be staked on average.

If our `totalStaked` is around 10,000 tokens:

- Estimated Rewards per Year = Base Rate x Total Staked x Duration

Let’s assume we want to distribute rewards evenly over one year:

- Total Rewards per Year = 1,000,000 tokens

We can rearrange this to calculate the base rate:

- Base Rate = Total Rewards per Year / (Total Staked x Duration)

*A few moments of basic highschool math later...*

- Base Rate = 1,000,000 tokens / (10,000 tokens x 365 days x 24 hours x 60 minutes x 60 seconds)
- Base Rate = 0.00317

Then convert to **wei**
- Base Rate = 3170000000000000


## IMPROVEMENTS
- Test cases
    - Integration tests
    - Unit Tests
    - Invariant Tests
    - Fuzz Testing
- Static Analysis
- Manual Security review
- Gas Optimizations.. for the love of god, *gas optimizations*

## NOTES
Instruction say to deploy with Hardhat or Truffle but:
 - Truffle is no longer maintained
 - Hardhat is great but once you go Foundry, you don't go back
