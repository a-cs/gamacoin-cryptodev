//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "./token.sol";

// import "hardhat/console.sol";

contract VendingMachine {
    //Properties
    address private admin;
    address public tokenAddress;
    uint256 private buyingprice;
    uint256 private sellingprice;

    // Modifiers
    modifier isAdmin() {
        require(msg.sender == admin, "Must be the admin");
        _;
    }

    constructor(address token) {
        admin = msg.sender;
        tokenAddress = token;
        buyingprice = 2 ether;
        sellingprice = 1 ether;
    }

    function availableSupply() public view returns (uint256) {
        return (GamaToken(tokenAddress).balanceOf(address(this)));
    }

    function buyingPrice() public view returns (uint256) {
        return (buyingprice);
    }

    function sellingPrice() public view returns (uint256) {
        return (sellingprice);
    }

    function buyTokens(uint256 amount) public payable {
        require(amount > 0, "Amount has to be greater than 0");
        require(
            msg.value >= amount * buyingprice,
            "The trasaction value was lower than expected"
        );
        require(availableSupply() >= amount, "Not enough tokens in stock");
        GamaToken(tokenAddress).transfer(address(this), msg.sender, amount);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount has to be greater than 0");
        require(
            address(this).balance >= amount * sellingprice,
            "The machine does not have enough Ether"
        );
        GamaToken(tokenAddress).transfer(msg.sender, address(this), amount);
        address payable payTo = payable(msg.sender);
        payTo.transfer(amount * sellingprice);
    }
}
