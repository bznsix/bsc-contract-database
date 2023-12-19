/**
 *Submitted for verification at Etherscan.io on 2021-02-26
*/

pragma solidity ^0.7.6;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external; }

contract TokenERC20 {
    string public name ;
    string public symbol;
    uint8 public constant decimals = 18;  
    uint256 public totalSupply;
	
	uint256 private constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

	// mapping(address => bool) public deployers;
	// address public dexPool;
	// uint256 public fee;
	// address public blackHole;
	// mapping(address => bool) public whites;

    mapping (address => uint256) public balanceOf;  // 
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);
	
	event Approval(address indexed owner, address indexed spender, uint256 value);

	event Mint(address indexed receiver, uint256 indexed amount);

	constructor(string memory tokenName, string memory tokenSymbol) public {
		totalSupply = INITIAL_SUPPLY;
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;

        // deployers[msg.sender] = true;
    }

    // modifier onlyDeployer() {
    //     require(deployers[msg.sender], "Only Deployer");
    //     _;
    // }

    // function setDeployer(address _dep, bool flag) public onlyDeployer {
    // 	deployers[_dep] = flag;
    // }

    // function setDexPool(address _pool) public onlyDeployer {
    // 	require(_pool != address(0), "pool can't be zero");
    // 	dexPool = _pool;
    // }

    // function setFee(uint256 _fee) public onlyDeployer {
    // 	require(_fee > 0 && _fee < 1000, "fee must be in range(0, 1000)");
    // 	fee = _fee;
    // }

    // function setBlackHole(address _bh) public onlyDeployer {
    // 	require(_bh != address(0), "blackHole must be 0x....dead");
    // 	blackHole = _bh;
    // }

    // function setWhite(address _from, bool flag) public onlyDeployer {
    // 	require(_from != address(0), "white can't be zero");
    // 	whites[_from] = flag;
    // }

    function _transfer(address _from, address _to, uint _value) internal returns (bool) {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        //uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // if(_to == dexPool) {
        // 	balanceOf[_from] -= _value;
        // 	balanceOf[_to] += (_value * (1000 - fee) / 1000);
        // 	balanceOf[blackHole] += (_value * fee / 1000);
        // 	emit Transfer(_from, _to, (_value * (1000 - fee) / 1000));
        // 	emit Transfer(_from, blackHole, (_value * fee / 1000));
        // } else {

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        
	    // }
        //assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
		return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
		//require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}