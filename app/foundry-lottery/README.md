# Provably Random Raffle Contracts

## About

This code is to create a provable random smart contract lottery.

## What do we want to do?

1. Users can enter the lottery by paying for a ticket.
   - The ticket fees are going to go to the winner of the lottery during the draw
2. After X period of time, the lottery will automaticall draw a winner
   - And this will be done programatically
3. Using Chainlink VRF & Chainlink Automation
   - Chainlink VRF -> Randomness
   - Chainlink Automation -> Time based trigger

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

<https://book.getfoundry.sh/>

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Anvil

```shell
anvil
```

### Deploy

```shell
forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
cast <subcommand>
```

### Help

```shell
forge --help
anvil --help
cast --help
```
