//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WinOOWin {
    uint128 FEE;
    uint Deposit_Keeper;
    uint MIN_DEPOSIT = 100000000000000; //0.0001

    address  HOLDER ;
    address  OWNER;
    address  ORACLE;
    address[] _p_1;

    bool withdraw_able;

    string private ID_OFN;

    mapping(uint => uint) WithAble;
    mapping(uint =>  mapping(uint => bool) ) Commitment;
    mapping(uint =>  mapping(uint => bool) ) DrawOver;
    mapping(uint =>  mapping(uint => uint)) CommitmentTimestampExpiration;
    mapping(uint => mapping(uint => mapping(address => uint))) Pool;
    mapping(uint => mapping(uint => mapping(address => uint))) PoolWinner;
    event Deposit(uint256 commitment, uint timestamp);
    event Withdraw(uint256 commitment, uint timestamp);

    modifier onlyOwner() {
        require(
            msg.sender == OWNER,
            "Only the owner is allowed to make this request"
        );
        _;
    }
    modifier onlyOracle() {
        require(
            msg.sender == ORACLE,
            "Only the owner is allowed to make this request"
        );
        _;
    }

    constructor(string memory _s,address _h, address _oracle) {
        withdraw_able = false;
        FEE = 1000; //10%
        ID_OFN = _s;
        ORACLE = _oracle;
        HOLDER = _h;
        OWNER = msg.sender;
    }

    function depozit_p_1(
        uint256 _commitment,
        uint _amount,
        uint _p
    ) public payable {
        if (Commitment[_commitment][_p] == false) {
            revert("unvalidated Commitment");
        }
        if (CommitmentTimestampExpiration[_commitment][_p]  < block.timestamp) {
            revert("unvalidated time");
        }

        if (msg.value < _amount) {
            revert("unvalidated _amount");
        }
        if (Pool[_commitment][_p][msg.sender] > 1) {
            revert("You already joined");
        }
        if (MIN_DEPOSIT > _amount) {
            revert("Less than min");
        }
        withdraw_able = true;

        uint ParticipationFEE = (_amount * FEE) / 10000;
        uint Total = _amount - ParticipationFEE;

        (bool _s_1, ) = payable(HOLDER).call{value: ParticipationFEE}("");

        Deposit_Keeper += _amount;
        Pool[_commitment][_p][msg.sender] = Total;

        withdraw_able = false;
        emit Deposit(_commitment, block.timestamp);
    }

    function depozit_p_1ByOracle(
        uint256 _commitment,
        uint _amount,
        address receipt,
        bytes memory otp,
        uint _p
    ) public payable onlyOracle {
        if (!signatureCheker(receipt, otp)) {
            revert("It is not valid signature ! ");
        }
        if (Commitment[_commitment][_p]  == false) {
            revert("unvalidated Commitment");
        }
        if (CommitmentTimestampExpiration[_commitment][_p]  < block.timestamp) {
            revert("unvalidated time");
        }

        if (msg.value < _amount) {
            revert("unvalidated _amount");
        }
        if (Pool[_commitment][_p][receipt] > 1) {
            revert("You already joined");
        }
        if (MIN_DEPOSIT > _amount) {
            revert("Less than min");
        }
        withdraw_able = true;

        uint ParticipationFEE = (_amount * FEE) / 10000;
        uint Total = _amount - ParticipationFEE;

        (bool _s_1, ) = payable(HOLDER).call{value: ParticipationFEE}("");

        Deposit_Keeper += _amount;
        Pool[_commitment][_p][receipt] = Total;

        withdraw_able = false;
        emit Deposit(_commitment, block.timestamp);
    }

    function getAmountPoolUser(
        address _ask,
        uint256 _commitment,
        uint _p
    ) external view returns (uint) {
        return Pool[_commitment][_p][_ask];
    }

    function Mywithdraw(
        address receipt,
        bytes memory otp,
        uint256 _commitment,
        uint _p
    ) external {
        if (withdraw_able) {
            revert("You are not Allowed to make this request");
        }
        withdraw_able = true;
        if (DrawOver[_commitment][_p]  == false) {
            revert("Commitment is duplicate");
        }
        if (Commitment[_commitment][_p]  == false) {
            revert("Commitment is unvalidated");
        }

        if (!signatureCheker(receipt, otp)) {
            revert("It is not valid signature ! ");
        }
        if (PoolWinner[_commitment][_p][msg.sender] <= 0) {
            revert("It is not valid number ! ");
        }
        if (PoolWinner[_commitment][_p][msg.sender] > address(this).balance) {
            revert("It is not valid number ! ");
        }

        (bool _s_1, ) = payable(receipt).call{
            value: PoolWinner[_commitment][_p][msg.sender]
        }("");
        delete PoolWinner[_commitment][_p][msg.sender];

        withdraw_able = false;
        emit Withdraw(_commitment, block.timestamp);
    }

    function WhitdrawByOracle(
       address siginer,
        address receipt,
        bytes memory otp, //
        uint256 _Gasfee,
        uint256 _commitment,
        uint _p
    ) external onlyOracle {
        if (withdraw_able) {
            revert("You are not Allowed to make this request");
        }
        withdraw_able = true;
        if (DrawOver[_commitment][_p] == false) {
            revert("Commitment is duplicate");
        }
        if (Commitment[_commitment][_p] == false) {
            revert("Commitment is unvalidated");
        }
        if (PoolWinner[_commitment][_p][siginer] <= 0) {
            revert("It is not valid number ! ");
        }
        if (!signatureCheker(receipt, otp)) {
            revert("It is not valid signature ! ");
        }
        if (PoolWinner[_commitment][_p][siginer] > address(this).balance) {
            revert("It is not valid number ! ");
        }

        uint receipt_recive = PoolWinner[_commitment][_p][siginer] - _Gasfee;
        delete PoolWinner[_commitment][_p][siginer];
        (bool _s_1, ) = payable(receipt).call{value: receipt_recive}("");
        (bool _s_2, ) = payable(msg.sender).call{value: _Gasfee}("");

        withdraw_able = false;

        emit Withdraw(_commitment, block.timestamp);
    }

    function setPutFee(uint128 _commision) public onlyOwner returns (bool) {
        if (_commision > 4000) //~ 20%
        {
            revert("The number of fee can't be greater than 10%");
        }
        if (_commision < 50) //~ 0.5%
        {
            revert("The number of fee can't be lower than 0.5%");
        }
        FEE = _commision;
        return true;
    }

    function updateSlot(uint256 _c,uint _p) external onlyOracle {
        // if (!Commitment[_c][_p] ) {
        //     revert("Commitment is duplicate");
        // }
        // if (!DrawOver[_c][_p] ) {
        //     revert("Commitment is duplicate");
        // }
        if( CommitmentTimestampExpiration[_c][_p] > block.timestamp){
              revert("Time Expire is still active ");
        }

        Commitment[_c][_p]  = true;
        DrawOver[_c][_p]  = false;
        CommitmentTimestampExpiration[_c][_p]  = block.timestamp + 23 hours;
    }

        function creatNewSlot(uint256 _c,uint _p) external onlyOracle {
        if (Commitment[_c][_p] ) {
            revert("Commitment is duplicate");
        }
        if (DrawOver[_c][_p] ) {
            revert("Commitment is duplicate");
        }

        Commitment[_c][_p]  = true;
        DrawOver[_c] [_p] = false;
        CommitmentTimestampExpiration[_c][_p]  = block.timestamp + 23 hours;
    }

    function InjectionWinner(
        uint[] memory _amounts,
        address[] memory _addresses,
        uint256 _c,
        uint _p
    ) external onlyOracle {
        if (DrawOver[_c][_p]) {
            revert("Commitment is duplicate");
        }
        if (Commitment[_c][_p] == false) {
            revert("Commitment is unvalidated");
        }

        for (uint i = 0; i < _addresses.length; i++) {
            if (_addresses[i] != address(0)) {
                PoolWinner[_c][_p][_addresses[i]] = _amounts[i];
            }
        }

        DrawOver[_c][_p] = true;
    }

    function getMessageHash(address adr) public view returns (bytes32) {
        return keccak256(abi.encodePacked(ID_OFN, adr));
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function signatureCheker(
        address adr,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 messageHash = getMessageHash(adr);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == msg.sender;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = Signature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function Signature(
        bytes memory sig
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))

            s := mload(add(sig, 64))

            v := byte(0, mload(add(sig, 96)))
        }
    }

    function Emergency() external {
        if (msg.sender != HOLDER) {
            revert();
        }

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
    }

    function encode(
        address _account,
        string memory _t
    ) public pure returns (bytes memory) {
        return (abi.encode(_account, _t));
    }

    function decode(
        bytes memory data
    ) public pure returns (address _account, string memory _number) {
        (_account, _number) = abi.decode(data, (address, string));
    }

    function message(
        address to,
        bytes memory _f
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked("WINOOWIN_2024_", to, _f));
    }

    function signatureOracel(
        address siginer,
        address to,
        bytes[2] memory signature
    ) internal view returns (bool) {
        bytes32 messageHash = message(to, signature[1]);

        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        (address _account, ) = decode(signature[1]);
        if (_account != to) {
            revert("It is not address! ");
        }

        return (recoverSigner(ethSignedMessageHash, signature[0]) == siginer);
    }
}