// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract burnAirdrop{
    uint256 private constant _value = 0.02 * 10**18;
    uint256 public totalDroped;
    uint256 public threshold;
    uint256 private constant _mintAmount = 1000 * 10 ** 18;
    mapping(address => uint256) public mintTimes;
    mapping(address => uint256) public _cliamAmount;
    address private devAddress = 0xd71bBeB97e335def0B65E9A44b398E80b3E42C74;
    address public token;
    address public owner;
    bool inits = false;
    bool isMint = true;
    modifier onlyDev() {
    require(msg.sender == owner, "Only the devAddress can call this function");
    _;
}
    constructor(){
        owner = msg.sender;
    }
    function init(address _token)  public{
        require(!inits,'initsd');
        inits = true;
        token = _token;
    }

    function _drop() internal {
        address _msgSender = msg.sender;
        if(msg.value == _value && _msgSender != address(this) && totalDroped<15000){
            require(_msgSender == tx.origin, "Only EOA");
            require(mintTimes[_msgSender]<10);
            require(isMint,"MintStop");
            payable(devAddress).transfer(msg.value);
                ++totalDroped;
                ++mintTimes[_msgSender];
        }
    }
    function cliam() public{
        require(canReward(msg.sender) > 0);
        IERC20(token).transfer(msg.sender, canReward(msg.sender));
        _cliamAmount[msg.sender] += canReward(msg.sender);
    }
    function canReward(address account) public view returns(uint256){
        return mintTimes[account] * _mintAmount - _cliamAmount[account];
    }
    function setMint(bool _mint)public onlyDev {
        isMint = _mint;
    }
    function errorBalance() external onlyDev {
      payable(devAddress).transfer(address(this).balance);
    }

    function errorToken(address _token,uint256 _Amount) external onlyDev {
      IERC20(_token).transfer(devAddress, _Amount);
    }    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {
        _drop();
    }
}