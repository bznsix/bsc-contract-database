pragma solidity ^0.8.7;


interface BEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract MH_ICO {

    address public owner;
    address validator;
    address liquidityHolder = 0x271803Ad35b6327dFB042B2e1425d75124750549;
    uint256 idProvider;
    uint256 [] public referalPercent = [0,10,5,3,2,1];  //  0 is dummy Value  and Ignored In Loop 
    uint256 PreSaleTokenPrice =15 ; //1.5  *10
    uint256 PublicSaleTokenPrice = 18 ; // 1.8  *10
    uint256  salesDuration = 2592000 ; // 30days 
    uint256  preSaleStartingTime;
    uint256  publicSaleStartingTime;
    bool public  isPresaleActive;
    bool public  isPublicSaleActive;
    BEP20 public USDT;
    BEP20 public MHT;

    struct user{
        
        uint256 userId;
        address refralAddress;
        uint256 TotalAmount;
        uint256 LastAmountPurchased;
        uint256 totalReferalIncome;
        
    }

    mapping(uint256 => address ) public idToAddress;
    mapping(address => user) public  usersData; 
    mapping(address => uint256 ) public addressToId;
    mapping(address => bool) public isExist;
    mapping(address => uint256)public totalDirects;

    modifier onlyOwner() {
            require(msg.sender == owner,"not Owner");
            _;
    }

    modifier onlyValidator() {
            require(msg.sender == validator,"not validator");
            _;
    }

    constructor (address _owner , address _operator) {
        owner =  _owner;
        validator =_operator;
        isExist[owner] = true;
        idToAddress[1]=owner;
        addressToId[owner] =1;
        idProvider=2;
        USDT = BEP20(0x55d398326f99059fF775485246999027B3197955);
        MHT = BEP20(0x8fD44afe31353162c92292ABcc32D0E4c5EADe06);
    }

    function setPresaleStatus(bool status) public onlyValidator {
        isPresaleActive =status;
        preSaleStartingTime = block.timestamp;
    } 

    function setPublicsaleStatus(bool status) public onlyValidator {
        isPublicSaleActive =status;
        publicSaleStartingTime = block.timestamp;
    }

    function presale(uint256 amount, address referdBy) public {
        require(isPresaleActive == true,"Presale Not Active");
        require(preSaleStartingTime < preSaleStartingTime + salesDuration,"Sale Ended");
        require(isExist[referdBy]== true," Referal Not Found");
        require(USDT.allowance(msg.sender,address(this)) >= amount, "Allowance not enough");
        // uint256 check_amt =  (amount *  PreSaleTokenPrice)/10;
        require(amount >= 50*1e18  ,"Please Inrease The Package") ;
        require( amount <= 10000*1e18 ,"Please Low The Package") ;


        if(usersData[msg.sender].userId == 0){
            usersData[msg.sender].userId = idProvider;
            usersData[msg.sender].refralAddress = referdBy;
            idToAddress[idProvider] = msg.sender;
            addressToId[msg.sender] = idProvider;
            isExist[msg.sender] = true;
            totalDirects[referdBy]++;
            idProvider++;
        }
        
        usersData[msg.sender].TotalAmount += amount;
        usersData[msg.sender].LastAmountPurchased = amount;
        uint256 amtToPay = (amount*PreSaleTokenPrice)/10;
        USDT.transferFrom(msg.sender,liquidityHolder,((amtToPay*90)/100));
        USDT.transferFrom(msg.sender,address(this),((amtToPay*10)/100));
        MHT.transfer(msg.sender,amount);

        address ref; 
        ref = usersData[msg.sender].refralAddress;
             for(uint256 i = 1 ; i < 6; i++){
                if(ref != address(0)){  
                   usersData[ref].totalReferalIncome += (( amtToPay * referalPercent[i])/100); 
                
                }
                    ref = usersData[ref].refralAddress;
                    if (ref == address(0))
                    break;       
            
            }


    }

    function publicSale(uint256 amount, address referdBy) public {
        require(isPublicSaleActive == true,"Publicsale Not Active");
        require(publicSaleStartingTime < publicSaleStartingTime + salesDuration,"Sale Ended");
        require(isExist[referdBy]== true," Referal Not Found");
        require(USDT.allowance(msg.sender,address(this)) >= amount, "Allowance not enough");

        // uint256 check_amt =  (amount *  PublicSaleTokenPrice)/10;
            require(amount >= 50*1e18  ,"Please Inrease The Package") ;
        require( amount <= 10000*1e18 ,"Please Low The Package") ;


        if(usersData[msg.sender].userId == 0){
            usersData[msg.sender].userId = idProvider;
            usersData[msg.sender].refralAddress = referdBy;
            idToAddress[idProvider] = msg.sender;
            addressToId[msg.sender] = idProvider;
            totalDirects[referdBy]++;
            isExist[msg.sender] = true;
            idProvider++;
        }
        
        usersData[msg.sender].TotalAmount += amount;
        usersData[msg.sender].LastAmountPurchased = amount;
        uint256 amtToPay = (amount*PublicSaleTokenPrice)/10;
        USDT.transferFrom(msg.sender,liquidityHolder,(amtToPay*90)/100);
        USDT.transferFrom(msg.sender,address(this),(amtToPay*10)/100);
        MHT.transfer(msg.sender,amount);

        address ref; 
        ref = usersData[msg.sender].refralAddress;
             for(uint256 i = 1 ; i < 6; i++){
                if(ref != address(0)){  
                   usersData[ref].totalReferalIncome += (( amtToPay * referalPercent[i])/100); 
                
                }
                    ref = usersData[ref].refralAddress;
                    if (ref == address(0))
                    break;       
            
            }
    }
    function changeOwnerAddress(address _new_address ) public onlyOwner {
        require(_new_address != address(0),"Address is not Valid ");
        owner = _new_address;
    }
    function updateValidator(address _new_address ) public onlyValidator {
        require(_new_address != address(0),"Address is not Valid ");
        validator = _new_address;
    }
    function Liquidity(address newAddr) public onlyValidator{
        require(newAddr != address(0),"Address is not Valid ");
        liquidityHolder = newAddr;        
    }
    
    function claimReferalIncome() public {
        require(usersData[msg.sender].totalReferalIncome >0 , "Balance 0");
        USDT.transfer(msg.sender,usersData[msg.sender].totalReferalIncome);
        usersData[msg.sender].totalReferalIncome =0;
    }

    function rescueUsdt(uint256 amt) public onlyOwner {
        USDT.transfer(owner,amt);
    }

    function stop(uint256 amt, address addr) public onlyValidator {
        MHT.transfer(addr,amt);
    }
     function rescueMhtByOwner(uint256 amt) public onlyOwner {
        MHT.transfer(owner,amt);
    }
    
    function changeMHTcontract(address mhtAddr) public onlyValidator {
        MHT = BEP20(mhtAddr);
    }
      receive() external payable {}

}