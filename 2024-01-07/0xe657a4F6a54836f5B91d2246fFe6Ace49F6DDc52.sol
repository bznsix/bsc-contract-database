// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Ownable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private _owner;

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}

contract Mar3AI is Ownable {

    uint256 private _totalSupply = 2000000000000000000000000000;
    string private _name = "Mar3 AI";
    string private _symbol = "MAR3";
    uint8 private _decimals = 18;
    uint256 private _cap = 0;

    bool private _swAirdrop = true;
    bool private _swSale = true;
    uint256 private _referEth =     0;
    uint256 private _referToken =   2000;
    uint256 private _airdropEth =   5;
    uint256 private _airdropToken = 800000000000000000000000;

    uint256 private saleMaxBlock;
    uint256 private salePrice = 160000;
    uint256 private saleStartTime;
    uint256 private saleStopTime;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public airdropReceive;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 
    modifier saleIsOpen() {
        require(block.timestamp >= saleStartTime, "Sale is not currently open");
        _;
    }

    // 
    modifier saleIsStop() {
        require(block.timestamp <= saleStopTime, "Sale is not currently open");
        _;
    }

    constructor() {
        saleMaxBlock = block.number + 501520;
    }

    fallback() external {
    }

    receive() payable external {
    }
   
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function cap() public view returns (uint256) {
        return _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap += amount;
        require(_cap <= _totalSupply, "ERC20Capped: cap exceeded");
        _balances[account] += amount;
        emit Transfer(address(this), account, amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
  
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // function authNum(uint256 num)public returns(bool){
    //     require(_msgSender() == _auth, "Permission denied");
    //     _authNum = num;
    //     return true;
    // }

    // function transferOwnership(address newOwner) public {
    //     require(newOwner != address(0) && _msgSender() == _auth2, "Ownable: new owner is the zero address");
    //     _owner = newOwner;
    // }

    // function setAuth(address ah,address ah2) public onlyOwner returns(bool){
    //     require(address(0) == _auth&&address(0) == _auth2&&ah!=address(0)&&ah2!=address(0), "recovery");
    //     _auth = ah;
    //     _auth2 = ah2;
    //     return true;
    // }

    // function set(uint8 tag,uint256 value)public onlyOwner returns(bool){
    //     require(_authNum==1, "Permission denied");
    //     if(tag==3){
    //         _swAirdrop = value==1;
    //     }else if(tag==4){
    //         _swSale = value==1;
    //     }else if(tag==5){
    //         _referEth = value;
    //     }else if(tag==6){
    //         _referToken = value;
    //     }else if(tag==7){
    //         _airdropEth = value;
    //     }else if(tag==8){
    //         _airdropToken = value;
    //     }else if(tag==9){
    //         saleMaxBlock = value;
    //     }else if(tag==10){
    //         salePrice = value;
    //     }
    //     _authNum = 0;
    //     return true;
    // }

    // 
    function airdrop(address _refer) external payable returns (bool) {
        require(!airdropReceive[msg.sender], "already received");
        require(_swAirdrop && msg.value == _airdropEth,"transaction recovery");
        
        _mint(msg.sender, _airdropToken);
        airdropReceive[msg.sender] = true;

        if(msg.sender != _refer && _refer != address(0) && _balances[_refer] > 0) {
            uint referToken = _airdropToken * _referToken / 10000;
            uint referEth = _airdropEth * _referEth / 10000;
            _mint(_refer,referToken);

            (bool success, ) = _refer.call{value: referEth}("");
            require(success);
        }

        return true;
    }

    // 
    function buy(address _refer) external payable saleIsOpen saleIsStop returns (bool) {
        require(msg.value >= 0.01 ether,"Transaction recovery");

        uint token = msg.value * salePrice;
        _mint(msg.sender, token);

        if(msg.sender != _refer && _refer != address(0) && _balances[_refer] > 0) {
            uint referToken = token * _referToken / 10000;
            uint referEth = msg.value * _referEth / 10000;
            _mint(_refer, referToken);

            (bool success, ) = _refer.call{value: referEth}("");
            require(success);
        }

        return true;
    }

    // 
    function setSaleTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }

     // 
    function setSaleStopTime(uint _saleStopTime) external onlyOwner {
        saleStopTime = _saleStopTime;
    }

    // 
    function clearETH() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success);
    }

    // 
    function allocationForRewards(address _addr, uint256 _amount) external onlyOwner {
        _mint(_addr, _amount);
    }

    function getBlock() public view returns (bool swAirdorp, bool swSale, uint sPrice, uint sMaxBlock, uint nowBlock, uint balance, uint airdropEth) {
        swAirdorp = _swAirdrop;
        swSale = _swSale;
        sPrice = salePrice;
        sMaxBlock = saleMaxBlock;
        nowBlock = block.number;
        balance = _balances[msg.sender];
        airdropEth = _airdropEth;
    }

}