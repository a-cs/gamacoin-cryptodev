//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

// import "hardhat/console.sol";

interface IERC20 {
    //Implementado (mais ou menos)
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);

    //Não implementados (ainda)
    //function allowence(address owner, address spender) external view returns(uint256);
    //function approve(address spender, uint256 amount) external returns(bool);
    //function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    //Implementado
    event Transfer(address from, address to, uint256 value);

    //Não está implementado (ainda)
    //event Approval(address owner, address spender, uint256 value);
}

contract GamaToken is IERC20 {
    //Enums
    enum Status {
        PAUSED,
        ACTIVE
    }

    //Properties
    address private owner;
    string public constant name = "GamaCoin";
    string public constant symbol = "GAMA";
    uint8 public constant decimals = 3; //Default dos exemplos é sempre 18
    uint256 private totalsupply;
    Status contractState;

    mapping(address => uint256) private addressToBalance;

    // Events
    // event Transfer(address sender, address receiver, uint256 amount);

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner, "Must be the owner");
        _;
    }

    modifier isActive() {
        require(contractState == Status.ACTIVE, "Contract is Paused");
        _;
    }

    //Constructor
    constructor(uint256 total) {
        totalsupply = total;
        addressToBalance[address(msg.sender)] = totalsupply;
        owner = msg.sender;
        contractState = Status.ACTIVE;
    }

    function state() public view returns (Status) {
        return contractState;
    }

    function whoIsOwner() public view returns (address) {
        return owner;
    }

    //Public Functions

    function totalSupply() public view override returns (uint256) {
        return totalsupply;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return addressToBalance[tokenOwner];
    }

    function transfer(
        address sender,
        address receiver,
        uint256 quantity
    ) public override isActive returns (bool) {
        require(
            quantity <= addressToBalance[sender],
            "Insufficient Balance to Transfer"
        );
        require(
            address(receiver) != address(0),
            "Account address can not be 0"
        );
        addressToBalance[sender] = addressToBalance[sender] - quantity;
        addressToBalance[receiver] = addressToBalance[receiver] + quantity;

        emit Transfer(sender, receiver, quantity);
        return true;
    }

    function mint(address account, uint256 amount)
        public
        override
        isOwner
        isActive
        returns (bool)
    {
        require(address(account) != address(0), "Account address can not be 0");
        require(amount > 0, "Amount has to be greater than 0");
        addressToBalance[account] += amount;
        totalsupply += amount;
        emit Transfer(address(0), account, amount);

        return true;
    }

    function burn(address account, uint256 amount)
        public
        override
        isOwner
        isActive
        returns (bool)
    {
        require(address(account) != address(0), "Account address can not be 0");
        require(
            addressToBalance[account] >= amount,
            "Account does not have enough funds"
        );
        addressToBalance[account] -= amount;
        totalsupply -= amount;
        emit Transfer(address(0), account, amount);

        return true;
    }

    function pausable() public isOwner returns (bool) {
        require(contractState == Status.ACTIVE, "Contract is already Paused");
        contractState = Status.PAUSED;
        return true;
    }

    function activable() public isOwner returns (bool) {
        require(contractState == Status.PAUSED, "Contract is already Active");
        contractState = Status.ACTIVE;
        return true;
    }

    function kill() public isOwner {
        selfdestruct(payable(owner));
    }
}
