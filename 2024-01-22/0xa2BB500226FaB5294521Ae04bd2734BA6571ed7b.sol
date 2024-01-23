/*
*██████╗░░█████╗░███╗░░██╗████████╗██╗░░██╗███████╗██████╗░░█████╗░██╗
*██╔══██╗██╔══██╗████╗░██║╚══██╔══╝██║░░██║██╔════╝██╔══██╗██╔══██╗██║
*██████╔╝███████║██╔██╗██║░░░██║░░░███████║█████╗░░██████╔╝███████║██║
*██╔═══╝░██╔══██║██║╚████║░░░██║░░░██╔══██║██╔══╝░░██╔══██╗██╔══██║██║
*██║░░░░░██║░░██║██║░╚███║░░░██║░░░██║░░██║███████╗██║░░██║██║░░██║██║
*╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PantherAI is IBEP20 {
    string public name = "Panther AI";
    string public symbol = "PAI";
    uint256 public totalSupply = 1000000000 * 10**18;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public teamAddress;
    uint256 public teamFeePercent = 0;
    uint256 public ownerFeePercent = 0;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FeePercentChanged(string feeType, uint256 oldPercent, uint256 newPercent);
    event Burn(address indexed burner, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        teamAddress = 0x3C39b41e76BD16B4f3d890b1Aa48a0c036C9edEB;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid transfer to the zero address");
        require(_value > 0, "Invalid transfer value");

        uint256 teamFee = (_value * teamFeePercent) / 100;
        uint256 ownerFee = (_value * ownerFeePercent) / 100;
        uint256 tokensToTransfer = _value - teamFee - ownerFee;

        balanceOf[_from] -= _value;
        balanceOf[_to] += tokensToTransfer;

        if (teamFee > 0) {
            balanceOf[teamAddress] += teamFee;
            emit Transfer(_from, teamAddress, teamFee);
        }
        if (ownerFee > 0) {
            balanceOf[owner] += ownerFee;
            emit Transfer(_from, owner, ownerFee);
        }

        emit Transfer(_from, _to, tokensToTransfer);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Transfer amount exceeds allowance");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance to burn");
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function changeTeamFee(uint256 newFeePercent) public onlyOwner {
        emit FeePercentChanged("Team", teamFeePercent, newFeePercent);
        teamFeePercent = newFeePercent;
    }

    function changeOwnerFee(uint256 newFeePercent) public onlyOwner {
        emit FeePercentChanged("Owner", ownerFeePercent, newFeePercent);
        ownerFeePercent = newFeePercent;
    }
	
	function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}