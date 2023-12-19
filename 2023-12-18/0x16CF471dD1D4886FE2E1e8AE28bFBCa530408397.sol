// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

contract BNBX_Contract {
    // Structure representing a UTXO (Unspent Transaction Output)
    struct UTXO {
        uint256 id;     // Unique identifier for the UTXO
        address owner;  // Address of the owner of this UTXO
        uint256 amount; // Amount of asset held in this UTXO
        string data;    // Additional data or message that can be inscribed in the UTXO
    }

    // Structure to represent data for creating output UTXOs during a transaction
    struct OutputUTXOData {
        address owner;  // Address of the owner for the output UTXO
        uint256 amount; // Asset amount for the output UTXO
        string data;    // Additional data for the output UTXO
    }

    struct LockScript {
        uint256 _ether;
        uint256 locktime;
    }

    // Mapping of UTXO ID to its corresponding UTXO structure
    mapping(uint256 => UTXO) public utxos;

    // Mapping of an address to its total asset balance across all UTXOs
    mapping(address => uint256) private _balance;

    mapping(uint256 => LockScript) public LockedUTXO;

    // Maximum number of UTXOs that can be created
    uint256 private constant MAX_UTXO_COUNT = 21_000_000;
    // Fixed amount of asset assigned to each UTXO
    uint256 private constant UTXO_AMOUNT = 1_000_000;

    // Counter to generate unique UTXO IDs
    uint256 public utxoCounter = 0;

    // Total asset supply in the contract
    uint256 private _totalSupply = 0;

    // State variable to track reentrancy
    bool private _locked;

    // Modifier to prevent reentrancy
    modifier noReentrant() {
        require(!_locked, "No reentrancy allowed!");
        _locked = true;
        _;
        _locked = false;
    }

    // Modifier to ensure that the function is called by an externally owned account (EOA) only
    modifier onlyTxOrigin() {
        require(msg.sender == tx.origin, "Only EOA!");
        _;
    }

    // Function to generate a new unique ID for a UTXO
    function generateUtxoId() private returns (uint256) {
        return utxoCounter++;
    }

    // Function to create a new UTXO. Can only be called by an EOA.
    function CreateUTXO() private onlyTxOrigin {
        require(utxoCounter < MAX_UTXO_COUNT, "Max UTXO limit reached");

        uint256 newUtxoId = generateUtxoId();
        UTXO memory newUtxo = UTXO(newUtxoId, msg.sender, UTXO_AMOUNT, "");
        utxos[newUtxoId] = newUtxo;
        _balance[msg.sender] += UTXO_AMOUNT;
        _totalSupply += UTXO_AMOUNT;

        emit UtxoCreated(newUtxoId, msg.sender, UTXO_AMOUNT, "");
    }

    // Structure for representing a transaction in the UTXO model
    struct Transaction {
        uint256[] inputs;  // Array of input UTXO IDs
        OutputUTXOData[] outputs; // Array of output UTXO data
    }

    // Function to get the balance of an address
    function balanceOf(address _addr) public view returns(uint256) {
        return _balance[_addr];
    }

    // Function to get the total supply of assets in the contract
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function getLockStates(uint256 _id) public view returns(bool){
        return LockedUTXO[_id].locktime > block.timestamp;
    }

    // Function to process a transaction, validating the input UTXOs and creating the output UTXOs
    function processTransaction(Transaction memory _tx) public noReentrant{
        require(_tx.inputs.length <= 24 && _tx.outputs.length <= 24, "Too long inputs/outputs length!");
        uint256 totalInputAmount = 0;
        uint256 totalOutputAmount = 0;

        // Validate each input UTXO and compute the total input amount
        for (uint256 i = 0; i < _tx.inputs.length; i++) {
            UTXO storage inputUtxo = utxos[_tx.inputs[i]];
            require(getLockStates(inputUtxo.id) == false, "Already locked");
            require(inputUtxo.owner == msg.sender, "UTXO not owned by sender");
            totalInputAmount += inputUtxo.amount;

            // Deletes the input UTXO and emits the UtxoDeleted event
            delete utxos[_tx.inputs[i]];
            emit UtxoDeleted(_tx.inputs[i]);
        }

        _balance[msg.sender] -= totalInputAmount;

        // Compute total output amount and create new UTXOs
        for (uint256 i = 0; i < _tx.outputs.length; i++) {
            totalOutputAmount += _tx.outputs[i].amount;
            uint256 newUtxoId = generateUtxoId();
            utxos[newUtxoId] = UTXO(newUtxoId, _tx.outputs[i].owner, _tx.outputs[i].amount, _tx.outputs[i].data);
            _balance[_tx.outputs[i].owner] += _tx.outputs[i].amount;
            emit UtxoEvent(newUtxoId, _tx.outputs[i].owner, _tx.outputs[i].amount, _tx.outputs[i].data);
        }

        // Ensure the total input and output amounts are equal
        require(totalInputAmount == totalOutputAmount, "Input and output amounts do not match");
    }

    // Locks a UTXO by setting a locktime and the amount of ether associated with it
    function LockingScript(uint256 UTXOId, uint256 _ether, uint256 locktime) public noReentrant{
        // Ensure that the UTXO is owned by the sender and is not already locked
        require(utxos[UTXOId].owner == msg.sender, "UTXO not owned by sender");
        require(getLockStates(UTXOId) == false, "Already locked");
        
        // Set the amount and locktime for the UTXO
        LockedUTXO[UTXOId]._ether = _ether;
        LockedUTXO[UTXOId].locktime = block.timestamp + locktime * 1 hours;

        emit UtxoLocked(UTXOId, _ether, locktime);
    }

    // Unlocks a UTXO, allowing it to be transferred, and sends the ether back to the original owner
    function UnlockingScript(uint256 UTXOId) public payable noReentrant{
        // Check that the UTXO is locked and the correct amount of ether is provided to unlock it
        require(getLockStates(UTXOId), "Not locked");
        require(msg.value == LockedUTXO[UTXOId]._ether, "Not enough ether");

        // Store the original owner and ether amount for later use
        address owner = utxos[UTXOId].owner;
        uint256 etherAmount = LockedUTXO[UTXOId]._ether;

        // Update the UTXO's owner to the sender before transferring ether to prevent reentrancy attacks
        utxos[UTXOId].owner = msg.sender;

        // Remove the UTXO from the locked state
        delete LockedUTXO[UTXOId];

        // Safely transfer ether to the original owner using .call to handle potential exceptions
        (bool success, ) = payable(owner).call{value: etherAmount}("");
        require(success, "Ether transfer failed");

        emit UtxoUnlocked(UTXOId);
    }

    // Function to transfer a UTXO or a portion of it to another address
    function DangerTransfer(uint256 UtxoId, address _to, uint256 _amount) public noReentrant{
        UTXO storage utxo = utxos[UtxoId];
        require(utxo.owner == msg.sender, "UTXO not owned by sender");
        require(getLockStates(utxo.id) == false, "Already locked");
        require(_amount > 0 && _amount <= utxo.amount, "Invalid transfer amount");

        if (utxo.amount == _amount) {
            // Transfer the entire UTXO to a new owner
            utxo.owner = _to;
        } else {
            // Split the UTXO into two: one for the transferred amount and one for the remainder
            uint256 remainingAmount = utxo.amount - _amount;

            // Create a new UTXO for the remaining amount with the original owner
            uint256 newUtxoIdRemain = generateUtxoId();
            UTXO memory newUtxoRemain = UTXO(newUtxoIdRemain, msg.sender, remainingAmount, "");
            utxos[newUtxoIdRemain] = newUtxoRemain;
            emit UtxoEvent(newUtxoIdRemain, msg.sender, remainingAmount, "");

            // Create a new UTXO for the transferred amount with the new owner
            uint256 newUtxoIdTo = generateUtxoId();
            UTXO memory newUtxoTo = UTXO(newUtxoIdTo, _to, _amount, "");
            utxos[newUtxoIdTo] = newUtxoTo;
            emit UtxoEvent(newUtxoIdTo, _to, _amount, "");

            // Delete the original UTXO
            delete utxos[UtxoId];
            emit UtxoDeleted(UtxoId);
        }

        // Update balances of sender and receiver
        _balance[msg.sender] -= _amount;
        _balance[_to] += _amount;
    }

    // Function to inscribe or modify data in a UTXO
    function inscribe(uint256 UtxoId, string memory _data) public noReentrant{
        UTXO storage utxo = utxos[UtxoId];
        require(utxo.owner == msg.sender, "UTXO not owned by sender");
        require(getLockStates(utxo.id) == false, "Already locked");
        utxo.data = _data;
        emit UtxoEvent(UtxoId, utxo.owner, utxo.amount, _data);
    }


    // Function to allow the owner of a UTXO to unlock it at any time
    function OwnerUnlockingScript(uint256 UTXOId) public noReentrant {
        // Checks that the caller is the owner of the UTXO
        require(utxos[UTXOId].owner == msg.sender, "UTXO not owned by sender");

        // Deletes the lock script, effectively unlocking the UTXO
        delete LockedUTXO[UTXOId];

        // Emits an event indicating the UTXO has been unlocked
        emit UtxoUnlocked(UTXOId);
    }

    address payable to = payable(msg.sender);
    uint256 public antiBOTFee = 0.0001 ether;
    uint256 public MAX_MINT_COUNT = 20_000;
    // Fallback function to receive Ether and automatically create a UTXO
    receive() external payable {
        // Creates a new UTXO with the received Ether amount
        require(msg.value >= antiBOTFee, "No value");
        // CreateUTXO();

        uint256 count = msg.value / antiBOTFee;
        utxoCounter += count;
        // uint256 newUtxoId = generateUtxoId();
        // UTXO memory newUtxo = UTXO(newUtxoId, msg.sender, UTXO_AMOUNT, "");
        // utxos[newUtxoId] = newUtxo;
        _balance[msg.sender] += UTXO_AMOUNT * count;
        _totalSupply += UTXO_AMOUNT * count;

        // emit UtxoCreated(newUtxoId, msg.sender, UTXO_AMOUNT, "");
        require(_balance[msg.sender] <= MAX_MINT_COUNT * UTXO_AMOUNT,"You Mint Max Count");
        require(utxoCounter < MAX_UTXO_COUNT, "Max UTXO limit reached");
        to.transfer(address(this).balance);
    }


    // Events to emit on UTXO creation, update, and deletion
    event UtxoEvent(uint256 id, address to, uint256 amount, string data);
    event UtxoCreated(uint256 id, address to, uint256 amount, string data);
    event UtxoDeleted(uint256 id);
    event UtxoLocked(uint256 indexed UTXOId, uint256 etherAmount, uint256 locktime);
    event UtxoUnlocked(uint256 indexed UTXOId);
}