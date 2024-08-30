## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


## CONTRACT ADDRESSES
Cytric Token = 0xF9178b484D2f8956ebC5d2730397E53213A544A7
 - Sepolia Link: https://sepolia.etherscan.io/address/0xF9178b484D2f8956ebC5d2730397E53213A544A7
Cytric Staking = 0x2A0F9D856D4D998639b3Ca58766eB27a2fa28cEF
 - Sepolia Link: https://sepolia.etherscan.io/address/0x2a0f9d856d4d998639b3ca58766eb27a2fa28cef


## Base Rate Calculation
Let’s say we want to distribute 1,000,000 tokens as rewards over one year, and we estimate that 10,000 tokens will be staked on average.

If our totalStaked is around 10,000 tokens:

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

## NOTES
Instruction say to deploy with Hardhat or Truffle but:
 - Truffle is no longer maintained
 - Hardhat is great but once you go Foundry, you don't go back