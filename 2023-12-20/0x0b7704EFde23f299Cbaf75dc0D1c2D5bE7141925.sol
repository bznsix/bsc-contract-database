/**
 *Submitted for verification at BscScan.com on 2023-11-17
*/

/**
 *Submitted for verification at basescan.org on 2023-08-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
contract Presale is ReentrancyGuard{
    uint256 public startTime;
    uint256 public endTime;
    IBEP20 public saleToken;
    mapping(address => uint256) public commitments;
    mapping(address => uint256) public missedEmissions;
    uint256 public totalCommitments;
    address public owner;
    uint256 public emissionPerEther;
    uint256 private minValue;
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        address _saleToken,
        uint256 _minValue
    ){
        require(
            _startTime >= block.timestamp,
            "Start time must be in the future."
        );
        require(
            _endTime > _startTime,
            "End time must be greater than start time."
        );
        startTime = _startTime;
        endTime = _endTime;
        saleToken = IBEP20(_saleToken);
        owner = msg.sender;
        emissionPerEther = 1000000*(10**18);
        minValue = _minValue;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function calculateEmission(uint256 value) internal view returns (uint256) {
        return (value * emissionPerEther) / 10 ** 18;
    }
    function commit() external payable nonReentrant returns (bool) {
        require(block.timestamp >= startTime && block.timestamp <= endTime, 'Invalid time for buying');
        require(msg.value >= minValue, "Min 0.01 ETH");
        commitments[msg.sender] += msg.value;
        missedEmissions[msg.sender] += calculateEmission(msg.value);
        totalCommitments += msg.value;
        return true;
    }
    function claim() external {
        require(missedEmissions[msg.sender] > 0, "You have not deposited any Token.");
        require(block.timestamp > endTime, "Invalid time for Claiming.");
        saleToken.transfer(msg.sender, missedEmissions[msg.sender]);
        missedEmissions[msg.sender] = 0;
    }
    function changeSaleTimes(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_startTime > 0 || _endTime > 0, 'Invalid parameters');
        if (_startTime > 0) {
            require(block.timestamp < _startTime, 'Sale time in past');
            startTime = _startTime;
        }
        if (_endTime > 0) {
            require(_endTime > startTime, 'Invalid endTime');
            endTime = _endTime;
        }
    }
    function changeowner(address _newowner) external onlyOwner{
        owner = _newowner;
    }
    function changesaleToken(address _newToken) external onlyOwner{
        saleToken = IBEP20(_newToken);
    }
    function changeemissionPerEther(uint256 amount) external onlyOwner{
        emissionPerEther = amount;
    }
    function changeMinvalue(uint256 _minValue) external onlyOwner{
        minValue = _minValue;
    }
    function withdrawBNB() external onlyOwner{
        (bool success, ) = owner.call{
                value: address(this).balance
            }("");
            require(success, "Failed to transfer ether");
    }
    function withdrawToken() external onlyOwner{
        saleToken.transfer(owner, saleToken.balanceOf(address(this)));
    }
    receive() external payable {}
}