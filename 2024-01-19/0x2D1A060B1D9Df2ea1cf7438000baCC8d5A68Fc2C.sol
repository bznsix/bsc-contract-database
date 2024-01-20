// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  function allowance(address owner, address spender) external view returns (uint256 remaining);
  function approve(address spender, uint256 value) external returns (bool success);
  function balanceOf(address owner) external view returns (uint256 balance);
  function decimals() external view returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external view returns (string memory tokenName);
  function symbol() external view returns (string memory tokenSymbol);
  function totalSupply() external view returns (uint256 totalTokensIssued);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}
interface VRFV2WrapperInterface {
  function lastRequestId() external view returns (uint256);
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}

abstract contract VRFV2WrapperConsumerBase {
  IERC20 internal immutable LINK;
  VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;
  /**
   * @param _link is the address of LinkToken
   * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _link, address _vrfV2Wrapper) {
    LINK = IERC20(_link);
    VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
  }
  /**
   * @dev Requests randomness from the VRF V2 wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2 request ID of the newly created randomness request.
   */
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords
  ) internal returns (uint256 requestId) {
    LINK.transferAndCall(
      address(VRF_V2_WRAPPER),
      VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
    );
    return VRF_V2_WRAPPER.lastRequestId();
  }
  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;
  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
    fulfillRandomWords(_requestId, _randomWords);
  }
}
contract VRFv2DirectFundingConsumer is
    VRFV2WrapperConsumerBase
{
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );
    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */
    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256 public lastRandomwords;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 150000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 1;

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0x721DFbc5Cfe53d32ab00A9bdFa605d3b8E1f3f42;

    constructor()
         VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {}
    function requestRandomWords() internal returns (uint256 requestId)
    {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }
    function fulfillRandomWords( uint256 _requestId, uint256[] memory _randomWords ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        lastRandomwords = _randomWords[0];
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }
    function getRequestStatus(uint256 _requestId) external view returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }
}

contract CoinFlip is VRFv2DirectFundingConsumer () {
    event Result(address indexed winer, address indexed looser, uint256 type_game);
        address internal _owner;        
        address public g_t_address = 0xC51c05B7eA1147a9c846136a6F64358Db4D6548e; //gaming_token_address 000000000000000000
        address public fee_address = 0x56CD37b5C7f5C1e713a151bA32ddCD2CF117c572;
        address public burn_address = 0x000000000000000000000000000000000000dEaD;
        uint256 public amount;
        uint256 public fee;   
        uint256 public burn_fee; 

        constructor( uint256 _amount,  uint256 _fee,  uint256 _burn_fee) {
            amount = _amount;
            fee = _fee;
            burn_fee = _burn_fee;
            _owner = msg.sender;
        }
        modifier onlyOwner() {
            require(_owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }
        struct Games{ address winner; address loser; uint256 outcome; }
        mapping(uint256 => Games) public historygames; 
        uint256 public lastgame;
       
        struct Status{ uint256 status; uint256 outcome;}
        mapping(address => Status) public status;

        uint256 public queue_1_last;
        uint256 public queue_1_first;
        struct Queue_1 { address gamer; bool status; }
        mapping(uint256 => Queue_1) public queue_1;

        uint256 public queue_2_last;
        uint256 public queue_2_first; 
        struct Queue_2 { address gamer; bool status;}
        mapping(uint256 => Queue_2) public queue_2;

        function sequence_1() external view returns(address[] memory) {
            uint256 length = queue_1_last - queue_1_first;
            address[] memory sequence_arr = new address[](length);
            for(uint i = 0; i < length; i++){        
                    sequence_arr[i] = queue_1[i + queue_1_first].gamer;               
            }
            return sequence_arr;
        }        
        function sequence_2() external view returns(address[] memory) {
            uint256 length = queue_2_last - queue_2_first;
            address[] memory sequence_arr = new address[](length);
            for(uint i = 0; i < length; i++){
                    sequence_arr[i] = queue_2[i + queue_2_first].gamer;               
            }
            return sequence_arr;
        }
        function game(uint outcome) public {
            require(0 < outcome && outcome < 3, ": Outcome out range");
            require(IERC20(g_t_address).allowance(msg.sender, address(this)) >= amount, ": Game token consumption not allowed");
            require(IERC20(g_t_address).balanceOf(msg.sender) >= amount, ": Your game token balance is insufficient");
            require(status[msg.sender].status != 3 , ": You are already in the queue");
            address this_gamer = msg.sender;
            status[this_gamer].outcome = outcome;
            // deposit
            transferFrom(this_gamer);
            // outcome == #1
            if (outcome == 1){
                //game immediately?
                if(queue_2[queue_2_first].status) {
                    //get random number from CHAINLINK 
                    requestRandomWords();
                    uint result = random() + 1;
                    address second_gamer =  queue_2[queue_2_first].gamer;
                    // msg.sender == winer?
                    if (result == outcome) {                     
                        transfer(this_gamer);                  
                        status[this_gamer].status = 1; //win
                        status[second_gamer].status = 2; //lose                      
                        historygames[lastgame].winner = this_gamer;
                        historygames[lastgame].loser = second_gamer;
                        emit Result(this_gamer, second_gamer, 1);
                    } else {
                        transfer(second_gamer);
                        status[this_gamer].status = 2; // lose
                        status[second_gamer].status = 1; // win
                      
                        historygames[lastgame].winner = second_gamer;
                        historygames[lastgame].loser = this_gamer;
                        emit Result(second_gamer, this_gamer, 1);
                    }                  
                    queue_2[queue_2_first].status = false;                   
                    queue_2_first++;
                    historygames[lastgame].outcome = result;
                    lastgame ++;
                //queuing: 
                } else {
                    queue_1[queue_1_last].status = true;
                    queue_1[queue_1_last].gamer = this_gamer;
                    queue_1_last++;
                    status[this_gamer].status = 3; // waiting
                }
            // outcome == #2        
            } else {                
                 //game immediately?    
                 if(queue_1[queue_1_first].status) {
                    //get random number from CHAINLINK 
                     requestRandomWords();
                    uint result = random() + 1; 
                    address second_gamer =  queue_1[queue_1_first].gamer;
                    // msg.sender == winer?
                    if (result == outcome) {
                        transfer(this_gamer);
                        status[this_gamer].status = 1; //win
                        status[second_gamer].status = 2; //lose
                        historygames[lastgame].winner = this_gamer;
                        historygames[lastgame].loser = second_gamer;
                         emit Result(this_gamer, second_gamer, 1);
                    } else {
                        transfer(second_gamer);
                        status[this_gamer].status = 2; // lose
                        status[second_gamer].status = 1; // win
                        historygames[lastgame].winner = second_gamer;
                        historygames[lastgame].loser = this_gamer;
                        emit Result(second_gamer, this_gamer, 1);
                    }
                    queue_1[queue_1_first].status = false;
                    queue_1_first++;
                    historygames[lastgame].outcome = result;
                    lastgame ++;
                //queuing: 
                } else {
                    queue_2[queue_2_last].status = true;
                    queue_2[queue_2_last].gamer = this_gamer;
                    queue_2_last++;
                    status[this_gamer].status = 3; // waiting
                }
            }
        }
        function transfer(address _to) internal {
             IERC20(g_t_address).transfer(_to, 2*amount - fee - burn_fee);
             IERC20(g_t_address).transfer(fee_address, fee);
             IERC20(g_t_address).transfer(burn_address, burn_fee);
        }
        function transferFrom(address _from) internal {
             IERC20(g_t_address).transferFrom(_from, address(this), amount);
        }
        function random() public view virtual returns(uint){       
            uint randomInt = lastRandomwords % 2;
            return randomInt;
        }
        function set_amount(uint256 _amount) public onlyOwner {
              amount = _amount;
        }
        function set_fee(uint256 _fee) public onlyOwner {
              fee = _fee;
        }
        function set_burn_fee(uint256 _burn_fee) public onlyOwner {
              burn_fee = _burn_fee;
        }
        function transfer_ownership(address  new_owner) public onlyOwner {
              _owner = new_owner;
        }        
        function set_fee_address(address _fee_address) public onlyOwner {
              fee_address = _fee_address;
        }
        function set_g_t_address(address _g_t_address) public onlyOwner {
              g_t_address = _g_t_address;
        }
        function withdrawLink() public onlyOwner{
            IERC20(linkAddress).transfer(msg.sender, IERC20(linkAddress).balanceOf(address(this)));
        }
}