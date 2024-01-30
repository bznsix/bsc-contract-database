//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Garant_V1_Proxy {

    constructor(address imp) {
        owner = payable(msg.sender);                        //set the contract owner
        thisContract = address(this);                       //set the address of this contract
        implementation = imp;
    }

    address payable public owner;                           //contract owner address
    address public thisContract;                            //the address of this contract
    address public admin;                                   //contract administrator's address
    uint public commissionFee;                              //service fee from each transaction. max 100 00%. 2 decimals
    uint public guarantorRegPrice;                          //guarantor registration price
    uint private commissionUSDT;                            //commission earned by service
    uint public totalUsers;                                 //total users
    uint public totalGuarantors;                            //total guarantors
    uint public totalVolume;                                //total volume of deals

    address public addressUsdt = 0x55d398326f99059fF775485246999027B3197955; //usdt contract in BSC
    address public implementation;

    Deal[] public Deals;                                    //list of all deals with their IDs
    DealFee[] public DealsFee;
    mapping(address => userInfo) public Users;              //all users and their state
    mapping(address => Guarantor) public Guarantors;        //all guarantors and their state

    //user state
    struct userInfo {
        uint registered;            //date of registration
        uint balance;               //user balance in usdt. 6 decimals
        uint good;                  //total deals without dispute
        uint dispute;               //total deals with dispute
        uint volume;                //total deal volume. 6 decimals
        string info;                //string to store the contact, etc.
        uint[] allDeals;
        uint[] active;
        uint[] archive;
        uint[] canceled;
    }

    //deal state
    struct Deal {
        bool accepted;              //if the deal is accepted
        bool deposit;               //buyer deposited usdt
        address buyerAddr;          //buyer address
        address sellerAddr;         //seller address
        address creatorDeal;        //deal creator address
        bool guarantor;             //whether there is a guarantor
        bool guarantAccept;         //guarantor has accepted the deal
        address guarantAddr;        //guarantor address
        bool dispute;               //whether there is a dispute
        uint createTime;             //trade start time
        uint endTime;               //end time
        bytes32 dealTerms;          //
    }

    struct DealFee {
        uint price;                 //deal price. 6 decimals
        uint sFee;                  //fixed service fee
        uint gFeeS;                 //fixed guarantor fee
        uint gFeeA;                 //fixed guarantor fee
        uint buyer;                 //percent of funds received by the buyer. 2 decimals
        uint seller;                //percent of funds received by the seller. 2 decimals
    }

    //guarantor state
    struct Guarantor {
        uint registered;            //date of registration
        uint balance;               //guarantor balance in usdt. 6 decimals
        uint totalDeals;            //total deals without dispute
        uint totalDisputs;          //total deals with dispute
        uint volume;                //total deal volume. 6 decimals
        uint minDeal;               //minimum deal price in Usdt. 6 decimals
        uint sleepP;                //commission for deals in which the guarantor did not participate. 2 decimals
        uint activeP;               //commission for deals in which the guarantor participated. 2 decimals
        string info;                //string to store the contact, etc.
        bool autoAccept;            //automatic deal acceptance
        uint[] allDeals;
        uint[] active;
        uint[] disputs;
        uint[] archive;
        uint[] canceled;
    }


    ////User public functions ----------------------------------------------------------------------------------------------------------------------------////
    
    //view user's deals
    function getUserDeals(address user) external view returns ( uint[] memory, uint[] memory, uint[] memory, uint[] memory ) {
        return ( 
            Users[user].allDeals,
            Users[user].active,
            Users[user].archive,
            Users[user].canceled
        );
    }

    //user registration
    function userSignIn() external {
        require(Users[msg.sender].registered == 0);
        Users[msg.sender].registered = block.timestamp;
        totalUsers++;
    }

    //deal creation
    function createDeal(
        bool iamBuyer,
        address secondPartner,
        bool guarantor,
        address guarantAddr,
        uint price,
        bytes32 dealTerms
        ) external returns(bool){
            address buyer;
            address seller;
            bool guarantAccept = true;
            uint sFee = commissionFee;
            uint gFeeS;
            uint gFeeA;
            require(Users[msg.sender].registered != 0 && Users[secondPartner].registered != 0);
            require(msg.sender != secondPartner);
            if (iamBuyer){
                buyer = msg.sender;
                seller = secondPartner;
            }
            if (!iamBuyer) {
                buyer = secondPartner;
                seller = msg.sender;
            }
            if (!guarantor) {       //deal without a guarantor
                guarantAddr = 0x0000000000000000000000000000000000000000;
            }
            if (guarantor) {        //deal with a guarantor
                require(guarantAddr != buyer && guarantAddr != seller);
                require(Guarantors[guarantAddr].registered != 0);
                require(Guarantors[guarantAddr].minDeal <= price);
                gFeeS = Guarantors[guarantAddr].sleepP;
                gFeeA = Guarantors[guarantAddr].activeP;
                if (!Guarantors[guarantAddr].autoAccept) {
                    guarantAccept = false;
                }
            }
            Deals.push(Deal(false, false, buyer, seller, msg.sender, guarantor, guarantAccept, guarantAddr, false, block.timestamp, 0, dealTerms));
            DealsFee.push(DealFee(price, sFee, gFeeS, gFeeA, 0, 0));
            Users[buyer].allDeals.push(Deals.length-1);
            Users[seller].allDeals.push(Deals.length-1);
            if (guarantor) {
                Guarantors[guarantAddr].allDeals.push(Deals.length-1);
            }
            return true;

    }

    //second user accepts the deal
    function acceptDeal(uint idDeal) external returns(bool){
        require(msg.sender == Deals[idDeal].buyerAddr || msg.sender == Deals[idDeal].sellerAddr);
        require(msg.sender != Deals[idDeal].creatorDeal);
        require(Deals[idDeal].accepted == false && Deals[idDeal].endTime == 0);
        require(Deals[idDeal].guarantAccept);
        Deals[idDeal].accepted = true;
        Users[Deals[idDeal].buyerAddr].active.push(idDeal);
        Users[Deals[idDeal].sellerAddr].active.push(idDeal);
        if (Deals[idDeal].guarantor) {
            Guarantors[Deals[idDeal].guarantAddr].active.push(idDeal);
        }
        return true;
    }


    //rejection of the deal by one party
    function cancelDeal (uint idDeal) external returns(bool){
        require(msg.sender == Deals[idDeal].buyerAddr || msg.sender == Deals[idDeal].sellerAddr || msg.sender == Deals[idDeal].guarantAddr);
        require(Deals[idDeal].endTime == 0 && Deals[idDeal].deposit == false);
        Deals[idDeal].endTime = block.timestamp;
        Users[Deals[idDeal].buyerAddr].canceled.push(idDeal);
        Users[Deals[idDeal].sellerAddr].canceled.push(idDeal);
        if (Deals[idDeal].guarantor) {
            Guarantors[Deals[idDeal].guarantAddr].canceled.push(idDeal);
        }
        return true;
    }

    //buyer deposits funds
    function depositUSDT (uint idDeal) external returns(bool){
        require(msg.sender == Deals[idDeal].buyerAddr);
        require(Deals[idDeal].accepted == true && Deals[idDeal].endTime == 0 && Deals[idDeal].deposit == false);
        require(safeTransferFrom(msg.sender, thisContract, DealsFee[idDeal].price));
        Deals[idDeal].deposit = true;
        return true;
    }

    //buyer confirms the deal
    function approveDeal (uint idDeal) external returns(bool){
        require(msg.sender == Deals[idDeal].buyerAddr);
        require(Deals[idDeal].endTime == 0 && Deals[idDeal].deposit == true);
        require(Deals[idDeal].dispute == false);
        
        Deals[idDeal].endTime = block.timestamp;

        Users[Deals[idDeal].buyerAddr].good++;
        Users[Deals[idDeal].sellerAddr].good++;
        Guarantors[Deals[idDeal].guarantAddr].totalDeals++;

        Users[Deals[idDeal].buyerAddr].archive.push(idDeal);
        Users[Deals[idDeal].sellerAddr].archive.push(idDeal);
        if (Deals[idDeal].guarantor) {
            Guarantors[Deals[idDeal].guarantAddr].archive.push(idDeal);
        }

        Users[Deals[idDeal].buyerAddr].volume += DealsFee[idDeal].price;
        Users[Deals[idDeal].sellerAddr].volume += DealsFee[idDeal].price;
        Guarantors[Deals[idDeal].guarantAddr].volume += DealsFee[idDeal].price;
    
        totalVolume += DealsFee[idDeal].price;
        //service fee
        uint fee1 = (DealsFee[idDeal].price * DealsFee[idDeal].sFee)/10000;
        commissionUSDT += fee1;
        //add the guarantor's commission
        uint fee2 = (DealsFee[idDeal].price * DealsFee[idDeal].gFeeS)/10000;
        Guarantors[Deals[idDeal].guarantAddr].balance += fee2;
        //add the seller's balance
        uint addBallance = DealsFee[idDeal].price - fee1 - fee2;
        Users[Deals[idDeal].sellerAddr].balance += addBallance;
        DealsFee[idDeal].seller = 10000;
        return true;
    }
    
    //dispute the deal
    function disputeDeal (uint idDeal) external returns(bool){
        require(msg.sender == Deals[idDeal].buyerAddr || msg.sender == Deals[idDeal].sellerAddr);
        require(Deals[idDeal].endTime == 0 && Deals[idDeal].deposit == true && Deals[idDeal].dispute == false);
        require(Deals[idDeal].guarantor);
        Deals[idDeal].dispute = true;
        Users[Deals[idDeal].buyerAddr].dispute++;
        Users[Deals[idDeal].sellerAddr].dispute++;
        Guarantors[Deals[idDeal].guarantAddr].disputs.push(idDeal);
        return true;
    }

    //Change the amount of payment in a deal without a guarantor
    function disputeWithoutGar (uint idDeal, uint buyerPercent) external returns(bool){
        (bool succes, bytes memory returndata) = implementation.delegatecall(abi.encodeWithSignature("disputeWithoutGar(uint256,uint256)", idDeal, buyerPercent));
        require(succes);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert();
        }
        return true;
    }
    

    //withdrawal of funds from the user's or guarantor's balance
    function withdrawFunds (bool iamUser) external returns(bool) {
        if(iamUser) {
            uint value = Users[msg.sender].balance;
            Users[msg.sender].balance = 0;
            require(safeTransfer(msg.sender, value));
        } else {
            uint value = Guarantors[msg.sender].balance;
            Guarantors[msg.sender].balance = 0;
            require(safeTransfer(msg.sender, value));
        }
        return true;
    }


    //set user profile information
    function setInfo (string memory info, bool iamUser) external returns(bool) {
        if (iamUser) {
            require(Users[msg.sender].registered != 0);
            Users[msg.sender].info = info;
        } else {
            require(Guarantors[msg.sender].registered != 0);
            Guarantors[msg.sender].info = info;
        }
        return true;
    }


    ////User private functions ----------------------------------------------------------------------------------------------------------------------------////

    //add Usdt to the contract
    function safeTransferFrom(address from, address to, uint value) private returns (bool) {
        (bool succes, bytes memory returndata) = addressUsdt.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value));
        require(succes);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert();
        }
        return true;
    }

    //take Usdt out of the contract
    function safeTransfer(address to, uint value) private returns (bool) {
        (bool succes, bytes memory returndata) = addressUsdt.call(abi.encodeWithSignature("transfer(address,uint256)", to, value));
        require(succes);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert();
        }
        return true;
    }


    ////Guarantor public functions ----------------------------------------------------------------------------------------------------------------------------////

    //view guarantor's deals
    function getGuarantorDeals(address guarantor) external view returns ( uint[] memory, uint[] memory, uint[] memory, uint[] memory, uint[] memory ) {
        return (
            Guarantors[guarantor].allDeals,
            Guarantors[guarantor].active,
            Guarantors[guarantor].disputs,
            Guarantors[guarantor].archive,
            Guarantors[guarantor].canceled
        );
    }

    //Guarantor registration
    function guarantorSignIn() external {
        require(Guarantors[msg.sender].registered == 0);
        require(safeTransferFrom(msg.sender, thisContract, guarantorRegPrice));
        commissionUSDT += guarantorRegPrice;
        Guarantors[msg.sender].registered = block.timestamp;
        totalGuarantors++;
    }

    //accept the deal if autoAccept is turned off
    function acceptDealGuarantor(uint idDeal) external returns(bool){
        require(msg.sender == Deals[idDeal].guarantAddr);
        Deals[idDeal].guarantAccept = true;
        return true;
    }

    //settle a dispute in a deal
    function settleDispute(uint idDeal, uint buyerPercent) external returns (bool){
        (bool succes, bytes memory returndata) = implementation.delegatecall(abi.encodeWithSignature("settleDispute(uint256,uint256)", idDeal, buyerPercent));
        require(succes);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert();
        }
        return true;
    }

    //set the guarantor's commission
    function setGuarantorFee(uint fee1, uint fee2) external returns (bool){
        require(Guarantors[msg.sender].registered != 0);
        require(fee1 <= 1000 && fee2 <= 2000);
        Guarantors[msg.sender].sleepP = fee1;
        Guarantors[msg.sender].activeP = fee2;
        return true;
    }

    //set a minimum deal value
    function setGuarantorMinDeal(uint value) external returns (bool){
        require(Guarantors[msg.sender].registered != 0);
        Guarantors[msg.sender].minDeal = value;
        return true;
    }

    //change autoAccept
    function setAutoAccept() external returns(bool){
        require(Guarantors[msg.sender].registered != 0);
        Guarantors[msg.sender].autoAccept = !Guarantors[msg.sender].autoAccept;
        return true;
    }


    ////Owner & Admin private functions ------------------------------------------------------------------------------------------------------------------////

    //change the guarantor in the deal
    function changeDealGuarantor(uint idDeal, address newGuarantor) external onlyAdmin returns (bool){
        require(Guarantors[newGuarantor].registered != 0);
        require(Deals[idDeal].endTime == 0 && Deals[idDeal].deposit == true);
        Deals[idDeal].guarantor = true;
        Guarantors[Deals[idDeal].guarantAddr].canceled.push(idDeal);
        Deals[idDeal].dispute = true;
        Deals[idDeal].guarantAddr = newGuarantor;
        DealsFee[idDeal].gFeeS = Guarantors[newGuarantor].sleepP;
        DealsFee[idDeal].gFeeA = Guarantors[newGuarantor].activeP;
        Guarantors[newGuarantor].disputs.push(idDeal);
        return true;
    }


    function setServiceFee(uint _commissionFee, uint _guarantorRegPrice) external onlyOwner{
        commissionFee = _commissionFee;
        guarantorRegPrice = _guarantorRegPrice;
    }

    function withdrawServiceFee() external onlyOwner{
        uint value = commissionUSDT;
        commissionUSDT = 0;
        require(safeTransfer(owner, value));
    }

    function withdrawFunds(address contractA, address to, uint value) external onlyOwner returns(bool){
        (bool succes, bytes memory returndata) = contractA.call(abi.encodeWithSignature("transfer(address,uint256)", to, value));
        require(succes);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert();
        }
        return true;
    }

    function withdrawBNB_ETH(uint amount) external onlyOwner{
        (bool success, ) = owner.call{value: amount}("");
        require(success);
    }

    
    function changeAdmin(address newAdmin) external onlyOwner{
        admin = newAdmin;
    }

    function changeOwner(address payable newOwner) external onlyOwner{
        owner = newOwner;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || msg.sender == admin);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {}
}