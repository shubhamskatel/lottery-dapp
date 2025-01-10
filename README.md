# Token Lottery DApp

This repository contains a Solidity smart contract (`TokenLottery.sol`) for a decentralized lottery DApp. Users can participate in the lottery by submitting tokens. The contract features:

- Whitelisted addresses for participation.
- Rate limiting (one-time participation per user).
- A time-bound lottery period.
- Automated winner selection and reward distribution.

## Contract Overview

The `TokenLottery` contract allows users to enter a lottery and includes the following functionalities:

- **Whitelisted Addresses:** Only users on the whitelist can participate.
- **Rate Limiting:** Users can participate only once in a lottery round.
- **Time-Bound Lottery:** A fixed period for accepting entries before selecting a winner.
- **Automated Winner Selection and Reward Calculation:** After the lottery period, a random winner is selected, and the reward is automatically transferred to the winner.

## Contract Details

- **`TokenLottery.sol`:** Main contract for the lottery system.
- **`IERC20.sol`:** Interface for the ERC20 token used in the lottery.
- **`Token.sol`:** Sample ERC20 token used in the lottery.

### Dependencies:

- `@openzeppelin/contracts`: For ERC20 interface and other utilities.

## Getting Started

### Prerequisites

1. **Node.js** and **npm** (or **yarn**)
2. **Hardhat**:
   ```bash
   npm install --save-dev hardhat
   ```
3. **OpenZeppelin Contracts**:
   ```bash
   npm install @openzeppelin/contracts
   ```

### Installation

```bash
git clone <repository_url>
cd <repository_directory>
npm install
```

### Configuration

In your Hardhat configuration file (`hardhat.config.js`), configure your network settings (e.g., local Hardhat network, testnet, or mainnet).

### Deployment

1. **Compile the contracts:**

   ```bash
   npx hardhat compile
   ```

2. **Deploy the `TokenLottery` contract:**

   ```bash
   npx hardhat run scripts/deploy.js --network <network_name>
   ```

   (Create a `deploy.js` script in the `scripts` directory.)

   Example `deploy.js`:

   ```javascript
   const { ethers } = require("hardhat");

   async function main() {
     const TokenLottery = await ethers.getContractFactory("TokenLottery");
     const tokenLottery = await TokenLottery.deploy(
       "<your_erc20_token_address>"
     );

     await tokenLottery.deployed();

     console.log("TokenLottery deployed to:", tokenLottery.address);
   }

   main().catch((error) => {
     console.error(error);
     process.exitCode = 1;
   });
   ```

### Interaction

- Use Hardhat console or a frontend application to interact with the contract.

## Contract Functions

- **`constructor(address _tokenAddress, uint256 _lotteryDuration)`**: Initializes the contract with the ERC20 token address and the lottery duration in seconds.
- **`whitelist(address _user)`**: Adds a user to the whitelist (only owner).
- **`removeFromWhitelist(address _user)`**: Removes a user from the whitelist (only owner).
- **`enterLottery(uint256 _amount)`**: Allows whitelisted users to enter the lottery by submitting tokens (only whitelisted users).
- **`endLottery()`**: Ends the lottery and picks a winner. Only callable after the lottery period has passed.
- **`getWinner()`**: Returns the address of the current winner.

## Events

- **`Entered(address indexed user, uint256 amount)`**: Emitted when a user enters the lottery.
- **`WinnerSelected(address indexed winner, uint256 reward)`**: Emitted when a winner is selected and rewarded.

## Security Considerations

- The contract uses **OpenZeppelin**'s libraries, ensuring security best practices such as safe ERC20 token transfers.
- Proper access control is implemented using modifiers (`onlyOwner`, `onlyWhitelisted`).
- Reentrancy attacks are mitigated by using safe transfer functions from OpenZeppelin's `IERC20` interface.
- It's highly recommended to conduct thorough testing and auditing before deploying to a production environment.

## Disclaimer

This contract is provided as-is and without any warranties. Use it at your own risk.
