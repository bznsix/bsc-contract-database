// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FoxFunnies {
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public burnedTokens;
    bool public paused;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint256 => mapping(address => uint256)) public snapshotBalances;
    uint256 public snapshotId = 1;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Pause();
    event Unpause();
    event Snapshot(uint256 id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        name = "FoxFunnies";
        symbol = "FXN";
        decimals = 18;
        totalSupply = 25000000 * 10**uint256(decimals); // 25 million tokens with 18 decimals
        balanceOf[owner] = totalSupply;
    }

    function transfer(address _to, uint256 _value) external whenNotPaused returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[msg.sender], "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external whenNotPaused returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external whenNotPaused returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) external onlyOwner whenNotPaused {
        require(_value <= balanceOf[owner], "Insufficient balance for burning");

        balanceOf[owner] -= _value;
        totalSupply -= _value;
        burnedTokens += _value;

        emit Burn(owner, _value);
    }

    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }

    function takeSnapshot() external onlyOwner {
        snapshotId++;
        emit Snapshot(snapshotId);

        for (uint256 i = 1; i <= snapshotId; i++) {
            snapshotBalances[i][msg.sender] = balanceOf[msg.sender];
        }
    }

    function getBalanceAtSnapshot(address _account, uint256 _snapshotId) external view returns (uint256) {
        require(_snapshotId <= snapshotId, "Invalid snapshot ID");
        return snapshotBalances[_snapshotId][_account];
    }
}