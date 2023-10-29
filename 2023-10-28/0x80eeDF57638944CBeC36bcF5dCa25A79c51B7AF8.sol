// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.17;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract $ES_Voting is Ownable{
    // create a struct template for each of the initiatives
    struct Initiative {
        uint256 id;
        string initiative;
        uint256 numberOfVotes;
    }

    // list of all the initiatives
    Initiative[] public initiatives;

    // this is the owner's address
    address public _owner;

    // token used to montior voters level
    address public voteToken;

    // map of voter addresses
    mapping(address => bool) public voters;

    // array of voters
    address [] public listOfVoters;

    // create voting seesion start and end
    uint256 public votingStart;
    uint256 public votingEnd;

    // create voting status
    bool public votingStarted;

    // Define an enum for the voting options
    enum VotingOption { Zero, One, Two, Three, Four, Five }

    // modifers
    modifier votingOnGoing() {
        require(votingStarted, "No voting yet");
        _;
    }

    // create constructor
    constructor(address _voteToken) {
        voteToken = _voteToken;
        _owner = msg.sender;
    }

    //functions
    //create a vote session
    function startVoting(string[] memory _initiatives, uint256 _votingDuration) public onlyOwner {
        require(votingStarted == false, "Voting is currently active");
        delete initiatives;
        resetAllVoterStatus();

        for(uint256 i = 0; i < _initiatives.length; i++) {
            initiatives.push(
                Initiative({id: i, initiative: _initiatives[i], numberOfVotes: 0})
            );
        }
        votingStarted = true;
        votingStart = block.timestamp;
        votingEnd = block.timestamp + (_votingDuration * 1 minutes);
    }

    // to add a new initiative
    function addInitiative(string memory _initiative) public onlyOwner votingOnGoing {
        require(checkVotingPeriod(), "Voting has ended");
        initiatives.push(
            Initiative({id: initiatives.length, initiative: _initiative, numberOfVotes: 0})
        );
    }

    // check voter status
    function checkVoterStatus(address _voter) public view votingOnGoing returns (bool) {
        if(voters[_voter] == true){
            return true;
        }
        return false;
    }

    function getVoteTokenBalance(address account) public view returns (uint256 _balance){
        _balance = IERC20(voteToken).balanceOf(account);
        return (_balance);
    }

    //vote function
    function vote(uint256 _id) public votingOnGoing {
        require(checkVotingPeriod(), "Voting has ended");
        require(!voters[msg.sender], "You already voted!");
        uint256 balance = getVoteTokenBalance(msg.sender);

        VotingOption voteValue;

        if (balance >= 17296695 * 10**18) {
            voteValue = VotingOption.Five;
        } else if (balance >= 8648347 * 10**18) {
            voteValue = VotingOption.Four;
        } else if (balance >= 4324173 * 10**18) {
            voteValue = VotingOption.Three;
        } else if (balance >= 2162086 * 10**18) {
            voteValue = VotingOption.Two;
        } else if (balance >= 864834 * 10**18) {
            voteValue = VotingOption.One;
        } else {
            voteValue = VotingOption.Zero;
        }

        // Update the numberOfVotes based on the voteValue
        initiatives[_id].numberOfVotes += uint8(voteValue);

        // Mark the sender as a voter and add them to the list
        voters[msg.sender] = true;
        listOfVoters.push(msg.sender);
    }

    // get number of votes
    function retrieveVotes() public view returns (Initiative[] memory) {
        return initiatives;
    }

    function retrieveVoters() public view returns (address[] memory) {
        return listOfVoters;
    }

    // view voting time
    function votingTimer() public view votingOnGoing returns(uint256) {
        if(block.timestamp >= votingEnd){
            return 0;
        }
        return (votingEnd - block.timestamp);
    }

    // check if voting period is still ongoing
    function checkVotingPeriod() public returns (bool) {
        if(votingTimer() > 0){
            return true;
        }
        votingStarted = false;
        return false;
    }

    // reset all voters status
    function resetAllVoterStatus() public onlyOwner {
        for(uint256 i = 0; i < listOfVoters.length; i++){
            voters[listOfVoters[i]] = false;
        }
        delete listOfVoters;
    }

    function setVoteToken(address token) public onlyOwner {
        require(token != address(0), "Can't Set Zero Address");
        voteToken = token;
    }

     //Transfers ownership of the contract to a new account (`newOwner`).
     //Can only be called by the current owner.
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //utility extrasa
    //get stuck tokens ftom contract
    function rescueToken(address tokenAddress, address to) external onlyOwner returns (bool success) {
    	uint256 _contractBalance = IERC20(tokenAddress).balanceOf(address(this));

        return IERC20(tokenAddress).transfer(to, _contractBalance);
    }

    //gets stuck bnb from contract
    function rescueBNB(uint256 amount) external onlyOwner{
    	payable(msg.sender).transfer(amount);
    }
}