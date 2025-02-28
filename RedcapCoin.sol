// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import standard ERC-20 functionality
import "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

contract RedcapCoin is ERC20, Ownable {
    uint256 public taxFee = 7;  // 7% total transaction fee
    address public devWallet;   // Wallet to receive development/marketing funds
    address public burnWallet = 0x000000000000000000000000000000000000dEaD;  // Burn address

    constructor() ERC20("Redcap Coin", "RCC") {
        _mint(msg.sender, 177600000 * 10 ** decimals());  // Total supply: 177,600,000 RCC
        devWallet = msg.sender;  // Set the developer wallet (your wallet)
    }

    // Override the default transfer function to apply transaction fees
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        uint256 feeAmount = (amount * taxFee) / 100;  // Calculate 7% fee
        uint256 transferAmount = amount - feeAmount;  // Subtract fee from the amount sent

        // Split the 7% fee into different buckets:
        uint256 reflectionFee = (amount * 2) / 100;  // 2% to holders
        uint256 burnFee = (amount * 1) / 100;        // 1% burned
        uint256 liquidityFee = (amount * 2) / 100;   // 2% for liquidity pool
        uint256 devFee = (amount * 2) / 100;         // 2% to dev/marketing wallet

        // Distribute the fees accordingly:
        super._transfer(sender, address(this), liquidityFee);  // Send to contract for liquidity
        super._transfer(sender, devWallet, devFee);           // Send to development wallet
        super._transfer(sender, burnWallet, burnFee);         // Burn tokens

        // Reflection: reduce supply to simulate rewards (simplified reflection mechanism)
        _reflectFee(reflectionFee);

        // Complete the transfer of the remaining tokens to the recipient
        super._transfer(sender, recipient, transferAmount);
    }

    // Simplified reflection logic: reduces total supply to mimic rewarding holders
    function _reflectFee(uint256 feeAmount) private {
        _burn(address(this), feeAmount);  // Burn the reflection portion from contract balance
    }
}
