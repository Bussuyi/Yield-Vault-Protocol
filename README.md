# Yield Vault Protocol

A decentralized yield farming protocol built on Stacks blockchain that allows users to deposit STX tokens and earn yield over time.

## Features

- **Secure Deposits**: Users can deposit STX tokens into the vault
- **Yield Generation**: Earn yield based on configurable annual percentage yield (APY)
- **Flexible Withdrawals**: Withdraw deposited funds at any time
- **Yield Claiming**: Claim accumulated yield rewards
- **Admin Controls**: Owner can adjust yield rates and pause the vault

## Contract Functions

### Public Functions

- `deposit(amount)` - Deposit STX tokens into the vault
- `withdraw(amount)` - Withdraw STX tokens from the vault
- `claim-yield()` - Claim accumulated yield rewards
- `set-yield-rate(new-rate)` - Admin function to set yield rate
- `toggle-vault()` - Admin function to pause/unpause the vault

### Read-Only Functions

- `get-user-deposit(user)` - Get user's total deposit amount
- `get-total-deposits()` - Get total deposits in the vault
- `get-yield-rate()` - Get current yield rate
- `calculate-yield(user)` - Calculate pending yield for a user

## Usage

1. Deploy the contract to Stacks blockchain
2. Users can deposit STX using the `deposit` function
3. Yield accumulates over time based on the configured rate
4. Users can claim yield using `claim-yield` function
5. Users can withdraw their principal using `withdraw` function

## Security

- Only contract owner can modify yield rates
- Vault can be paused in emergency situations
- All transfers are validated for sufficient balance