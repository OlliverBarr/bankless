// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

// import "./IERC20.sol";
// import "./CERC20.sol";

// A simple fixed-rate interest bank that interacts with Compound's interface
interface Erc20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
}

contract Bankless {
    
    Erc20 public usdc = Erc20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    CErc20 public cusdc = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    
    struct Depositor {
        uint principal;
        uint timestamp;
    }
    
    mapping (address => Depositor) user;
    
    function deposit(uint _amount) external {
        usdc.transferFrom(msg.sender, address(this), _amount);
        usdc.approve(address(cusdc), _amount);
        user[msg.sender].principal += _amount;
        user[msg.sender].timestamp = block.timestamp;
        cusdc.mint(_amount);
        require(cusdc.mint(_amount) == 0, "Minting failed");
    }
    
    function withdraw() external {
        uint _initial = user[msg.sender].principal;
        // re-entrancy prevention
        user[msg.sender].principal = 0;
        uint _timeElapsed = block.timestamp - user[msg.sender].timestamp;
        // flat 2% interest rate
        uint _interest = (_initial * _timeElapsed * 2) / (100 * 365 * 24 * 60 * 60) + 1;
        uint _exchangeRate = cusdc.exchangeRateCurrent();
        uint _redeemAmount = _interest / _exchangeRate * _initial;
        cusdc.redeem(_redeemAmount);
        usdc.transfer(msg.sender, (_initial * _interest));
    }
    
}