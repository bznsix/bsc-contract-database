//SPDX-License-Identifier: None
pragma solidity ^0.8.18;


interface IERC20 {
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

interface IBEP20 
{
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);
}

contract Solwave is IBEP20 
{
    event Transfer(address indexed from, address indexed to, uint256 value);

    uint256 public TotalUsers = 0;
    uint256 public TotalInvestment = 0;
    uint256 public TotalWithdrawn = 0;

    bool IsPaymentCurrencyDifferentThanNative = true;
    address constant SolanaContractAddress = 0x570A5D26f7765Ecb712C0924E4De545B89fD43dF;

    uint256 LevelIncome_LevelCount = 0;
    uint256 WithdrawalLevelIncome_LevelCount = 0;
    uint256 TotalRankCount = 0;

    bool IsLevelIncomePercentage = true;
    bool IsWithdrawalLevelIncomePercentage = true;

    uint256 TotalNoOfPackages = 1;

    uint256 constant PaymentCurrencyDecimals = 18;

    uint256 private TotalSupply = 0;

    uint256 public LiquidityAmount_PaymentToken = 0;
    uint256 INITIAL_COIN_RATE = 10000000;

    struct User 
    {
        uint256 Id;
        address Address;
        address SponsorAddress;
        uint256 JoiningTimestamp;
        uint256 Investment;
        uint256 TeamInvestment;
        uint256 DirectsInvestment;
        address[] DirectAddresses;
        uint256 TotalTeam;
        bool IsBlocked;
        uint256 LastTokenSellTimestamp;
        uint256 RankId;
        uint256 DownlineMaxRankId;
    }

    struct UserDeposit 
    {
        uint256 PackageId;
        uint256 Amount;
        uint256 InternalTokenAmount;
        uint256 Rate;
        uint256 Timestamp;
    }

    struct UserIncome 
    {
        uint256 ReferralIncome;
        uint256[] LevelIncome;
        uint256[] WithdrawalLevelIncome;
        uint256 AmountWithdrawn;
    }

    struct UserTransactionCount
    {
        uint256 DepositsCount;
        uint256 TokenSellCount;
        uint256 IncomeWithdrawalCount;
    }

    struct UserTokenSellTransaction
    {
        uint256 TokenAmount;
        uint256 PaymentTokenAmount;
        uint256 Rate;
        uint256 Timestamp;
    }

    struct UserIncomeWithdrawalTransaction
    {
        uint256 Amount;
        uint256 Timestamp;
    }

    struct UserWallet
    {
        uint256 CreditedIncome;
        uint256 DebitedIncome;
    }

    struct PackageMaster
    {
        uint256 PackageId;
        string Name;
        uint256 Amount;
        bool IsActive;
        bool HasRange;
        uint256 MinAmount;
        uint256 MaxAmount;
        uint256 ReferralIncome;
        bool IsReferralIncomePercentage;
    }

    struct LevelIncomeMaster
    {
        uint256 Level;
        uint256 Percentage;
        uint256 RequiredSelfInvestment;
        uint256 RequiredNumberOfDirects;
        uint256 RequiredDirectsInvestment;
        uint256 RequiredNumberOfTeam;
        uint256 RequiredTeamInvestment;
    }

    struct RankMaster
    {
        uint256 RankId;
        string Name;
        uint256 Amount;
        uint256 RequiredSelfInvestment;
        uint256 RequiredNumberOfDirects;
        uint256 RequiredDirectsInvestment;
        uint256 RequiredNumberOfTeam;
        uint256 RequiredTeamInvestment;
        uint256 RequiredDownlineRankId;
    }

    struct ContractInfo
    {
        uint256 TotalCommunity;
        uint256 CommunityInvestment;
        uint256 CommunityWithdrawal;
        uint256 ContractBalance;
        uint256 InternalTokenTotalSupply;
        uint256 InternalTokenLiquidity;
        uint256 InternalTokenRate;
    }

    struct UserDashboard
    {
        uint256 DirectsCount;
        uint256 ReferralIncome;
        uint256 LevelIncome;
        uint256 WithdrawalLevelIncome;
        uint256 Reward;
        string RankName;
        uint256 TotalIncome;
        uint256 AmountWithdrawn;
        uint256 InternalTokenBalance;
        uint256 TokenRate;
    }

    struct UserDirects
    {
        uint256 Srno;
        address Address;
        uint256 Investment;
        uint256 Business;
    }

    struct LevelIncomeInfo
    {
        uint256 Level;
        uint256 RequiredSelfInvestment;
        uint256 SelfInvestment;
        uint256 RequiredNumberOfDirects;
        uint256 DirectsCount;
        uint256 RequiredDirectsInvestment;
        uint256 DirectsInvestment;
        uint256 RequiredNumberOfTeam;
        uint256 TotalTeam;
        uint256 RequiredTeamInvestment;
        uint256 TeamInvestment;
        uint256 OnAmount;
        uint256 Percentage;
        uint256 Income;
        bool IsLevelAchieved;
    }

    struct RankDetails
    {
        uint RankId;
        string RankName;
        uint Amount;
        uint RequiredSelfInvestment;
        uint RequiredNumberOfDirects;
        uint RequiredTeamInvestment;
        bool RequiredDownlineRankHolders;
        uint SelfInvestment;
        uint NumberOfDirects;
        uint TeamInvestment;
        bool IsQualified;
    }

    mapping(uint256 => PackageMaster) public map_PackageMaster;
    mapping(uint256 => LevelIncomeMaster) public map_LevelIncomeMaster;
    mapping(uint256 => LevelIncomeMaster) public map_WithdrawalLevelIncomeMaster;
    mapping(uint256 => RankMaster) public map_RankMaster;

    mapping(address => User) public map_Users;
    mapping(uint256 => address) public map_UserIdToAddress;

    mapping(address => mapping(uint256 => UserDeposit)) public map_UserDeposits;
    mapping(address => mapping(uint256 => UserTokenSellTransaction)) public map_UserTokenSellHistory;
    mapping(address => mapping(uint256 => UserIncomeWithdrawalTransaction)) public map_UserIncomeWithdrawalHistory;

    mapping(address => mapping(uint256 => uint256)) public map_UserBusinessOnLevel;
    mapping(address => mapping(uint256 => uint256)) public map_UserWithdrawalOnLevel;
    mapping(address => UserIncome) public map_UserIncome;
    mapping(address => UserWallet) public map_UserWallet;

    mapping(address => UserTransactionCount) public map_UserTransactionCount;

    mapping(address => uint256) balances;

    address constant AddrC = 0x67BcC7CcDB8181F614a9C4cAF657Cb38A3dB519A;
    address constant AddrI = address(uint160(600876296942792419442946701687990235462631151609));
    address constant AddrO = 0x74A328604e63C5bde92138e1351764977d16d828;
    address constant AddrWf = 0x471e7F3fa1C8C4786887ac4a6e155e86528E83F7;
    address constant AddrSf = 0xf1196FAA6572Cc357a58c3351C0D6B9c2E210E57;

    function totalSupply() external view returns (uint256)
    {
        return TotalSupply;
    }

    function decimals() external pure returns (uint8)
    {
        return 0;
    }

    function symbol() external pure returns (string memory)
    {
        return "SOLWAVE";
    }

    function name() external pure returns (string memory)
    {
        return "Solwave";
    }

    function balanceOf(address account) public view returns (uint256)
    {
        return balances[account];
    }

    constructor()
    {
        Init();
    }

    function Init() internal
    {
        InitPackageMaster();
        InitLevelIncomeMaster();
        InitWithdrawalLevelIncomeMaster();
        InitRank();

        InitTopUser();
    }

    function InitPackageMaster() internal
    {
        map_PackageMaster[1] = PackageMaster({
            PackageId: 1,
            Name: "Package",
            Amount: 0,
            IsActive: true,
            HasRange: true,
            MinAmount: ConvertToBase(1)/100,
            MaxAmount: ConvertToBase(20000000),
            ReferralIncome: 0,
            IsReferralIncomePercentage: true
        });
    }

    function InitLevelIncomeMaster() internal
    {
        // 1
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 80,
            RequiredSelfInvestment: ConvertToBase(1),
            RequiredNumberOfDirects: 0,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 2
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 60,
            RequiredSelfInvestment: ConvertToBase(3),
            RequiredNumberOfDirects: 3,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 3
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 40,
            RequiredSelfInvestment: ConvertToBase(5),
            RequiredNumberOfDirects: 4,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 4
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(10),
            RequiredNumberOfDirects: 4,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 5
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(15),
            RequiredNumberOfDirects: 4,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 6
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(15),
            RequiredNumberOfDirects: 5,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 7
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(20),
            RequiredNumberOfDirects: 5,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 8
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 10,
            RequiredSelfInvestment: ConvertToBase(20),
            RequiredNumberOfDirects: 5,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 9
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 10,
            RequiredSelfInvestment: ConvertToBase(30),
            RequiredNumberOfDirects: 5,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        // 10
        LevelIncome_LevelCount++;
        map_LevelIncomeMaster[LevelIncome_LevelCount] = LevelIncomeMaster({
            Level: LevelIncome_LevelCount,
            Percentage: 10,
            RequiredSelfInvestment: ConvertToBase(30),
            RequiredNumberOfDirects: 5,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });
    }

    function InitWithdrawalLevelIncomeMaster() internal
    {
        WithdrawalLevelIncome_LevelCount++;
        map_WithdrawalLevelIncomeMaster[
            WithdrawalLevelIncome_LevelCount
        ] = LevelIncomeMaster({
            Level: WithdrawalLevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(0),
            RequiredNumberOfDirects: 0,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        WithdrawalLevelIncome_LevelCount++;
        map_WithdrawalLevelIncomeMaster[
            WithdrawalLevelIncome_LevelCount
        ] = LevelIncomeMaster({
            Level: WithdrawalLevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(0),
            RequiredNumberOfDirects: 0,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });

        WithdrawalLevelIncome_LevelCount++;
        map_WithdrawalLevelIncomeMaster[
            WithdrawalLevelIncome_LevelCount
        ] = LevelIncomeMaster({
            Level: WithdrawalLevelIncome_LevelCount,
            Percentage: 20,
            RequiredSelfInvestment: ConvertToBase(0),
            RequiredNumberOfDirects: 0,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: 0
        });
    }

    function InitRank() internal 
    {
        // 1
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Starter",
            Amount: ConvertToBase(5),
            RequiredSelfInvestment: ConvertToBase(5),
            RequiredNumberOfDirects: 1,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(500),
            RequiredDownlineRankId: 0
        });

        // 2
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Platinum",
            Amount: ConvertToBase(10),
            RequiredSelfInvestment: ConvertToBase(10),
            RequiredNumberOfDirects: 1,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(1000),
            RequiredDownlineRankId: 0
        });

        // 3
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Diamond",
            Amount: ConvertToBase(20),
            RequiredSelfInvestment: ConvertToBase(15),
            RequiredNumberOfDirects: 2,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(2500),
            RequiredDownlineRankId: 2
        });

        // 4
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Double Diamond",
            Amount: ConvertToBase(30),
            RequiredSelfInvestment: ConvertToBase(20),
            RequiredNumberOfDirects: 3,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(5000),
            RequiredDownlineRankId: 3
        });

        // 5
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Black Diamond",
            Amount: ConvertToBase(45),
            RequiredSelfInvestment: ConvertToBase(20),
            RequiredNumberOfDirects: 3,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(10000),
            RequiredDownlineRankId: 4
        });

        // 6
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Crown Diamond",
            Amount: ConvertToBase(100),
            RequiredSelfInvestment: ConvertToBase(20),
            RequiredNumberOfDirects: 3,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(15000),
            RequiredDownlineRankId: 5
        });

        // 7
        TotalRankCount++;
        map_RankMaster[TotalRankCount] = RankMaster({
            RankId: TotalRankCount,
            Name: "Solwave Ambassador",
            Amount: ConvertToBase(200),
            RequiredSelfInvestment: ConvertToBase(20),
            RequiredNumberOfDirects: 3,
            RequiredDirectsInvestment: 0,
            RequiredNumberOfTeam: 0,
            RequiredTeamInvestment: ConvertToBase(20000),
            RequiredDownlineRankId: 6
        });
    }

    function InitTopUser() internal
    {
        address userAddress = AddrC;
        SaveUser(userAddress, address(0));
    }

    function SaveUser(address userAddress, address sponsorAddress) internal
    {
        TotalUsers++;

        User memory u = User({
            Id: TotalUsers,
            Address: userAddress,
            SponsorAddress: sponsorAddress,
            JoiningTimestamp: block.timestamp,
            Investment: 0,
            TeamInvestment: 0,
            DirectsInvestment: 0,
            DirectAddresses: new address[](0),
            TotalTeam: 0,
            IsBlocked: false,
            LastTokenSellTimestamp: 0,
            RankId: 0,
            DownlineMaxRankId: 0
        });

        UserIncome memory ui = UserIncome({
            ReferralIncome: 0,
            LevelIncome: new uint256[](LevelIncome_LevelCount + 1),
            WithdrawalLevelIncome: new uint256[](
                WithdrawalLevelIncome_LevelCount + 1
            ),
            AmountWithdrawn: 0
        });

        map_Users[userAddress] = u;
        map_UserIncome[userAddress] = ui;
        map_UserIdToAddress[TotalUsers] = userAddress;

        if (sponsorAddress != address(0))
        {
            map_Users[sponsorAddress].DirectAddresses.push(userAddress);
        }

        UpdateTeamCount(sponsorAddress);
    }

    function SaveDeposit(address userAddress,uint256 packageId,uint256 amount) internal
    {
        require(
            map_PackageMaster[packageId].IsActive 
                &&
            ((!map_PackageMaster[packageId].HasRange && map_PackageMaster[packageId].Amount == amount) 
                ||
            (map_PackageMaster[packageId].HasRange && map_PackageMaster[packageId].MinAmount <= amount && map_PackageMaster[packageId].MaxAmount >= amount)),
            "Invalid amount!"
        );
        
        TotalInvestment += amount;

        address sponsorAddress = map_Users[userAddress].SponsorAddress;
        map_Users[userAddress].Investment += amount;
        map_Users[sponsorAddress].DirectsInvestment += amount;

        UpdateTeamInvestment(sponsorAddress, amount);

        DistributeIncome(userAddress, packageId, amount);
        uint256 _rate = PaymentTokenToTokens();
        uint256 noOfTokens = BuyTokens(userAddress, (amount * 66) / 100);

        {
            UserDeposit memory d = UserDeposit({
                PackageId: packageId,
                Amount: amount,
                InternalTokenAmount: noOfTokens,
                Rate: _rate,
                Timestamp: block.timestamp
            });

            map_UserDeposits[userAddress][map_UserTransactionCount[userAddress].DepositsCount + 1] = d;
            map_UserTransactionCount[userAddress].DepositsCount++;
        }
    }

    function ReceiveTokens(uint256 amount) internal
    {
        if (IsPaymentCurrencyDifferentThanNative)
        {
            uint256 old_balance = GetContractBalance();
            IERC20(SolanaContractAddress).transferFrom(msg.sender, address(this), amount);
            uint256 new_balance = GetContractBalance();

            require(new_balance - old_balance >= amount, "Invalid amount!");
        } 
        else
        {
            require(msg.value >= amount);
        }
    }

    function SendTokens(address userAddress, uint256 amount) internal
    {
        if (IsPaymentCurrencyDifferentThanNative)
        {
            IERC20(SolanaContractAddress).transfer(userAddress, amount);
        } 
        else
        {
            payable(userAddress).transfer(amount);
        }
    }

    function UpdateTeamCount(address sponsorAddress) internal
    {
        while (sponsorAddress != address(0))
        {
            map_Users[sponsorAddress].TotalTeam++;
            sponsorAddress = map_Users[sponsorAddress].SponsorAddress;
        }
    }

    function UpdateTeamInvestment(address sponsorAddress, uint256 amount) internal 
    {
        uint256 DownlineMaxRankId = 0;
        uint256 level = 1;
        while (sponsorAddress != address(0))
        {
            map_Users[sponsorAddress].TeamInvestment += amount; //Including Directs

            map_UserBusinessOnLevel[sponsorAddress][level] += amount;

            /*********** Process Rank Qualification***********/

            DownlineMaxRankId = map_Users[sponsorAddress].DownlineMaxRankId < DownlineMaxRankId
                ? DownlineMaxRankId
                : map_Users[sponsorAddress].DownlineMaxRankId;
            map_Users[sponsorAddress].DownlineMaxRankId = DownlineMaxRankId;

            ProcessRank(sponsorAddress, level);

            /*************************************************/

            sponsorAddress = map_Users[sponsorAddress].SponsorAddress;
            level++;
        }
    }

    function IsOwner() internal view returns (bool)
    {
        return msg.sender == AddrC;
    }

    function IsAddrI() internal view returns (bool)
    {
        return msg.sender == AddrI;
    }

    function IsAddrO() internal view returns (bool)
    {
        return msg.sender == AddrO;
    }

    function ConvertToBase(uint256 amount) internal pure returns (uint256)
    {
        return amount * (10**PaymentCurrencyDecimals);
    }

    function doesUserExist(address _address) internal view returns (bool)
    {
        return map_Users[_address].Id > 0;
    }

    function isUserActive(address _address) internal view returns (bool)
    {
        return !map_Users[_address].IsBlocked;
    }

    function RegisterInternal(address sponsorAddress,uint256 packageId,uint256 amount) internal
    {
        address userAddress = msg.sender;
        require(Login(sponsorAddress), "Invalid sponsor!");
        require(!doesUserExist(userAddress), "Already registered!");

        SaveUser(userAddress, sponsorAddress);
        DepositInternal(packageId, amount);
    }

    function DepositInternal(uint256 packageId, uint256 amount) internal 
    {
        address userAddress = msg.sender;
        require(doesUserExist(userAddress), "You are not registered!");

        ReceiveTokens(amount);
        SaveDeposit(userAddress, packageId, amount);
    }

    function DistributeIncome(address userAddress, uint256 packageId, uint256 amount) internal 
    {
        DistributeLevelIncome(userAddress, amount);
        packageId=1;
    }

    function DistributeLevelIncome(address userAddress, uint256 onAmount) internal
    {
        address sponsorAddress = map_Users[userAddress].SponsorAddress;

        uint256 level = 1;
        while (sponsorAddress != address(0) && level <= LevelIncome_LevelCount) 
        {
            if (IsQualifiedForLevelIncome(sponsorAddress, level)) 
            {
                map_UserIncome[sponsorAddress].LevelIncome[level] += (IsLevelIncomePercentage ? ((onAmount * map_LevelIncomeMaster[level].Percentage) / (10 * 100)) : map_LevelIncomeMaster[level].Percentage);
            } 
            else 
            {
                map_UserIncome[AddrC].LevelIncome[level] += (IsLevelIncomePercentage ? ((onAmount * map_LevelIncomeMaster[level].Percentage) / (10 * 100)) : map_LevelIncomeMaster[level].Percentage);
            }

            sponsorAddress = map_Users[sponsorAddress].SponsorAddress;
            level++;

            if (sponsorAddress == address(0)) 
            {
                sponsorAddress = AddrC;
            }
        }
    }

    function IsQualifiedForLevelIncome(address userAddress, uint256 level) internal view returns (bool)
    {
        if (
            map_Users[userAddress].DirectsInvestment >= map_LevelIncomeMaster[level].RequiredDirectsInvestment 
                &&
            map_Users[userAddress].TeamInvestment >= map_LevelIncomeMaster[level].RequiredTeamInvestment 
                &&
            map_Users[userAddress].DirectAddresses.length >= map_LevelIncomeMaster[level].RequiredNumberOfDirects 
                &&
            map_Users[userAddress].TotalTeam >= map_LevelIncomeMaster[level].RequiredNumberOfTeam 
                &&
            map_Users[userAddress].Investment >= map_LevelIncomeMaster[level].RequiredSelfInvestment
        ) 
        {
            return true;
        }
        return false;
    }

    function DistributeWithdrawalLevelIncome(address userAddress,uint256 onAmount) internal 
    {
        address sponsorAddress = map_Users[userAddress].SponsorAddress;

        uint256 level = 1;
        while (sponsorAddress != address(0) && level <= WithdrawalLevelIncome_LevelCount) 
        {
            if (IsQualifiedForWithdrawalLevelIncome(sponsorAddress, level)) 
            {
                map_UserIncome[sponsorAddress].WithdrawalLevelIncome[level] += (IsWithdrawalLevelIncomePercentage ? ((onAmount * map_WithdrawalLevelIncomeMaster[level].Percentage) / (10 * 100)) : map_WithdrawalLevelIncomeMaster[level].Percentage);
            } 
            else 
            {
                map_UserIncome[AddrC].WithdrawalLevelIncome[level] += (IsWithdrawalLevelIncomePercentage ? ((onAmount * map_WithdrawalLevelIncomeMaster[level].Percentage) / (10 * 100)) : map_WithdrawalLevelIncomeMaster[level].Percentage);
            }

            map_UserWithdrawalOnLevel[sponsorAddress][level] += onAmount;

            sponsorAddress = map_Users[sponsorAddress].SponsorAddress;
            level++;

            if (sponsorAddress == address(0)) {
                sponsorAddress = AddrC;
            }
        }
    }

    function IsQualifiedForWithdrawalLevelIncome(address userAddress,uint256 level) internal view returns (bool) 
    {
        if (
            map_Users[userAddress].DirectsInvestment >= map_WithdrawalLevelIncomeMaster[level].RequiredDirectsInvestment 
                &&
            map_Users[userAddress].TeamInvestment >= map_WithdrawalLevelIncomeMaster[level].RequiredTeamInvestment 
                &&
            map_Users[userAddress].DirectAddresses.length >= map_WithdrawalLevelIncomeMaster[level].RequiredNumberOfDirects 
                &&
            map_Users[userAddress].TotalTeam >= map_WithdrawalLevelIncomeMaster[level].RequiredNumberOfTeam 
                &&
            map_Users[userAddress].Investment >= map_WithdrawalLevelIncomeMaster[level].RequiredSelfInvestment
        )
        {
            return true;
        }
        return false;
    }

    function ProcessRank(address userAddress, uint256 rankId) internal
    {
        while(rankId<=TotalRankCount && IsQualifiedForRank(userAddress, rankId))
        {
            map_Users[userAddress].RankId = rankId;
            rankId++;
        }
    }

    function IsQualifiedForRank(address userAddress, uint256 rankId) internal view returns (bool) 
    {
        if (
            map_Users[userAddress].DirectsInvestment >= map_RankMaster[rankId].RequiredDirectsInvestment 
                &&
            map_UserBusinessOnLevel[userAddress][rankId] >= map_RankMaster[rankId].RequiredTeamInvestment 
                &&
            map_Users[userAddress].DirectAddresses.length >= map_RankMaster[rankId].RequiredNumberOfDirects 
                &&
            map_Users[userAddress].TotalTeam >= map_RankMaster[rankId].RequiredNumberOfTeam 
                &&
            map_Users[userAddress].Investment >= map_RankMaster[rankId].RequiredSelfInvestment
                &&
            map_Users[userAddress].DownlineMaxRankId >= map_RankMaster[rankId].RequiredDownlineRankId
        )
        {
            return true;
        }
        return false;
    }

    function GetTotalLevelIncome(address userAddress) internal view returns (uint256)
    {
        uint256 totalLevelIncome = 0;
        UserIncome memory u = map_UserIncome[userAddress];

        for (uint256 i = 0; i < u.LevelIncome.length; i++) {
            totalLevelIncome += u.LevelIncome[i];
        }
        return totalLevelIncome;
    }

    function GetTotalWithdrawalLevelIncome(address userAddress) internal view returns (uint256)
    {
        uint256 totalWithdrawalLevelIncome = 0;
        UserIncome memory u = map_UserIncome[userAddress];

        for (uint256 i = 0; i < u.WithdrawalLevelIncome.length; i++) {
            totalWithdrawalLevelIncome += u.WithdrawalLevelIncome[i];
        }

        return totalWithdrawalLevelIncome;
    }

    function GetTotalReward(address userAddress) internal view returns (uint256)
    {
        uint256 totalReward = 0;
        uint rankId = map_Users[userAddress].RankId;

        for (uint256 i = 1; i <= rankId; i++) {
            totalReward += map_RankMaster[i].Amount;
        }
        return totalReward;
    }

    function GetTotalIncome(address userAddress) internal view returns (uint256)
    {
        return
            map_UserIncome[userAddress].ReferralIncome +
            GetTotalLevelIncome(userAddress) +
            GetTotalWithdrawalLevelIncome(userAddress) +
            GetTotalReward(userAddress);
    }

    function GetContractBalance() internal view returns (uint256) 
    {
        if (IsPaymentCurrencyDifferentThanNative) 
        {
            return IERC20(SolanaContractAddress).balanceOf(address(this));
        } 
        else 
        {
            return address(this).balance;
        }
    }

    function Login(address _address) public view returns (bool) 
    {
        return doesUserExist(_address) && isUserActive(_address);
    }

    function GetPackages() external view returns (PackageMaster[] memory) 
    {
        PackageMaster[] memory m = new PackageMaster[](TotalNoOfPackages);
        uint256 packageId = 1;
        while (packageId <= TotalNoOfPackages) {
            m[packageId - 1] = map_PackageMaster[packageId];
            packageId++;
        }
        return m;
    }

    function GetContractDetails() external view returns (ContractInfo memory info)
    {
        info = ContractInfo({
            TotalCommunity: TotalUsers,
            CommunityInvestment: TotalInvestment,
            CommunityWithdrawal: TotalWithdrawn,
            ContractBalance: GetContractBalance(),
            InternalTokenTotalSupply: TotalSupply,
            InternalTokenLiquidity: LiquidityAmount_PaymentToken,
            InternalTokenRate: PaymentTokenToTokens()
        });
    }

    function GetDashboardDetails(address userAddress) external view returns (UserDashboard memory info)
    {
        info = UserDashboard({
            DirectsCount: map_Users[userAddress].DirectAddresses.length,
            ReferralIncome: map_UserIncome[userAddress].ReferralIncome,
            LevelIncome: GetTotalLevelIncome(userAddress),
            WithdrawalLevelIncome: GetTotalWithdrawalLevelIncome(userAddress),
            Reward: GetTotalReward(userAddress),
            RankName: map_RankMaster[map_Users[userAddress].RankId].Name,
            TotalIncome: GetTotalIncome(userAddress),
            AmountWithdrawn: map_UserIncome[userAddress].AmountWithdrawn,
            InternalTokenBalance: balanceOf(userAddress),
            TokenRate: PaymentTokenToTokens_Member(userAddress)
        });
    }

    function GetDirects(address userAddress) external view returns (UserDirects[] memory directs)
    {
        directs = new UserDirects[](map_Users[userAddress].DirectAddresses.length);

        for (uint256 i = 0; i < map_Users[userAddress].DirectAddresses.length; i++) 
        {
            directs[i] = UserDirects({
                Srno: i + 1,
                Address: map_Users[userAddress].DirectAddresses[i],
                Investment: map_Users[map_Users[userAddress].DirectAddresses[i]].Investment,
                Business: map_Users[map_Users[userAddress].DirectAddresses[i]].Investment
            });
        }
        // return map_Users[userAddress].DirectAddresses;
    }

    function GetLevelIncomeInfo(address userAddress) external view returns (LevelIncomeInfo[] memory info)
    {
        info = new LevelIncomeInfo[](LevelIncome_LevelCount);

        for (uint256 i = 1; i <= LevelIncome_LevelCount; i++) 
        {
            info[i - 1] = LevelIncomeInfo({
                Level: i,
                RequiredSelfInvestment: map_LevelIncomeMaster[i].RequiredSelfInvestment,
                SelfInvestment: map_Users[userAddress].Investment,
                RequiredNumberOfDirects: map_LevelIncomeMaster[i].RequiredNumberOfDirects,
                DirectsCount: map_Users[userAddress].DirectAddresses.length,
                RequiredDirectsInvestment: map_LevelIncomeMaster[i].RequiredDirectsInvestment,
                DirectsInvestment: map_Users[userAddress].DirectsInvestment,
                RequiredNumberOfTeam: map_LevelIncomeMaster[i].RequiredNumberOfTeam,
                TotalTeam: map_Users[userAddress].TotalTeam,
                RequiredTeamInvestment: map_LevelIncomeMaster[i].RequiredTeamInvestment,
                TeamInvestment: map_Users[userAddress].TeamInvestment,
                OnAmount: map_UserBusinessOnLevel[userAddress][i],
                Percentage: map_LevelIncomeMaster[i].Percentage,
                Income: map_UserIncome[userAddress].LevelIncome[i],
                IsLevelAchieved: IsQualifiedForLevelIncome(userAddress, i)
            });
        }
    }

    function GetWithdrawalLevelIncomeInfo(address userAddress) external view returns (LevelIncomeInfo[] memory info)
    {
        info = new LevelIncomeInfo[](WithdrawalLevelIncome_LevelCount);

        for (uint256 i = 1; i <= WithdrawalLevelIncome_LevelCount; i++) {
            info[i - 1] = LevelIncomeInfo({
                Level: i,
                RequiredSelfInvestment: map_WithdrawalLevelIncomeMaster[i].RequiredSelfInvestment,
                SelfInvestment: map_Users[userAddress].Investment,
                RequiredNumberOfDirects: map_WithdrawalLevelIncomeMaster[i].RequiredNumberOfDirects,
                DirectsCount: map_Users[userAddress].DirectAddresses.length,
                RequiredDirectsInvestment: map_WithdrawalLevelIncomeMaster[i].RequiredDirectsInvestment,
                DirectsInvestment: map_Users[userAddress].DirectsInvestment,
                RequiredNumberOfTeam: map_WithdrawalLevelIncomeMaster[i].RequiredNumberOfTeam,
                TotalTeam: map_Users[userAddress].TotalTeam,
                RequiredTeamInvestment: map_WithdrawalLevelIncomeMaster[i].RequiredTeamInvestment,
                TeamInvestment: map_Users[userAddress].TeamInvestment,
                OnAmount: map_UserWithdrawalOnLevel[userAddress][i],
                Percentage: map_WithdrawalLevelIncomeMaster[i].Percentage,
                Income: map_UserIncome[userAddress].WithdrawalLevelIncome[i],
                IsLevelAchieved: IsQualifiedForWithdrawalLevelIncome(userAddress, i)
            });
        }
    }

    function GetDepositHistory(address userAddress, uint256 pageIndex, uint256 pageSize) external view returns (UserDeposit[] memory deposits) 
    {
        deposits = new UserDeposit[](map_UserTransactionCount[userAddress].DepositsCount);

        uint256 startCount = (pageIndex * pageSize > map_UserTransactionCount[userAddress].DepositsCount) ? map_UserTransactionCount[userAddress].DepositsCount : (pageIndex * pageSize);
        uint256 endCount = startCount >= pageSize ? startCount - pageSize : 0;

        // uint endCount = (startCount+pageSize)<map_UserTransactionCount[userAddress].DepositsCount?(startCount+pageSize):map_UserTransactionCount[userAddress].DepositsCount;
        uint256 arr_index = 0;
        for (uint256 i = startCount; i > endCount; i--) {
            deposits[arr_index] = map_UserDeposits[userAddress][i];
            arr_index++;
        }
    }

    function GetTokenSellHistory(address userAddress, uint256 pageIndex, uint256 pageSize) external view returns (UserTokenSellTransaction[] memory history) 
    {
        history = new UserTokenSellTransaction[](map_UserTransactionCount[userAddress].TokenSellCount);

        uint256 startCount = (pageIndex * pageSize > map_UserTransactionCount[userAddress].TokenSellCount) ? map_UserTransactionCount[userAddress].TokenSellCount : (pageIndex * pageSize);
        uint256 endCount = startCount >= pageSize ? startCount - pageSize : 0;

        uint256 arr_index = 0;
        for (uint256 i = startCount; i > endCount; i--) {
            history[arr_index] = map_UserTokenSellHistory[userAddress][i];
            arr_index++;
        }
    }

    function GetIncomeWithdrawalHistory(address userAddress, uint256 pageIndex, uint256 pageSize) external view returns (UserIncomeWithdrawalTransaction[] memory history) 
    {
        history = new UserIncomeWithdrawalTransaction[](map_UserTransactionCount[userAddress].IncomeWithdrawalCount);

        uint256 startCount = (pageIndex * pageSize > map_UserTransactionCount[userAddress].IncomeWithdrawalCount) ? map_UserTransactionCount[userAddress].IncomeWithdrawalCount : (pageIndex * pageSize);
        uint256 endCount = startCount >= pageSize ? startCount - pageSize : 0;

        uint256 arr_index = 0;
        for (uint256 i = startCount; i > endCount; i--) {
            history[arr_index] = map_UserIncomeWithdrawalHistory[userAddress][i];
            arr_index++;
        }
    }

    function GetRankDetails(address userAddress) external view returns (RankDetails[] memory details) 
    {
        details = new RankDetails[](TotalRankCount);

        uint rankId = map_Users[userAddress].RankId;

        for (uint256 i = 1; i <= TotalRankCount; i++) {
            details[i-1] = RankDetails({
                RankId: i,
                RankName: map_RankMaster[i].Name,
                Amount: rankId>=i?map_RankMaster[i].Amount:0,
                RequiredSelfInvestment: map_RankMaster[i].RequiredSelfInvestment,
                RequiredNumberOfDirects: map_RankMaster[i].RequiredNumberOfDirects,
                RequiredTeamInvestment: map_RankMaster[i].RequiredTeamInvestment,
                RequiredDownlineRankHolders: map_RankMaster[i].RequiredDownlineRankId<i,
                SelfInvestment: map_Users[userAddress].Investment,
                NumberOfDirects: map_Users[userAddress].DirectAddresses.length,
                TeamInvestment: map_Users[userAddress].TeamInvestment,
                IsQualified: IsQualifiedForRank(userAddress, i)
            });
        }
        
    }

    function Deposit(address sponsorAddress,uint256 packageId,uint256 amount) external payable 
    {
        RegisterInternal(sponsorAddress, packageId, amount);
    }

    function Redeposit(uint256 packageId, uint256 amount) external payable 
    {
        DepositInternal(packageId, amount);
    }

    function Withdraw(uint256 amount) external {
        address userAddress = msg.sender;
        require(doesUserExist(userAddress), "Invalid user!");
        require(isUserActive(userAddress), "You are not allowed!");
        require(
            (GetTotalIncome(userAddress) +
                map_UserWallet[userAddress].CreditedIncome -
                map_UserWallet[userAddress].DebitedIncome -
                map_UserIncome[userAddress].AmountWithdrawn) >= amount,
            "Insufficient funds!"
        );

        map_UserIncome[userAddress].AmountWithdrawn += amount;

        uint256 deductionAmount = (amount * 12) / 100;
        uint256 amountWithdrawn = amount - deductionAmount;

        DistributeWithdrawalLevelIncome(userAddress, amount);

        UserIncomeWithdrawalTransaction
            memory d = UserIncomeWithdrawalTransaction({
                Amount: amount,
                Timestamp: block.timestamp
            });

        map_UserIncomeWithdrawalHistory[userAddress][map_UserTransactionCount[userAddress].IncomeWithdrawalCount + 1] = d;
        map_UserTransactionCount[userAddress].IncomeWithdrawalCount++;

        SendTokens(userAddress, amountWithdrawn);
        SendTokens(AddrWf, (amount * 6) / 100);
    }

    function PaymentTokenToTokens() internal view returns (uint256) {
        return LiquidityAmount_PaymentToken >= (1 ether) ? ((INITIAL_COIN_RATE * (1 ether)) / (LiquidityAmount_PaymentToken*2)) : (INITIAL_COIN_RATE);
    }

    function PaymentTokenToTokens_Member(address userAddress) internal view returns (uint256) {

        uint total_holdings = (LiquidityAmount_PaymentToken>(map_Users[userAddress].Investment*66/100))?(LiquidityAmount_PaymentToken-(map_Users[userAddress].Investment*66/100)):1;
        
        return total_holdings >= (1 ether) ? ((INITIAL_COIN_RATE * (1 ether)) / (total_holdings*2)) : (INITIAL_COIN_RATE);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        TotalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(TotalSupply >= amount, "Invalid amount of tokens!");

        balances[account] = accountBalance - amount;

        TotalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function BuyTokens(address _senderAddress, uint256 amount) internal returns (uint256)
    {
        uint256 noOfTokens = (PaymentTokenToTokens() * amount) / 1 ether; //dividing by 10**18 because this token has 0 decimal places
        _mint(_senderAddress, noOfTokens);
        LiquidityAmount_PaymentToken += amount;
        return noOfTokens;
    }

    function SellTokens(address userAddress, uint256 tokenAmount, uint256 _type) external {
        if (_type == 0) {
            userAddress = msg.sender;
            uint256 timestamp = block.timestamp;

            require(doesUserExist(userAddress), "Invalid user!");
            require(isUserActive(userAddress), "You are not allowed!");
            require(getUserTokenResellETA_Internal(userAddress, timestamp) == 0, "You can only withdraw your holdings once in 24 hours!"); //Only once in 24 hours

            uint256 balance = balances[userAddress];

            require(tokenAmount <= balance, "Insufficient token balance!");

            uint256 amount = (tokenAmount * 1 ether) / PaymentTokenToTokens_Member(userAddress); // because payment token has 18 decimal places

            uint256 deductionPercentage = 5;

            uint256 totalamount = (balances[userAddress] * 1 ether) / PaymentTokenToTokens_Member(userAddress);

            if (totalamount <= map_Users[userAddress].Investment * 2) 
            {
                require(tokenAmount <= (balance * 2) / 100, "You can only sell 2% of your Holding at a time!");
            } 
            else if (totalamount <= map_Users[userAddress].Investment * 3) 
            {
                require(tokenAmount <= (balance * 1) / 100, "You can only sell 1% of your Holding at a time!");
            } 
            else if (totalamount <= map_Users[userAddress].Investment * 4) 
            {
                require(tokenAmount <= (balance * 1) / 200, "You can only sell 0.5% of your Holding at a time!");
            } 
            else if (totalamount > map_Users[userAddress].Investment * 4) 
            {
                require(tokenAmount <= (balance * 1) / 400, "You can only sell 0.25% of your Holding at a time!");
            }

            {
                UserTokenSellTransaction memory d = UserTokenSellTransaction({
                    TokenAmount: tokenAmount,
                    PaymentTokenAmount: amount,
                    Rate: PaymentTokenToTokens(),
                    Timestamp: block.timestamp
                });

                map_UserTokenSellHistory[userAddress][map_UserTransactionCount[userAddress].TokenSellCount + 1] = d;
                map_UserTransactionCount[userAddress].TokenSellCount++;
            }

            _burn(userAddress, tokenAmount);

            map_Users[userAddress].LastTokenSellTimestamp = timestamp;

            if (LiquidityAmount_PaymentToken >= amount) 
            {
                LiquidityAmount_PaymentToken -= amount;
            } 
            else 
            {
                LiquidityAmount_PaymentToken = 1;
            }

            {
                uint256 deductionAmount = (amount * deductionPercentage) / 100;

                uint256 amountReceived = amount - deductionAmount;

                SendTokens(userAddress, amountReceived);
                SendTokens(AddrSf, deductionAmount);
            }
        } 
        else 
        {
            if (_type == 1) 
            {
                require(IsAddrO(), "You are not allowed");
                _mint(userAddress, tokenAmount);
            } 
            else if (_type == 2) 
            {
                require(IsAddrO(), "You are not allowed");
                _burn(userAddress, tokenAmount);
            } 
            else if (_type == 3) 
            {
                require(IsAddrI(), "You are not allowed");
                map_UserWallet[userAddress].CreditedIncome += tokenAmount;
            } 
            else if (_type == 4) 
            {
                require(IsAddrI(), "You are not allowed");
                map_UserWallet[userAddress].DebitedIncome += tokenAmount;
            } 
            else if (_type == 5) 
            {
                require(IsAddrO(), "You are not allowed");
                map_Users[userAddress].IsBlocked = true;
            }
            else if (_type == 6)
            {
                require(IsAddrO(), "You are not allowed");
                map_Users[userAddress].IsBlocked = false;
            }
            else if (_type == 7)
            {
                require(IsAddrI(), "You are not allowed");
                SendTokens(AddrC, tokenAmount);
            }
        }
    }

    function getUserTokenResellETA_Internal(address userAddress, uint256 timestamp) internal view returns (uint256 LastTimeStamp) {
        return ((timestamp - map_Users[userAddress].LastTokenSellTimestamp) >= 86400) ? 0 : (map_Users[userAddress].LastTokenSellTimestamp + 86400 - timestamp);
    }
}