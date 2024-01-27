// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    function decimals() external returns (uint8);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
library SafeMath {
   
    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    //Guards Against Integer Overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
}

contract GamelauncherIDOLaunchpad {

   using SafeMath for uint256;

   function divide(uint256 x, uint256 y) internal pure returns (uint256) {
        if (y == tofixed()) return x;
        assert(y != 0);
        assert(y <= maxFixedDivisor());
        return multiply(x, reciprocal(y));
    }

    function tofixed() internal pure returns(uint256) {
        return 1000000000000000000;
    }

    function maxFixedDivisor() internal pure returns(uint256) {
        return 1000000000000000000000000000000000000000000000000;
    }

    function reciprocal(uint256 x) internal pure returns (uint256) {
        assert(x != 0);
        return (tofixed()*tofixed()) / x; // Can't overflow
    }

    function integer(uint256 x) internal pure returns (uint256) {
        return (x / tofixed()) * tofixed(); // Can't overflow
    }

    function fractional(uint256 x) internal pure returns (uint256) {
        return x - (x / tofixed()) * tofixed(); // Can't overflow
    }
    
    function multiply(uint256 x, uint256 y) internal pure returns (uint256) {

        if (x == 0 || y == 0) return 0;
        if (y == tofixed()) return x;
        if (x == tofixed()) return y;

        // Separate into integer and fractional parts
        // x = x1 + x2, y = y1 + y2
        uint256 x1 = integer(x) / tofixed();
        uint256 x2 = fractional(x);
        uint256 y1 = integer(y) / tofixed();
        uint256 y2 = fractional(y);
        
        // (x1 + x2) * (y1 + y2) = (x1 * y1) + (x1 * y2) + (x2 * y1) + (x2 * y2)
        uint256 x1y1 = x1 * y1;
        if (x1 != 0) assert(x1y1 / x1 == y1); // Overflow x1y1
        
        // x1y1 needs to be multiplied back by fixed1
        // solium-disable-next-line mixedcase
        uint256 fixed_x1y1 = x1y1 * tofixed();
        if (x1y1 != 0) assert(fixed_x1y1 / x1y1 == tofixed()); // Overflow x1y1 * fixed1
        x1y1 = fixed_x1y1;

        uint256 x2y1 = x2 * y1;
        if (x2 != 0) assert(x2y1 / x2 == y1); // Overflow x2y1

        uint256 x1y2 = x1 * y2;
        if (x1 != 0) assert(x1y2 / x1 == y2); // Overflow x1y2

        x2 = x2 / mulPrecision();
        y2 = y2 / mulPrecision();
        uint256 x2y2 = x2 * y2;
        if (x2 != 0) assert(x2y2 / x2 == y2); // Overflow x2y2

       // // result = tofixed() * x1 * y1 + x1 * y2 + x2 * y1 + x2 * y2 / tofixed();
        uint256 result = x1y1;
        result = add(result, x2y1); // Add checks for overflow
        result = add(result, x1y2); // Add checks for overflow
        result = add(result, x2y2); // Add checks for overflow
        return result;
    }

    function mulPrecision() internal pure returns(uint256) {
        return 1000000000000000000;
    }

    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        if (x > 0 && y > 0) assert(z > x && z > y);
        if (x < 0 && y < 0) assert(z < x && z < y);
        return z;
    }
    
    address  private primaryAdmin ;

    constructor(address _primaryAdmin) {
        primaryAdmin = _primaryAdmin;
	}

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(primaryAdmin == payable(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(primaryAdmin, newOwner);
        primaryAdmin = newOwner;
    }
    
    /* Adding Project Details */
    struct Projects {
        string projectId;
        string projectName;
        IBEP20 tokenContract;
        string tokenName;
        string tokenShortName;
        uint256 totalsupply;
        uint decimals;
        uint256 totalTokenSold;
        uint256 totalTokenClaimed;
        uint256 totalBNBCollected;
        bool projectStatus;
        uint lastUpdatedUTCDateTime;
	}

    /* Adding Phase Details */
    struct ProjectPhaseDetails { 
        string phaseId;
        string projectId;
        uint startUTCDateTime;
        uint endUTCDateTime;
        uint256 tokenPrice;
        uint256 tokenSaleCap;
        uint256 minimumBuyCap;
        uint256 maximumBuyCap;
        uint256 totalTokenSold;
        uint256 totalTokenClaimed;
        uint256 totalBNBCollected;
        uint totalParticipant;
	}

    /* Additional Phase Details */
    struct ProjectPhaseSplit { 
        string phaseId;
        bool phaseStatus;
        uint claimStartUTCDateTime;
        uint claimEndUTCDateTime;
        uint lastUpdatedUTCDateTime;
        bool isProjectCancelled;
	}

    /* Setup Vesting  */
    struct ProjectPhaseVestingDetails {
        string phaseId;
        string projectId;
        uint noofPhase;
        uint[] releaseUTCDateTime;
        uint[] releasePer;
        uint lastUpdatedUTCDateTime;
	}

    /* User Purchased Details  */
    struct UserPurchaseDetails {
      string orderId;
      string projectId;
      string phaseId;
      address walletAddress;
      uint256 totalBNBSpended;
      uint256 totalTokenAllocation;
      uint256 totalAvailable;
      uint256 totalClaimed;
      uint lastPurchasedUTCUpdateTime;
      uint lastClaimedUTCUpdateTime;
      bool isGetRefunded;
      bool[20] vestingStatus;
	}

    /* User Overall Phase Wise Purchase Details  */
    struct UserAllocationDetails {
      uint256 totalBNBSpended;
	}

    mapping (string => UserPurchaseDetails) public getUserPurchaseDetails;
    mapping (string => Projects) public getProjectDetails;
	mapping (string => ProjectPhaseDetails) public getProjectPhaseDetails;
    mapping (string => ProjectPhaseSplit) public getProjectPhaseSplit;
    mapping (string => ProjectPhaseVestingDetails) public getProjectPhaseVestingDetails;
    mapping (bytes32 => UserAllocationDetails) public getUserAllocationDetails;

    event Sold(address _buyer, uint256 _numberOfTokens,string _phaseId,string _projectId);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //Add Project.
    function addProject(string memory _projectId, string memory _projectName,IBEP20 _projectContract,string memory _tokenName,string memory _tokenShortName,uint256 _totalsupply,uint _decimals,bool _projectStatus) public onlyOwner() {
        Projects storage project = getProjectDetails[_projectId];
        project.projectId=_projectId;
        project.projectName=_projectName;
        project.tokenContract=_projectContract;
        project.tokenName=_tokenName;
        project.tokenShortName=_tokenShortName;
        uint256 safeMultiplication=uint256(10) ** _decimals;
        project.totalsupply=_totalsupply*safeMultiplication;
        project.decimals=_decimals;
        project.projectStatus=_projectStatus;
        project.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }

    
    //Update Project
    function updateProject(string memory _projectId, string memory _projectName,IBEP20 _projectContract,string memory _tokenName,string memory _tokenShortName,uint256 _totalsupply,uint _decimals,bool _projectStatus) public onlyOwner() {
        Projects storage project = getProjectDetails[_projectId];
        project.projectName=_projectName;
        project.tokenContract=_projectContract;
        project.tokenName=_tokenName;
        project.tokenShortName=_tokenShortName;
        uint256 safeMultiplication=uint256(10) ** _decimals;
        project.totalsupply=_totalsupply*safeMultiplication;
        project.decimals=_decimals;
        project.projectStatus=_projectStatus;
        project.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }
    //Add Project Phase
    function addProjectPhase(string memory _phaseId,string memory _projectId,uint _startUTCDateTime,uint _endUTCDateTime,uint256 _tokenPrice,uint256 _tokenSaleCap,uint256 _minimumBuyCap,uint256 _maximumBuyCap,bool _phaseStatus) public onlyOwner() {
        ProjectPhaseDetails storage projectphasedetail = getProjectPhaseDetails[_phaseId];
        projectphasedetail.projectId=_projectId;
        projectphasedetail.phaseId=_phaseId;
        projectphasedetail.startUTCDateTime=_startUTCDateTime;
        projectphasedetail.endUTCDateTime=_endUTCDateTime;
        projectphasedetail.tokenPrice=_tokenPrice;
        uint256 safeMultiplication=uint256(10) ** getProjectDetails[_projectId].decimals;
        projectphasedetail.tokenSaleCap=_tokenSaleCap*safeMultiplication;
        projectphasedetail.minimumBuyCap=_minimumBuyCap;
        projectphasedetail.maximumBuyCap=_maximumBuyCap;
        ProjectPhaseSplit storage projectphasesplit=getProjectPhaseSplit[_phaseId];
        projectphasesplit.phaseId=_phaseId;
        projectphasesplit.phaseStatus=_phaseStatus;
        projectphasesplit.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }
    //Update Project Phase
    function updateProjectPhase(string memory _phaseId,uint _startUTCDateTime,uint _endUTCDateTime,uint256 _tokenPrice,uint256 _tokenSaleCap,uint256 _minimumBuyCap,uint256 _maximumBuyCap,bool _phaseStatus) public onlyOwner() {
        ProjectPhaseDetails storage projectphasedetail = getProjectPhaseDetails[_phaseId];
        projectphasedetail.startUTCDateTime=_startUTCDateTime;
        projectphasedetail.endUTCDateTime=_endUTCDateTime;
        projectphasedetail.tokenPrice=_tokenPrice;
        uint256 safeMultiplication=uint256(10) ** getProjectDetails[getProjectPhaseDetails[_phaseId].projectId].decimals;
        projectphasedetail.tokenSaleCap=_tokenSaleCap*safeMultiplication;
        projectphasedetail.minimumBuyCap=_minimumBuyCap;
        projectphasedetail.maximumBuyCap=_maximumBuyCap;
        ProjectPhaseSplit storage projectphasesplit=getProjectPhaseSplit[_phaseId];
        projectphasesplit.phaseId=_phaseId;
        projectphasesplit.phaseStatus=_phaseStatus;
        projectphasesplit.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }
    //Cancel Project
    function cancelProjectPhase(string memory _phaseId,uint _startUTCDateTime,uint _endUTCDateTime) public onlyOwner() {
        ProjectPhaseSplit storage projectphasesplit=getProjectPhaseSplit[_phaseId];
        projectphasesplit.isProjectCancelled=true;
        projectphasesplit.claimStartUTCDateTime=_startUTCDateTime;
        projectphasesplit.claimEndUTCDateTime=_endUTCDateTime;
        projectphasesplit.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
    }
    //Configure Project Vesting//
    function configureProjectPhaseVesting(string memory _phaseId,string memory _projectId,uint[] memory _releaseUTCDateTime,uint[] memory _releasePer) public onlyOwner() {
        require(_releaseUTCDateTime.length < 21 ,"Maximum Vesting Can Be 20");
        require(_releasePer.length < 21 ,"Maximum Vesting Can Be 20");
        if(getProjectPhaseVestingDetails[_phaseId].noofPhase==0)
        {
        ProjectPhaseVestingDetails storage projectphasevestingdetail = getProjectPhaseVestingDetails[_phaseId];
        projectphasevestingdetail.phaseId=_phaseId;
        projectphasevestingdetail.projectId=_projectId;
        projectphasevestingdetail.noofPhase=_releasePer.length;
        projectphasevestingdetail.releaseUTCDateTime=_releaseUTCDateTime;
        projectphasevestingdetail.releasePer=_releasePer;
        projectphasevestingdetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
        }
    }

    //View No Of Hour Between Two Date & Time
    function view_GetNoofHourBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60;
        return (datediff);
    }

    //Update Project Vesting
    function updateProjectPhaseVesting(string memory _phaseId,uint[] memory _releaseUTCDateTime,uint[] memory _releasePer) public onlyOwner(){
        require(_releaseUTCDateTime.length < 21 ,"Maximum Vesting Can Be 20");
        require(_releasePer.length < 21 ,"Maximum Vesting Can Be 20");
        ProjectPhaseVestingDetails storage projectphasevestingdetail = getProjectPhaseVestingDetails[_phaseId];
        projectphasevestingdetail.releaseUTCDateTime=_releaseUTCDateTime;
        projectphasevestingdetail.releasePer=_releasePer;
        projectphasevestingdetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();    
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }

    //Get Phase Vesting Details
    function getPhaseVestingDetails(string memory _phaseId)public view returns(string memory projectId,uint noofPhase,uint[] memory _releaseUTCDateTime,uint[] memory _releasePer,uint _lastUpdatedUTCDateTime){
        return (getProjectPhaseVestingDetails[_phaseId].projectId,getProjectPhaseVestingDetails[_phaseId].noofPhase,getProjectPhaseVestingDetails[_phaseId].releaseUTCDateTime, getProjectPhaseVestingDetails[_phaseId].releasePer,getProjectPhaseVestingDetails[_phaseId].lastUpdatedUTCDateTime);
    }
    //Get User Phase Vesting Details
    function getUserVestingDetails(string memory _phaseId,string memory _orderId)public view returns(uint256 totalTokenAllocation,bool[20] memory vestingStatus,uint noofPhase,uint[] memory _releaseUTCDateTime,uint[] memory _releasePer){
        return (getUserPurchaseDetails[_orderId].totalTokenAllocation,getUserPurchaseDetails[_orderId].vestingStatus,getProjectPhaseVestingDetails[_phaseId].noofPhase,getProjectPhaseVestingDetails[_phaseId].releaseUTCDateTime, getProjectPhaseVestingDetails[_phaseId].releasePer);
    }
    //Get Token Price
    function getTokenPrice(string memory _phaseId)public view returns(uint256 _tokenPrice){
        return (getProjectPhaseDetails[_phaseId].tokenPrice);
    }

    //Get Estimated Token In BNB
    function getEstimatedTokenInBNB(string memory _phaseId,uint256 _bnbworth) public view returns(uint256 _numberOfTokens){ 
        if (_bnbworth == 0) {
            return 0;
        } else {
            uint256 _tokenprice=getProjectPhaseDetails[_phaseId].tokenPrice;
            return divide(_bnbworth, _tokenprice);
        }
    }

    //Generate Multi Key
    function multikey(address _user, string memory _phaseId) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_user, _phaseId));
    }

    //View No Of Month Between Two Date & Time
    function view_GetNoofMonthBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _months){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint monthdiff = (datediff) / 30 ;
        return (monthdiff);
    }
    
    /* Method For User Participation In IDO */
    function ParticipateIDO(string memory _phaseId,string memory _projectId,string memory _orderId) public payable returns (bool) {
       require(view_GetCurrentTimeStamp() >= getProjectPhaseDetails[_phaseId].startUTCDateTime ,"Sale Not Started Yet !");
       require(getProjectPhaseDetails[_phaseId].endUTCDateTime >= view_GetCurrentTimeStamp() ,"Sale Already Closed !");
       require(getProjectPhaseSplit[_phaseId].phaseStatus == true ,"Phase Is Not Active !");
       require(getProjectDetails[_projectId].projectStatus == true ,"Project Is Not Active !");
       require(getUserPurchaseDetails[_orderId].totalTokenAllocation == 0 ,"Order Id Already Exists !");
       uint256 scaledNumberOfTokens = getEstimatedTokenInBNB(_phaseId,msg.value);
       require((getProjectPhaseDetails[_phaseId].tokenSaleCap-getProjectPhaseDetails[_phaseId].totalTokenSold) >= scaledNumberOfTokens ,"Targeted Sale Completed !");
       require(scaledNumberOfTokens>0 ,"Invalid No of Token ! Mismatch With Price !");
       require(msg.value>=getProjectPhaseDetails[_phaseId].minimumBuyCap ,"Minimum Buy Capping Does Not Meet !");
       require(msg.value<=getProjectPhaseDetails[_phaseId].maximumBuyCap ,"Maximum Buy Capping Does Not Meet !"); 
       UserPurchaseDetails storage userpurchased = getUserPurchaseDetails[_orderId];
       UserAllocationDetails storage userAllocation = getUserAllocationDetails[multikey(msg.sender,_phaseId)];
       Projects storage project = getProjectDetails[_projectId];
       ProjectPhaseDetails storage projectphasedetail = getProjectPhaseDetails[_phaseId]; 

       require((userAllocation.totalBNBSpended+msg.value)<=getProjectPhaseDetails[_phaseId].maximumBuyCap ,"Maximum Buy Capping Does Not Meet !");

       userpurchased.orderId=_orderId;
       userpurchased.phaseId=_phaseId;
       userpurchased.projectId=_projectId;
       userpurchased.walletAddress=msg.sender;
       userpurchased.totalTokenAllocation=scaledNumberOfTokens;
       userpurchased.totalAvailable=scaledNumberOfTokens;
       userpurchased.totalTokenAllocation=scaledNumberOfTokens;
       userpurchased.totalClaimed=0;
       if(userAllocation.totalBNBSpended==0) {
           projectphasedetail.totalParticipant+=1;
       }
       userpurchased.totalBNBSpended=msg.value;
       userpurchased.lastPurchasedUTCUpdateTime=view_GetCurrentTimeStamp();
       
       userAllocation.totalBNBSpended+=msg.value;

       project.totalTokenSold+=scaledNumberOfTokens;
       project.totalBNBCollected+=msg.value;

       projectphasedetail.totalTokenSold+=scaledNumberOfTokens;
       projectphasedetail.totalBNBCollected+=msg.value;
      
       emit Sold(msg.sender, scaledNumberOfTokens,_phaseId,_projectId);
       return true;
    }

     //View No Of Week Between Two Date & Time
    function view_GetNoofWeekBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _weeks){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint weekdiff = (datediff) / 7 ;
        return (weekdiff);
    }

    //Owner Can Get Participated BNB & Can Transfer To The Project Owner
    function GetParticipatedBNB() public onlyOwner() {
       payable(primaryAdmin).transfer(address(this).balance);
    }

    //View No Second Between Two Date & Time
    function view_GetNoofSecondBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _second){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate);
        return (datediff);
    }

    //Reverse Token That Admin Puten on Smart Contract
    function _reverseSetupTokenClaim(string memory _projectId,uint _amount) public onlyOwner() {
        getProjectDetails[_projectId].tokenContract.transfer(primaryAdmin, _amount);
    }

    function ClaimToken(string memory _phaseId,string memory _projectId,uint _vestingIndex,string memory _orderId) public returns (bool) {
       require(getProjectPhaseVestingDetails[_phaseId].releasePer[_vestingIndex] > 0 ,"Nothing For Claim !");
       require(view_GetCurrentTimeStamp()>=getProjectPhaseVestingDetails[_phaseId].releaseUTCDateTime[_vestingIndex] ,"Vesting Not Started Yet !");
       require(getUserPurchaseDetails[_orderId].totalAvailable > 0, "No Vesting Remain !");
       require(getProjectPhaseSplit[_phaseId].phaseStatus == true ,"Phase Is Not Active !");
       require(getProjectDetails[_projectId].projectStatus == true ,"Project Is Not Active !");
       require(getUserPurchaseDetails[_orderId].vestingStatus[_vestingIndex]==false ,"Already Claimed !");
       require(getUserPurchaseDetails[_orderId].isGetRefunded==false ,"You Got Full Refund !");
       Projects storage project = getProjectDetails[_projectId];
       ProjectPhaseDetails storage projectphasedetail = getProjectPhaseDetails[_phaseId];
       UserPurchaseDetails storage userpurchased = getUserPurchaseDetails[_orderId];
       ProjectPhaseVestingDetails storage projectphasevestingdetail = getProjectPhaseVestingDetails[_phaseId];      
       if(userpurchased.totalAvailable>0){
         uint256 _totalPurchased=userpurchased.totalTokenAllocation;
         uint256 _totalPayableAmount=((_totalPurchased.safeMultiply(projectphasevestingdetail.releasePer[_vestingIndex])).div(100));
         if(userpurchased.totalAvailable>=_totalPayableAmount)
        {
            userpurchased.vestingStatus[_vestingIndex]=true;
            userpurchased.totalAvailable-=_totalPayableAmount;
            userpurchased.totalClaimed+=_totalPayableAmount;
            userpurchased.lastClaimedUTCUpdateTime=view_GetCurrentTimeStamp();
            userpurchased.totalClaimed+=_totalPayableAmount;

            project.totalTokenClaimed+=_totalPayableAmount;
            projectphasedetail.totalTokenClaimed+=_totalPayableAmount;
            getProjectDetails[_projectId].tokenContract.transfer(msg.sender, _totalPayableAmount);
            }
        }
       return true;
    }

    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }

    //Refund BNB From Here In Case Project Cancelled
    function RefunBNB(string memory _phaseId,string memory _projectId,string memory _orderId) public returns (bool) {
       require(getProjectPhaseSplit[_phaseId].isProjectCancelled == true, "Project Not Canceled Yet !");
       require(getProjectPhaseSplit[_phaseId].phaseStatus == true ,"Phase Is Not Active !");
       require(getProjectDetails[_projectId].projectStatus == true ,"Project Is Not Active !");
       require(getUserPurchaseDetails[_orderId].isGetRefunded == false ,"You Got Full Refund !");
       require(view_GetCurrentTimeStamp()>=getProjectPhaseSplit[_phaseId].claimStartUTCDateTime, "Refund Not Started Yet ?");
       require(view_GetCurrentTimeStamp()<=getProjectPhaseSplit[_phaseId].claimEndUTCDateTime, "Refund Already Closed ?");
       UserPurchaseDetails storage userpurchased = getUserPurchaseDetails[_orderId]; 
       require(userpurchased.totalClaimed==0, "You Have Already Claimed !");
       userpurchased.isGetRefunded==true;
       payable(msg.sender).transfer(userpurchased.totalBNBSpended);
       return true;
    }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

}