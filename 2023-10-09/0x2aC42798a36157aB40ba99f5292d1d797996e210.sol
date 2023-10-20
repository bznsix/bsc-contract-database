// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(
        uint256 a, 
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a, 
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a, 
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a, 
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a, 
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient, 
        uint256 amount
        ) external returns (bool);

    function allowance(
        address owner, 
        address spender
        ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner, 
        address indexed spender, 
        uint256 value);
}


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0), 
            "Ownable: new owner is the zero address"
            );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

contract OwnerWithdrawable is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    receive() external payable {}

    fallback() external payable {}

    function withdraw(address token, uint256 amt) public onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amt);
    }

    function withdrawAll(address token) public onlyOwner {
        uint256 amt = IERC20(token).balanceOf(address(this));
        withdraw(token, amt);
    }

    function withdrawCurrency(uint256 amt) public onlyOwner {
        payable(msg.sender).transfer(amt);
    }

    // function deposit(address token, uint256 amt) public onlyOwner {
    //     uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
    //     require(allowance >= amt, "Check the token allowance");
    //     IERC20(token).transferFrom(owner(), address(this), amt);
    // }
}

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount, 
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success, 
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target, 
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return 
        functionCallWithValue(
            target, 
            data, 
            value, 
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value, 
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target, 
        bytes memory data
        ) internal view returns (bytes memory) {
        return 
        functionStaticCall(
            target, 
            data, 
            "Address: low-level static call failed"
        );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target, 
        bytes memory data
    ) internal returns (bytes memory) {
        return 
        functionDelegateCall(
            target, 
            data, 
            "Address: low-level delegate call failed"
        );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.0;

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token, 
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token, 
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token, 
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token, 
            abi.encodeWithSelector(
                token.approve.selector, 
                spender, 
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value, 
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token, 
                abi.encodeWithSelector(
                    token.approve.selector, 
                    spender, 
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data, 
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)), 
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;

contract TokenPresale is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    address private teamAddress;

    uint256 public rate;
    
    address public saleToken;
    
    uint public saleTokenDec;
    
    uint256 public totalTokensforSale;
    
    uint256 public maxBuyLimit;
    
    uint256 public minBuyLimit;

    mapping(address => bool) public payableToken;

    mapping(address => uint256) public tokenPrices;

    bool public saleStatus;
    
    address[] public buyers;
    mapping(address => BuyerDetails) public buyersDetails;
    
    mapping(address => BuyerTokenDetails) public buyersAmount;
    
    // bool public isUnlockingStarted;
    bool public isPresaleStarted;
    uint public presalePhase;
    
    struct BuyerDetails {
        uint amount;
        bool exists;
    }

    mapping(address => uint256) public presaleData;
    
    uint256 public totalBuyers;
    uint256 public totalTokensSold;

    struct BuyerTokenDetails {
        uint amount;
        bool isClaimed;
    }
    
    struct BuyerAmount {
        uint amount;
        address buyer;
    }

    constructor(address _teamAddress) {
        saleStatus = false;
        teamAddress = _teamAddress;
    }

    modifier saleStarted(){
        require (!isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    modifier saleEnabled() {
        require(saleStatus == true, "Presale: is not enabled");
        _;
    }

    modifier saleStoped() {
        require(saleStatus == false, "Presale: is not stopped");
        _;
    }

    function setSaleTokenParams(
        uint256 _decimals,
        uint256 _totalTokensforSale,
        uint256 _rate,
        bool _saleStatus
    ) external onlyOwner {
        require(_rate != 0);
        rate = _rate;
        saleStatus = _saleStatus;        
        saleTokenDec = _decimals;
        totalTokensforSale = _totalTokensforSale;
    }

    function addWhiteListedToken(
        address _token,
        uint256 _price
    ) external onlyOwner {
        require(
            _price != 0, "Presale: Cannot set price to 0");
            payableToken[_token] = true;
            tokenPrices[_token] = _price;
    }

    function updateEthRate(uint256 _rate) external  onlyOwner {
        rate = _rate;
    }

    function updateTokenRate(
        address _token,
        uint256 _price
    )external onlyOwner{
        require(payableToken[_token], "Presale: Token not whitelisted");
        require(_price != 0, "Presale: Cannot set price to 0");
        tokenPrices[_token] = _price;
    }

    function startPresale() external onlyOwner {
        require(!isPresaleStarted, "PreSale: Sale has already started");
        isPresaleStarted = true;
    }

    function stopPresale() external onlyOwner {
        require(isPresaleStarted, "PreSale: Sale hasn't started yet!");
        isPresaleStarted = false;
    }

    function getTokenAmount(
        address token, 
        uint256 amount
    ) public view returns (uint256) {
        if(!isPresaleStarted) {
            return 0;
        }
        uint256 amtOut;
        if(token != address(0)){
            require(payableToken[token] == true, "Presale: Token not whitelisted");
            uint256 price = tokenPrices[token];
            amtOut = amount.mul(10**saleTokenDec).div(price);
        }
        else{
            amtOut = amount.mul(10**saleTokenDec).div(rate);
        }
        return amtOut;
    }

    function transferETH() private {
        uint256 teamAmount = msg.value.mul(20).div(100);

        payable(teamAddress).transfer(teamAmount);
        payable(owner()).transfer(msg.value.sub(teamAmount));
    }

    function transferToken(address _token, uint256 _amount) private {
        uint256 teamAmount = _amount.mul(20).div(100);

        IERC20(_token).safeTransferFrom(msg.sender, teamAddress, teamAmount);
        IERC20(_token).safeTransferFrom(
            msg.sender,
            owner(),
            _amount.sub(teamAmount)
        );
    }
    
    function buyToken(
        address _token, 
        uint256 _amount
        ) external payable {
         require(isPresaleStarted, "PreSale: Sale stopped!");

       uint256 saleTokenAmt;
       if(_token != address(0)){ 
            require(_amount > 0, "Presale: Cannot buy with zero amount");
            require(payableToken[_token] == true, "Presale: Token not whitelisted");
            saleTokenAmt = getTokenAmount(_token, _amount);
            // check if saleTokenAmt is greater than minBuyLimit
            require(saleTokenAmt >= minBuyLimit, "Presale: Min buy limit not reached");
            require(presaleData[msg.sender] + saleTokenAmt <= maxBuyLimit, "Presale: Max buy limit reached for this phase");
            require((totalTokensSold + saleTokenAmt) <= totalTokensforSale, "PreSale: Total Token Sale Reached!");            
        }
        else{
            saleTokenAmt = getTokenAmount(address(0), msg.value);
             // check if saleTokenAmt is greater than minBuyLimit
            require(saleTokenAmt >= minBuyLimit, "Presale: Min buy limit not reached");
            require(presaleData[msg.sender] + saleTokenAmt <= maxBuyLimit, "Presale: Max buy limit reached for this phase");
            require((totalTokensSold + saleTokenAmt) <= totalTokensforSale, "PreSale: Total Token Sale Reached!");
         }
       
         if (_token != address(0)) {
            transferToken(_token, _amount);
        } else {
            transferETH();
        }

        totalTokensSold += saleTokenAmt;
        buyersAmount[msg.sender].amount += saleTokenAmt;
        presaleData[msg.sender] += saleTokenAmt;              
       
        if (!buyersDetails[msg.sender].exists) {
            buyers.push(msg.sender);
            buyersDetails[msg.sender].exists = true;
            totalBuyers += 1;
        }

        buyersDetails[msg.sender].amount += saleTokenAmt;
    }

    function buyersAmountList(
        uint _from,
        uint _to
    ) external view returns (BuyerAmount[] memory) {
        require(_from < _to, "Presale: _from should be less than _to");

        uint to = _to > totalBuyers ? totalBuyers : _to;
        uint from = _from > totalBuyers ? totalBuyers : _from;

        BuyerAmount[] memory buyersAmt = new BuyerAmount[](to - from);

        for (uint i = from; i < to; i += 1) {
            buyersAmt[i].amount = buyersDetails[buyers[i]].amount;
            buyersAmt[i].buyer = buyers[i];
        }

        return buyersAmt;
    }

    function setMinBuyLimit(uint _minBuyLimit) external onlyOwner {
        minBuyLimit = _minBuyLimit;
    }

    function setMaxBuyLimit(uint _maxBuyLimit) external onlyOwner {
        maxBuyLimit = _maxBuyLimit;
    }
}