/**
 *Submitted for verification at BscScan.com on 2021-03-06
*/

pragma solidity 0.6.12;

    // SPDX-License-Identifier: No License

    /**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
    library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    }

    /**
    * @dev Library for managing
    * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
    * types.
    *
    * Sets have the following properties:
    *
    * - Elements are added, removed, and checked for existence in constant time
    * (O(1)).
    * - Elements are enumerated in O(n). No guarantees are made on the ordering.
    *
    * ```
    * contract Example {
    *     // Add the library methods
    *     using EnumerableSet for EnumerableSet.AddressSet;
    *
    *     // Declare a set state variable
    *     EnumerableSet.AddressSet private mySet;
    * }
    * ```
    *
    * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
    * (`UintSet`) are supported.
    */
    library EnumerableSet {
        

        struct Set {
        
            bytes32[] _values;
    
            mapping (bytes32 => uint256) _indexes;
        }
    
        function _add(Set storage set, bytes32 value) private returns (bool) {
            if (!_contains(set, value)) {
                set._values.push(value);
                
                set._indexes[value] = set._values.length;
                return true;
            } else {
                return false;
            }
        }

        /**
        * @dev Removes a value from a set. O(1).
        *
        * Returns true if the value was removed from the set, that is if it was
        * present.
        */
        function _remove(Set storage set, bytes32 value) private returns (bool) {
            // We read and store the value's index to prevent multiple reads from the same storage slot
            uint256 valueIndex = set._indexes[value];

            if (valueIndex != 0) { // Equivalent to contains(set, value)
                

                uint256 toDeleteIndex = valueIndex - 1;
                uint256 lastIndex = set._values.length - 1;

            
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

                set._values.pop();

                delete set._indexes[value];

                return true;
            } else {
                return false;
            }
        }

        
        function _contains(Set storage set, bytes32 value) private view returns (bool) {
            return set._indexes[value] != 0;
        }

        
        function _length(Set storage set) private view returns (uint256) {
            return set._values.length;
        }

    
        function _at(Set storage set, uint256 index) private view returns (bytes32) {
            require(set._values.length > index, "EnumerableSet: index out of bounds");
            return set._values[index];
        }

        

        struct AddressSet {
            Set _inner;
        }
    
        function add(AddressSet storage set, address value) internal returns (bool) {
            return _add(set._inner, bytes32(uint256(value)));
        }

    
        function remove(AddressSet storage set, address value) internal returns (bool) {
            return _remove(set._inner, bytes32(uint256(value)));
        }

        
        function contains(AddressSet storage set, address value) internal view returns (bool) {
            return _contains(set._inner, bytes32(uint256(value)));
        }

    
        function length(AddressSet storage set) internal view returns (uint256) {
            return _length(set._inner);
        }
    
        function at(AddressSet storage set, uint256 index) internal view returns (address) {
            return address(uint256(_at(set._inner, index)));
        }


    
        struct UintSet {
            Set _inner;
        }

        
        function add(UintSet storage set, uint256 value) internal returns (bool) {
            return _add(set._inner, bytes32(value));
        }

    
        function remove(UintSet storage set, uint256 value) internal returns (bool) {
            return _remove(set._inner, bytes32(value));
        }

        
        function contains(UintSet storage set, uint256 value) internal view returns (bool) {
            return _contains(set._inner, bytes32(value));
        }

        
        function length(UintSet storage set) internal view returns (uint256) {
            return _length(set._inner);
        }

    
        function at(UintSet storage set, uint256 index) internal view returns (uint256) {
            return uint256(_at(set._inner, index));
        }
    }
    
    contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    }


    interface Token {
        function transferFrom(address, address, uint) external returns (bool);
        function transfer(address, uint) external returns (bool);
    }

    contract BSCPrediction is Ownable {
        using SafeMath for uint;
        using EnumerableSet for EnumerableSet.AddressSet;
        
    
        /*
        participanta[i] = [
            0 => user staked,
            1 => amount staked,
            2 => result time,
            3 => prediction time,
            4 => market pair,
            5 => value predicted at,
            6 => result value,
            7 => prediction type  0 => Down, 1 => up ,
            8 => result , 0 => Pending , 2 => Lost, 1 => Won, 3 => Withdrawn
        ]
        */

        // MTP token contract address
        address public tokenAddress = 0x305996A218f515932F62a5658504f847ABc3562a;
        // Lost token contract address
        address payable public constant lossPool = 0xCD1f4b06ef46D5B569caeD35ca236E9beD9E434D; 
        
    
        
        // mapping(address => uint[]) internal participants;
        
        struct Prediction {
            address payable user;
            uint betAmount;
            uint resultTime;
            uint betTime;
            uint marketPair;
            uint marketType;
            uint valuePredictedAt;
            uint valueResult;
            uint predictionType;
            uint result;       
            bool token;
            bool exists;
        }
        

        mapping(uint => Prediction)  predictions;
        
        mapping (address => uint) public totalEarnedTokens;
        mapping (address => uint) public totalEarnedBNB;
        mapping (address => uint) public totalClaimedTokens;
        mapping (address => uint) public totalClaimedBNB;
        mapping (address => uint256) public totalAvailableBNBRewards;
        mapping (address => uint) public totalAvailableTokenRewards;
        mapping (address => uint) public totalPoints;
        mapping (address => uint) public totalStakedToken;
        mapping (address => uint) public totalStakedBNB;
        event PredictionMade(address indexed user, uint matchid);
        event PointsEarned(address indexed user, uint indexed time ,  uint score);
    
        event RewardsTransferred(address indexed user, uint amount);
        event ResultDeclared(address indexed user, uint matchID);
        
        uint public payoutPercentage = 7500 ;
        uint public expresultime = 24 hours;
        uint public maximumToken = 5e18 ; 
        uint public minimumToken = 1e17 ; 
        uint public totalClaimedTokenRewards = 0;
        uint public totalClaimedBNBRewards = 0;
        
        uint public scoreAmtEq = 50 ;
     
        uint[] public matches;

    
    function getallmatches() view public  returns (uint[] memory){
        return matches;
    }
        
        function predictBnb(uint matchID , uint amountToPredict, uint resultTime, uint predictedtime, uint marketPair, uint valuePredictedAt, uint predictionType,uint marketType) payable public returns (uint)  {
            require(msg.value == amountToPredict, "Cannot predict with 0 Tokens");
            require(amountToPredict >= minimumToken && amountToPredict <= maximumToken, "Cannot predict with 0 Tokens");
            require(resultTime > predictedtime, "Cannot predict at the time of result");
            
            require(predictions[matchID].exists !=  true  , "Match already Exists" );
                        
            Prediction storage newprediction = predictions[matchID];
            newprediction.user =  msg.sender;
            newprediction.betAmount =  amountToPredict; 
            newprediction.resultTime =  resultTime ;
            newprediction.betTime =  predictedtime; 
            newprediction.marketPair =  marketPair ;
            newprediction.marketType =  marketType ;
            newprediction.valuePredictedAt =  valuePredictedAt ;
            newprediction.valueResult =  0 ;
            newprediction.predictionType =  predictionType ;
            newprediction.result =  0 ;
            newprediction.token =  false ;
            newprediction.exists =  true ;
            matches.push(matchID) ;

            totalPoints[msg.sender] = totalPoints[msg.sender].add(amountToPredict.mul(scoreAmtEq).div(1e18));
            emit PointsEarned(msg.sender, now , amountToPredict.mul(scoreAmtEq).div(1e18));

            totalStakedBNB[msg.sender] =  totalStakedBNB[msg.sender].add(amountToPredict) ;
            emit PredictionMade(msg.sender, matchID);

        }
        
         function predictToken(uint matchID , uint amountToPredict, uint resultTime, uint predictedtime, uint marketPair, uint valuePredictedAt, uint predictionType,uint marketType) public returns (uint)  {
            require(amountToPredict >= minimumToken && amountToPredict <= maximumToken, "Cannot predict with 0 Tokens");
            require(resultTime > predictedtime, "Cannot predict at the time of result");
            require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToPredict), "Insufficient Token Allowance");
            
            require(predictions[matchID].exists !=  true  , "Match already Exists" );
            
            

            Prediction storage newprediction = predictions[matchID];
            newprediction.user =  msg.sender;
            newprediction.betAmount =  amountToPredict; 
            newprediction.resultTime =  resultTime ;
            newprediction.betTime =  predictedtime; 
            newprediction.marketPair =  marketPair ;
            newprediction.marketType =  marketType ;
            newprediction.valuePredictedAt =  valuePredictedAt ;
            newprediction.valueResult =  0 ;
            newprediction.predictionType =  predictionType ;
            newprediction.result =  0 ;
            newprediction.token =  true ;
            newprediction.exists =  true ;
            matches.push(matchID) ;

            totalPoints[msg.sender] = totalPoints[msg.sender].add(amountToPredict.mul(scoreAmtEq).div(1e18));
            emit PointsEarned(msg.sender, now , amountToPredict.mul(scoreAmtEq).div(1e18));

            totalStakedToken[msg.sender] =  totalStakedToken[msg.sender].add(amountToPredict) ;
            emit PredictionMade(msg.sender, matchID);

        }

     
        
        function declareResult(uint curMarketValue , uint matchID  ) public  onlyOwner returns (bool)   {


                    Prediction storage eachparticipant = predictions[matchID];

                        if(eachparticipant.resultTime <= now && eachparticipant.result == 0 && curMarketValue > 0 ){

                            /* When User Predicted Up && Result is Up */
                                if(eachparticipant.valuePredictedAt  < curMarketValue && eachparticipant.predictionType  == 1  ){
                                    eachparticipant.result  = 1 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    uint reward = eachparticipant.betAmount.mul(payoutPercentage).div(1e4);

                                    if(eachparticipant.token == true){
                                         totalEarnedTokens[eachparticipant.user] = totalEarnedTokens[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    
                                    totalAvailableTokenRewards[eachparticipant.user] = totalAvailableTokenRewards[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    }
                                    else{
                                   totalEarnedBNB[eachparticipant.user] = totalEarnedBNB[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    
                                    totalAvailableBNBRewards[eachparticipant.user] = totalAvailableBNBRewards[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    }
                                 
                                }

                            /* When User Predicted Up && Result is Down */
                                if(eachparticipant.valuePredictedAt  > curMarketValue && eachparticipant.predictionType  == 1  ){
                                    eachparticipant.result  = 2 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    if(eachparticipant.token == true){
                                        Token(tokenAddress).transfer(lossPool, eachparticipant.betAmount);
                                    }
                                    else{
                                       lossPool.transfer(eachparticipant.betAmount);

                                    }

                                }

                            /* When User Predicted Down && Result is Up */
                                if(eachparticipant.valuePredictedAt  < curMarketValue && eachparticipant.predictionType  == 0  ){
                                    eachparticipant.result  = 2 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                       if(eachparticipant.token == true){
                                        Token(tokenAddress).transfer(lossPool, eachparticipant.betAmount);
                                    }
                                    else{
                                       lossPool.transfer(eachparticipant.betAmount);

                                    }

                                }

                            /* When User Predicted Down && Result is Down */
                                if(eachparticipant.valuePredictedAt  > curMarketValue && eachparticipant.predictionType  == 0  ){
                                    eachparticipant.result  = 1 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    uint reward = eachparticipant.betAmount.mul(payoutPercentage).div(1e4);

                                    if(eachparticipant.token == true){
                                    totalEarnedTokens[eachparticipant.user] = totalEarnedTokens[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    totalAvailableTokenRewards[eachparticipant.user] = totalAvailableTokenRewards[eachparticipant.user].add(eachparticipant.betAmount).add(reward);

                                     }
                                     else{
                                    totalEarnedBNB[eachparticipant.user] = totalEarnedBNB[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    totalAvailableBNBRewards[eachparticipant.user] = totalAvailableBNBRewards[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                     }


                                }
                        emit ResultDeclared(msg.sender, matchID);
                    
                }
                
            
                return true ;

            }
 


            function getmatchBasic(uint  _matchID ) view public returns (address , uint , uint , uint , uint , bool ) {
                        return (predictions[_matchID].user , predictions[_matchID].betAmount , predictions[_matchID].resultTime , predictions[_matchID].betTime , predictions[_matchID].marketPair , predictions[_matchID].token  );
            }

            function getmatchAdv(uint  _matchID ) view public returns (uint , uint , uint , uint , uint  , bool  ) {
                        return (predictions[_matchID].marketType , predictions[_matchID].valuePredictedAt, predictions[_matchID].valueResult, predictions[_matchID].predictionType , predictions[_matchID].result  , predictions[_matchID].exists );
            }

            
    

        function withdrawNotExecutedResult(uint  _matchID) 
            public 
            
            returns (bool) {
            
            if(predictions[_matchID].result == 0 && predictions[_matchID].user == msg.sender && now.sub(predictions[_matchID].resultTime) > expresultime){
                Prediction storage eachparticipant = predictions[_matchID];
                eachparticipant.result =  3 ;
                if(eachparticipant.token == true){
                Token(tokenAddress).transfer(predictions[_matchID].user, predictions[_matchID].betAmount);
                }
                else{
                predictions[_matchID].user.transfer(predictions[_matchID].betAmount);
                }
            }
            
            return true ;
        }

    function addContractTokenBalance(uint amount) public {
            require(Token(tokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
            
        }

         function addContractBNBBalance(uint amount) payable public {
            /* 
            Do Nothing
            */
        }

         function addTokenScore(uint  score, uint amount, address _holder) 
            public 
            onlyOwner
            returns (bool) {
             totalPoints[_holder] = totalPoints[_holder].add(score);
              totalStakedToken[_holder] = totalStakedToken[_holder].add(amount);
            
            return true ;
        }

        function addBNBScore(uint  score, uint amount, address _holder) 
            public 
            onlyOwner
            returns (bool) {
             totalPoints[_holder] = totalPoints[_holder].add(score);
              totalStakedBNB[_holder] = totalStakedBNB[_holder].add(amount);
            
            return true ;
        }

        function updateMaximum(uint  amount) 
            public 
            onlyOwner
            returns (bool) {
            maximumToken = amount;
            
            return true ;
        }

        function updateMinimum(uint  amount) 
            public 
            onlyOwner
            returns (bool) {
            minimumToken = amount;
            
            return true ;
        }

        

        function updatePayout(uint  percentage) 
            public 
            onlyOwner
            returns (bool) {
            payoutPercentage = percentage;
            
            return true ;
        }
        
        


    function updateToken(address  _token) 
            public 
            onlyOwner
            returns (bool) {
            tokenAddress = _token;
            
            return true ;
        }

    function updateScoreEq(uint  amteq) 
            public 
            onlyOwner
            returns (bool) {
            scoreAmtEq = amteq;
            
            return true ;
        }


    
    


         

            
        function claimToken() public {
            uint pendingDivs = totalAvailableTokenRewards[msg.sender];
            if (pendingDivs > 0 ) {
                require(Token(tokenAddress).transfer(msg.sender, pendingDivs), "Could not transfer tokens.");
                totalClaimedTokens[msg.sender] = totalClaimedTokens[msg.sender].add(pendingDivs);
                totalAvailableTokenRewards[msg.sender] = 0 ;
                totalClaimedTokenRewards = totalClaimedTokenRewards.add(pendingDivs);
                emit RewardsTransferred(msg.sender, pendingDivs);
            }
        }
        
        function claimBNB() public {
            uint256 pendingDivs = totalAvailableBNBRewards[msg.sender];
            if (pendingDivs > 0 ) {
                msg.sender.transfer(pendingDivs);
                totalClaimedBNB[msg.sender] = totalClaimedBNB[msg.sender].add(pendingDivs);
                totalAvailableBNBRewards[msg.sender] = 0 ;
                totalClaimedBNBRewards = totalClaimedBNBRewards.add(pendingDivs);
                emit RewardsTransferred(msg.sender, pendingDivs);
            }
        }
        
        
        function withdrawToken(uint _amount) public onlyOwner{
                Token(tokenAddress).transfer(msg.sender , _amount);
        }


        function withdrawBNB() public onlyOwner{
                msg.sender.transfer(address(this).balance);
            }
        
        
    

    }