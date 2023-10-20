// SPDX-License-Identifier: GPL-3.0
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address public _contractOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function contractOwner() public view virtual returns (address) {
        return _contractOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_contractOwner, address(0));
        _setContractOwner(address(0));
    }

    modifier onlyOwner() {
        require(contractOwner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(_contractOwner, newOwner);
        _setContractOwner(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_contractOwner, newOwner);
        _setContractOwner(newOwner);
    }

    function _setContractOwner(address newOwner) internal {
        _contractOwner = newOwner;
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

 contract GFD_Token_Locking is Ownable{

    struct _tokens{
        uint256 _amount;
        uint256 _interval;
        uint256 _lockingTime;
        uint256 _lastWithdraw;
        uint256 _withdrawnAmount;
        uint256 _intervalAmount;
        uint256 _releaseStartTime;
        uint256 _1streleaseAmount;
    }
    mapping(address=>_tokens) public Tokens;

    address public Authorised;


    constructor(){

    }

    function lock(address token,uint256 amount,uint256 interval,uint256 intervalamt,uint256 _releaseStarttime,uint256 _releaseStartAmount) public onlyOwner returns(bool){
        require(token!=address(0),"Invalid Token Address");
        require(amount>0,"Invalid Amount");
        require(interval>0,"Invalid Interval");
        require(Tokens[token]._withdrawnAmount==Tokens[token]._amount,"Token Lock Already Exist");

        IERC20(token).transferFrom(msg.sender,address(this),amount);
        Tokens[token]=_tokens(amount,interval,block.timestamp,block.timestamp+_releaseStarttime,0,intervalamt,block.timestamp+_releaseStarttime,_releaseStartAmount);


        return true;
    }

    function setAuthWallet(address _auth) public onlyOwner{
        require(_auth!=address(0),"Invalid Address");
        Authorised=_auth;
    }

    function WithdrawReleasedAmount(address _token) public returns(bool){
        require(msg.sender==Authorised,"You DOnt Have Permission To Withdraw");
        require(Tokens[_token]._withdrawnAmount<=Tokens[_token]._amount,"All Tokens Are Released");
        uint amt=checkUnlockAmount(_token);
        Tokens[_token]._lastWithdraw=block.timestamp;
        Tokens[_token]._withdrawnAmount+=amt;
        IERC20(_token).transfer(msg.sender,amt);
        return true;
    }



    function checkUnlockAmount(address _token) public view returns(uint256 amt){
        require(_token!=address(0),"Invalid Token Address");
        require(block.timestamp>=Tokens[_token]._releaseStartTime,"Token Not Released");

        
            uint j=1;
            uint256 intervalOccr=0;
            uint256 temp=Tokens[_token]._interval;
            uint256 time=block.timestamp;

            if(Tokens[_token]._releaseStartTime==Tokens[_token]._lastWithdraw)
            {
                amt+=Tokens[_token]._1streleaseAmount;
            }
        
            for(uint i=0;i<j;i++)
            {
            
             if(Tokens[_token]._lastWithdraw+temp<=time)
                {
                    if(Tokens[_token]._withdrawnAmount+amt>Tokens[_token]._amount)
                    {
                        amt=Tokens[_token]._amount-Tokens[_token]._withdrawnAmount;
                        break;
                    }
                    else
                    {
                        intervalOccr+=1;
                        temp+=Tokens[_token]._interval;
                        j++;
                        amt+=Tokens[_token]._intervalAmount;
                    }
                
                }
            }

            if(Tokens[_token]._withdrawnAmount+amt>Tokens[_token]._amount)
            {
                amt=Tokens[_token]._amount-Tokens[_token]._withdrawnAmount;
            }
        
       
        return amt;

    }


}