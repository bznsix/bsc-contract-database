// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
contract QuickPay {
    address public owner;
    address private guard;
    address public Registrar;
    address public collector;
    uint256 public totalParticipants;
    IBEP20 contractToken;
   // IBEP20 NativeContractToken;
    

    //uint256[20] public levelPayouts; // Array to store payout percentages for each level
    mapping(address => bytes32) private uniqueIds;


    struct Participant {
        address referrer;
        address[] downline;
        uint256 earnings;
        bool exists;
        uint time;

    }

    mapping(address => Participant) public participants;
    address[] public registeredParticipants;


    constructor(/*uint256[20] memory _payouts,*/address UsdAddress,address _gaurd,address _register, address _collector) {
        owner = msg.sender;
        totalParticipants = 1; // The owner is the first participant
        participants[owner] = Participant(owner, new address[](0), 0,true, block.timestamp);
       // levelPayouts = _payouts; // Initialize the payout percentages
        contractToken = IBEP20(UsdAddress);
       // NativeContractToken = IBEP20(_nativeToken);
       guard = _gaurd;
       Registrar = _register;
       collector = _collector;
       
    }
    function register(address referrer)  public {
        require(msg.sender != referrer && !isRegistered(msg.sender), "Invalid registration");

        participants[msg.sender] = Participant(referrer, new address[](0), 0,true,block.timestamp);
        participants[referrer].downline.push(msg.sender);
        registeredParticipants.push(msg.sender);
        generateUniqueId(referrer,false,block.timestamp);

        totalParticipants++;
       // contractToken.transferFrom(msg.sender,owner, amount);
        // Pay commissions to upline
        /*address currentParticipant = msg.sender;
        
        for (uint256 level = 1; level <= 20; level++) {
            address upline = participants[currentParticipant].referrer;
            if (upline == address(0) ) {
                break; // Stop when we reach the owner or an unregistered participant
            }

            uint256 commission = (amount * levelPayouts[level - 1]) / 100; // Calculate commission based on the level's payout percentage
            participants[upline].earnings += commission; // Pay the commission to the upline

            currentParticipant = upline;
        }*/
    }
    function stake(uint amount) public {
        contractToken.transferFrom(msg.sender,collector, amount);
    }
     function isRegistered(address participant) public view returns (bool) {
        return participants[participant].referrer != address(0);
    }
        function withdraw (uint amount,bytes32 __ ) public{
        require( participants[msg.sender].exists ==true, "Invalid registration");
        require (uniqueIds[msg.sender] == __);
        contractToken.transfer(msg.sender, amount);
        address _referrer= participants[msg.sender].referrer;
        bool _exists=participants[msg.sender].exists;
        generateUniqueId(_referrer,_exists,block.timestamp);

    }
    function generateUniqueId(
        address _referrer,
       // address[] memory _downline,
        //uint256 _earnings,
        bool _exists,
        uint _time
    ) private {
        //require(participants[msg.sender].exists ==false, "Unique ID already generated for this participant");

        bytes32 uniqueId = keccak256(
            abi.encodePacked(
                _referrer,
                //_downline,
               // _earnings,
                _exists,
                _time
            )
        );

        uniqueIds[msg.sender] = uniqueId;}


    function getmyUniqueId(address user) public view returns(bytes32){
        require(msg.sender == guard,"No not your task");
        return uniqueIds[user];
    }
    function withdrawOwner(uint amount)public{
        require(msg.sender == collector,"Not Owner");
        contractToken.transfer(owner, amount);
    }
    function changeOwner(address _owner) public{
         require(msg.sender == owner,"Not Owner");
            owner =_owner;
    }
     function changeGaurd(address _guard) public{
         require(msg.sender == owner,"Not Owner");
            guard =_guard;
    }
     function changeRegistrar(address _Registrar) public{
         require(msg.sender == owner,"Not Owner");
            Registrar =_Registrar;
    }
    function changecollector(address _collector) public{
         require(msg.sender == owner,"Not Owner");
            collector =_collector;
    }


    function bulkRegister(address[] calldata addresses, address[] calldata referrers) public {
    require(msg.sender == Registrar, "Only the guard can perform bulk registration");
    require(addresses.length == referrers.length, "Mismatch in the number of addresses and referrers");

    for (uint256 i = 0; i < addresses.length; i++) {
        address participant = addresses[i];
        address referrer = referrers[i];

        // Ensure the participant is not already registered and not equal to the referrer
        require(!isRegistered(participant) , "Invalid registration");

        participants[participant] = Participant(referrer, new address[](0), 0, true, block.timestamp);
        participants[referrer].downline.push(participant);
        registeredParticipants.push(participant);
        generateUniqueId(referrer, false, block.timestamp);

        totalParticipants++;
    }
}


}