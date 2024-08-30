// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CytricToken is ERC20, Ownable {
    uint256 public constant initialSupply = 100_000_000 ether;

    constructor() ERC20("Cytric Token", "CYT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    function mintTo(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
