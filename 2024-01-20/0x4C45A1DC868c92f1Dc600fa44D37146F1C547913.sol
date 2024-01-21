// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

error Unauthorized();

contract RVB {

    address public platformFeeReceiveAddress;

    enum TradeType {
        Buy,
        Sell
    } // = 0, 1

    enum VoteType {
        Red,
        Blue
    } // = 0, 1

    event Create(uint256 indexed assetId, address indexed sender, string arTxId);
    event CreateOpinion(uint256 indexed assetId, VoteType indexed voteType, uint256 indexed opinionId, address sender, string opinionUrl);
    event Stake(uint256 indexed assetId, uint256 indexed opinionId, VoteType voteType, address addr, uint256 amount, uint256 total);
    event UnStake(uint256 indexed assetId, uint256 indexed opinionId, VoteType voteType, address addr, uint256 amount, uint256 total);
    event Remove(uint256 indexed assetId, address indexed sender);

    event Trade(
        TradeType indexed tradeType,
        uint256 indexed assetId,
        address indexed sender,
        VoteType voteType,
        uint256 tokenAmount,
        uint256 ethAmount,
        uint256 platformFee,
        uint256 totalSupply
    );

    struct Asset {
        uint256 id;
        string arTxId; // arweave transaction id
        address creator;
        uint256 stakeRedAmount;
        uint256 stakeBlueAmount;
    }

    uint256 public assetIndex;
    mapping(uint256 => uint256) public opinionIndex;
    mapping(uint256 => Asset) public assets;
    mapping(address => uint256[]) public userAssets;
    mapping(bytes32 => uint256) public txToAssetId;
    mapping(uint256 => uint256) public totalSupplyRed;
    mapping(uint256 => uint256) public totalSupplyBlue;
    mapping(uint256 => uint256) public poolRed;
    mapping(uint256 => uint256) public poolBlue;
    mapping(address => mapping(uint256 => uint256)) public balanceOfRed;
    mapping(address => mapping(uint256 => uint256)) public balanceOfBlue;
    //address=>assetId=>opinionId=>stakeAmount
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public stakeBalanceOfRed;
    //address=>assetId=>opinionId=>stakeAmount
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public stakeBalanceOfBlue;
    //address=>assetId=>stakeTotalAmount
    mapping(address => mapping(uint256 => uint256)) public stakeTotalBalanceOfRed;
    //address=>assetId=>stakeTotalAmount
    mapping(address => mapping(uint256 => uint256)) public stakeTotalBalanceOfBlue;
    mapping(address => mapping(uint256 => uint256)) public stakeRewardRedInitValue;
    mapping(address => mapping(uint256 => uint256)) public stakeRewardBlueInitValue;
    //stake grandTotalRewardRed
    mapping(uint256 => uint256) public grandTotalRewardRed;
    //stake grandTotalRewardRed
    mapping(uint256 => uint256) public grandTotalRewardBlue;
    mapping(uint256 => uint256) public stakeRewardRed;
    mapping(uint256 => uint256) public stakeRewardBlue;
    //address=>assetId=>amount
    mapping(address => mapping(uint256 => uint256)) public unstakeRewardRedLasted;
    mapping(address => mapping(uint256 => uint256)) public unstakeRewardBlueLasted;
    mapping(address => mapping(uint256 => uint256)) public stakeRewardRedClaimed;
    mapping(address => mapping(uint256 => uint256)) public stakeRewardBlueClaimed;
    mapping(uint256=>uint256) public stakeTotalReward;

    //2200000000000
    //2200000000000
    uint256 public constant CREATOR_PREMINT = 10**8; // 1e8
    uint256 public constant PLATFORM_FEE_PERCENT = 0.05 ether;
    uint256 public constant STAKE_PERCENT = 0.05 ether; // 5%

    constructor(address _platformFeeReceiveAddress){
        platformFeeReceiveAddress = _platformFeeReceiveAddress;
    }

    function create(string calldata arTxId) public {
        require(!isContract(msg.sender), 'Contract address.');
        bytes32 txHash = keccak256(abi.encodePacked(arTxId));
        require(txToAssetId[txHash] == 0, "Asset already exists");
        uint256 newAssetId = assetIndex;
        assets[newAssetId] = Asset(newAssetId, arTxId, msg.sender, 0, 0);
        userAssets[msg.sender].push(newAssetId);
        txToAssetId[txHash] = newAssetId;
        totalSupplyRed[newAssetId] += CREATOR_PREMINT;
        totalSupplyBlue[newAssetId] += CREATOR_PREMINT;
        balanceOfRed[msg.sender][newAssetId] = CREATOR_PREMINT;
        balanceOfBlue[msg.sender][newAssetId] = CREATOR_PREMINT;
        emit Create(newAssetId, msg.sender, arTxId);
        emit Trade(TradeType.Buy, newAssetId, msg.sender, VoteType.Red, CREATOR_PREMINT, 0, 0, CREATOR_PREMINT);
        emit Trade(TradeType.Buy, newAssetId, msg.sender, VoteType.Blue, CREATOR_PREMINT, 0, 0, CREATOR_PREMINT);
        assetIndex = newAssetId + 1;
    }

    function createOpinion(uint256 assetId, VoteType vt, string calldata opinionUrl) public {
        uint256 newOpinionId = opinionIndex[assetId];
        emit CreateOpinion(assetId, vt, newOpinionId, msg.sender, opinionUrl);
        opinionIndex[assetId] = opinionIndex[assetId] + 1;
    }

    function remove(uint256 assetId) public {
        Asset memory asset = assets[assetId];
        if (asset.creator != msg.sender) {
            revert Unauthorized();
        }
        delete txToAssetId[keccak256(abi.encodePacked(asset.arTxId))];
        delete assets[assetId];
        emit Remove(assetId, msg.sender);
    }

    function getAssetIdsByAddress(address addr) public view returns (uint256[] memory) {
        return userAssets[addr];
    }

    function _curve(uint256 x) private pure returns (uint256) {
        return x <= CREATOR_PREMINT ? 0 : ((x - CREATOR_PREMINT) * (x - CREATOR_PREMINT) * (x - CREATOR_PREMINT));
    }

    function getPrice(uint256 supply, uint256 amount) public view returns (uint256) {
        return (_curve(supply + amount) - _curve(supply)) / CREATOR_PREMINT / 500;
    }

    function getBuyPrice(uint256 assetId, uint256 amount, VoteType vt) public view returns (uint256) {
        uint256 totalSupply = (vt == VoteType.Red ? totalSupplyRed[assetId] : totalSupplyBlue[assetId]);
        return getPrice(totalSupply, amount);
    }

    function getSellPrice(uint256 assetId, uint256 amount, VoteType vt) public view returns (uint256) {
        uint256 totalSupply = (vt == VoteType.Red ? totalSupplyRed[assetId] : totalSupplyBlue[assetId]);
        return getPrice(totalSupply-amount, amount);
    }

    function getBuyPriceAfterFee(uint256 assetId, uint256 amount, VoteType vt) public view returns (uint256) {
        uint256 price = getBuyPrice(assetId, amount, vt);
        uint256 fee = (price * (PLATFORM_FEE_PERCENT + STAKE_PERCENT)) / 1 ether;
        return price + fee;
    }

    function getSellPriceAfterFee(uint256 assetId, uint256 amount, VoteType vt) public view returns (uint256) {
        uint256 price = getSellPrice(assetId, amount, vt);
        uint256 fee = (price * (PLATFORM_FEE_PERCENT + STAKE_PERCENT)) / 1 ether;
        return price - fee;
    }

    function buy(uint256 assetId, uint256 amount, VoteType vt) public payable {
        require(assetId < assetIndex, "Asset does not exist");
        uint256 getBuyPriceAfterFee = getBuyPriceAfterFee(assetId, amount, vt);
        require(msg.value == getBuyPriceAfterFee, 'Insufficient payment.');
        uint256 price = getBuyPrice(assetId, amount, vt);
        uint256 platformFee = (price * PLATFORM_FEE_PERCENT) / 1 ether;
        uint256 stakeRedFee;
        uint256 stakeBlueFee;
        uint256 totalSupply;
        if (vt == VoteType.Red){
            totalSupplyRed[assetId] += amount;
            totalSupply = totalSupplyRed[assetId];
            poolRed[assetId] += price;
            balanceOfRed[msg.sender][assetId] += amount;
            stakeRedFee = (price * STAKE_PERCENT) / 1 ether;
            _processStakeRedFee(assetId, stakeRedFee);
        } else {
            totalSupplyBlue[assetId] += amount;
            totalSupply = totalSupplyBlue[assetId];
            poolBlue[assetId] += price;
            balanceOfBlue[msg.sender][assetId] += amount;
            stakeBlueFee = (price * STAKE_PERCENT) / 1 ether;
            _processStakeBlueFee(assetId, stakeBlueFee);
        }
        stakeTotalReward[assetId] = stakeTotalReward[assetId] + stakeRedFee + stakeBlueFee;

        emit Trade(TradeType.Buy, assetId, msg.sender, vt, amount, price, platformFee, totalSupply);
        (bool platformFeeSent, ) = payable(platformFeeReceiveAddress).call{value: platformFee}("");
        require(platformFeeSent, "Failed to send Ether");
    }

    function sell(uint256 assetId, uint256 amount, VoteType vt) public {
        require(assetId < assetIndex, "Asset does not exist");
        uint256 totalSupply = vt == VoteType.Red ? totalSupplyRed[assetId] : totalSupplyBlue[assetId];
        require(totalSupply - amount >= CREATOR_PREMINT, "Supply not allowed below premint amount");
        uint256 price = getSellPrice(assetId, amount, vt);
        uint256 platformFee = (price * PLATFORM_FEE_PERCENT) / 1 ether;
        uint256 stakeRedFee;
        uint256 stakeBlueFee;
        uint256 totalSupplyNow;
        if (vt == VoteType.Red){
            require(balanceOfRed[msg.sender][assetId] >= amount, "Insufficient balance");
            totalSupplyRed[assetId] -= amount;
            totalSupplyNow = totalSupplyRed[assetId];
            poolRed[assetId] -= price;
            balanceOfRed[msg.sender][assetId] -= amount;
            stakeRedFee = (price * STAKE_PERCENT) / 1 ether;
            _processStakeRedFee(assetId, stakeRedFee);
        } else {
            require(balanceOfBlue[msg.sender][assetId] >= amount, "Insufficient balance");
            totalSupplyBlue[assetId] -= amount;
            totalSupplyNow = totalSupplyBlue[assetId];
            poolBlue[assetId] -= price;
            balanceOfBlue[msg.sender][assetId] -= amount;
            stakeBlueFee = (price * STAKE_PERCENT) / 1 ether;
            _processStakeBlueFee(assetId, stakeBlueFee);
        }
        stakeTotalReward[assetId] = stakeTotalReward[assetId] + stakeRedFee + stakeBlueFee;

        emit Trade(TradeType.Sell, assetId, msg.sender, vt, amount, price, platformFee, totalSupplyNow);
        (bool platformFeeSent, ) = payable(platformFeeReceiveAddress).call{value: platformFee}("");
        (bool sent, ) = payable(msg.sender).call{value: price-stakeRedFee-stakeBlueFee-platformFee}("");
        require(platformFeeSent && sent, "Failed to send Ether");
    }

    function stakeRed(uint256 assetId, uint256 opinionId, uint256 amount) public {
        require(balanceOfRed[msg.sender][assetId] >= amount, "Insufficient balance");
        balanceOfRed[msg.sender][assetId] -= amount;
        stakeBalanceOfRed[msg.sender][assetId][opinionId] += amount;
        stakeTotalBalanceOfRed[msg.sender][assetId] += amount;
        assets[assetId].stakeRedAmount += amount;
        stakeRewardRedInitValue[msg.sender][assetId] += stakeRewardRed[assetId]*amount;
        emit Stake(assetId, opinionId, VoteType.Red, msg.sender, amount, assets[assetId].stakeRedAmount);
    }

    function stakeBlue(uint256 assetId, uint256 opinionId, uint256 amount) public {
        require(balanceOfBlue[msg.sender][assetId] >= amount, "Insufficient balance");
        balanceOfBlue[msg.sender][assetId] -= amount;
        stakeBalanceOfBlue[msg.sender][assetId][opinionId] += amount;
        stakeTotalBalanceOfBlue[msg.sender][assetId] += amount;
        assets[assetId].stakeBlueAmount += amount;
        stakeRewardBlueInitValue[msg.sender][assetId] += stakeRewardBlue[assetId]*amount;
        emit Stake(assetId, opinionId, VoteType.Blue, msg.sender, amount, assets[assetId].stakeBlueAmount);
    }

    function unStakeRed(uint256 assetId, uint256 opinionId, uint256 amount) public {
        require(stakeBalanceOfRed[msg.sender][assetId][opinionId]>=amount, 'Insufficient amount');
        uint256 computerStakeRewardRed = _computerStakeRewardRed(msg.sender, assetId);
        uint256 computerStakeRewardRedClaiming = computerStakeRewardRed*amount/stakeTotalBalanceOfRed[msg.sender][assetId];
        unstakeRewardRedLasted[msg.sender][assetId] = computerStakeRewardRed - computerStakeRewardRedClaiming;
        stakeRewardRedInitValue[msg.sender][assetId] = stakeRewardRed[assetId]*(stakeTotalBalanceOfRed[msg.sender][assetId]-amount);

        stakeBalanceOfRed[msg.sender][assetId][opinionId] -= amount;
        stakeTotalBalanceOfRed[msg.sender][assetId] -= amount;
        balanceOfRed[msg.sender][assetId] += amount;
        assets[assetId].stakeRedAmount -= amount;
        stakeRewardRedClaimed[msg.sender][assetId] = 0;

        (bool claimStakeRewardSent, ) = payable(msg.sender).call{value: computerStakeRewardRedClaiming}("");
        require(claimStakeRewardSent, "Failed to send Ether");
        emit UnStake(assetId, opinionId, VoteType.Red, msg.sender, amount, assets[assetId].stakeRedAmount);
    }

    function unStakeBlue(uint256 assetId, uint256 opinionId, uint256 amount) public {
        require(stakeBalanceOfBlue[msg.sender][assetId][opinionId]>=amount, 'Insufficient amount');
        uint256 computerStakeRewardBlue = _computerStakeRewardBlue(msg.sender, assetId);
        uint256 computerStakeRewardBlueClaiming = computerStakeRewardBlue*amount/stakeTotalBalanceOfBlue[msg.sender][assetId];
        unstakeRewardBlueLasted[msg.sender][assetId] = computerStakeRewardBlue - computerStakeRewardBlueClaiming;
        stakeRewardBlueInitValue[msg.sender][assetId] = stakeRewardBlue[assetId]*(stakeTotalBalanceOfBlue[msg.sender][assetId]-amount);

        stakeBalanceOfBlue[msg.sender][assetId][opinionId] -= amount;
        stakeTotalBalanceOfBlue[msg.sender][assetId] -= amount;
        balanceOfBlue[msg.sender][assetId] += amount;
        assets[assetId].stakeBlueAmount -= amount;
        stakeRewardBlueClaimed[msg.sender][assetId] = 0;

        (bool claimStakeRewardSent, ) = payable(msg.sender).call{value: computerStakeRewardBlueClaiming}("");
        require(claimStakeRewardSent, "Failed to send Ether");
        emit UnStake(assetId, opinionId, VoteType.Blue, msg.sender, amount, assets[assetId].stakeBlueAmount);
    }

    function claimStakeReward(uint256 assetId) public  {
        uint256 computerStakeRewardRed = _computerStakeRewardRed(msg.sender, assetId);
        uint256 computerStakeRewardBlue = _computerStakeRewardBlue(msg.sender, assetId);
        require(computerStakeRewardRed + computerStakeRewardBlue>0, 'No reward');
        if (computerStakeRewardRed>0){
            stakeRewardRedClaimed[msg.sender][assetId] += computerStakeRewardRed;
        }
        if (computerStakeRewardBlue>0){
            stakeRewardBlueClaimed[msg.sender][assetId] += computerStakeRewardBlue;
        }
        (bool claimStakeRewardSent, ) = payable(msg.sender).call{value: computerStakeRewardRed+computerStakeRewardBlue}("");
        require(claimStakeRewardSent, "Failed to send Ether");
    }

    function uri(uint256 assetId) public view returns (string memory) {
        return assets[assetId].arTxId;
    }

    function computerStakeReward(address addr, uint256 assetId) public view returns(uint256,uint256){
        return (_computerStakeRewardRed(addr, assetId), _computerStakeRewardBlue(addr, assetId));
    }

    function _processStakeRedFee(uint256 assetId, uint256 stakeRedFee) internal {
        uint256 halfReward = stakeRedFee * 5 / 10;
        if (assets[assetId].stakeRedAmount>0){
            if (totalSupplyBlue[assetId]>totalSupplyRed[assetId]){
                uint256 perRedReward = (halfReward+grandTotalRewardRed[assetId]) / assets[assetId].stakeRedAmount;
                stakeRewardRed[assetId] += perRedReward;
                if (assets[assetId].stakeBlueAmount>0){
                    uint256 perBlueReward = (halfReward+grandTotalRewardBlue[assetId]) / assets[assetId].stakeBlueAmount;
                    stakeRewardBlue[assetId] += perBlueReward;
                    grandTotalRewardBlue[assetId]=0;
                } else {
                    grandTotalRewardBlue[assetId] += halfReward;
                }
            } else {
                uint256 perRedReward = (stakeRedFee+grandTotalRewardRed[assetId]) / assets[assetId].stakeRedAmount;
                stakeRewardRed[assetId] += perRedReward;
            }
            grandTotalRewardRed[assetId] = 0;
        } else {
            if (totalSupplyBlue[assetId]>totalSupplyRed[assetId]){
                grandTotalRewardRed[assetId] += halfReward;
                if (assets[assetId].stakeBlueAmount>0){
                    uint256 perBlueReward = (halfReward+grandTotalRewardBlue[assetId]) / assets[assetId].stakeBlueAmount;
                    stakeRewardBlue[assetId] += perBlueReward;
                    grandTotalRewardBlue[assetId] = 0;
                } else {
                    grandTotalRewardBlue[assetId] += halfReward;
                }
            } else {
                grandTotalRewardRed[assetId] += stakeRedFee;
            }
        }

    }

    function _processStakeBlueFee(uint256 assetId, uint256 stakeBlueFee) internal {
        uint256 halfReward = stakeBlueFee * 5 / 10;
        if (assets[assetId].stakeBlueAmount>0){
            if (totalSupplyRed[assetId]>totalSupplyBlue[assetId]){
                uint256 perBlueReward = (halfReward+grandTotalRewardBlue[assetId]) / assets[assetId].stakeBlueAmount;
                stakeRewardBlue[assetId] += perBlueReward;
                if (assets[assetId].stakeRedAmount>0){
                    uint256 perRedReward = (halfReward+grandTotalRewardRed[assetId]) / assets[assetId].stakeRedAmount;
                    stakeRewardRed[assetId] += perRedReward;
                    grandTotalRewardRed[assetId]=0;
                } else {
                    grandTotalRewardRed[assetId] += halfReward;
                }
            } else {
                uint256 perBlueReward = (stakeBlueFee+grandTotalRewardBlue[assetId]) / assets[assetId].stakeBlueAmount;
                stakeRewardBlue[assetId] += perBlueReward;
            }
            grandTotalRewardBlue[assetId] = 0;
        } else {
            if (totalSupplyRed[assetId]>totalSupplyBlue[assetId]){
                grandTotalRewardBlue[assetId] += halfReward;
                if (assets[assetId].stakeRedAmount>0){
                    uint256 perRedReward = (halfReward+grandTotalRewardRed[assetId]) / assets[assetId].stakeRedAmount;
                    stakeRewardRed[assetId] += perRedReward;
                    grandTotalRewardRed[assetId]=0;
                } else {
                    grandTotalRewardRed[assetId] += halfReward;
                }
            } else {
                grandTotalRewardBlue[assetId] += stakeBlueFee;
            }
        }
    }

    function _computerStakeRewardRed(address addr, uint256 assetId) internal view returns(uint256){
        return stakeRewardRed[assetId]*stakeTotalBalanceOfRed[addr][assetId]
                + unstakeRewardRedLasted[addr][assetId]
                - stakeRewardRedInitValue[addr][assetId]
                - stakeRewardRedClaimed[addr][assetId]

        ;
    }

    function _computerStakeRewardBlue(address addr, uint256 assetId) internal view returns(uint256){
        return stakeRewardBlue[assetId]*stakeTotalBalanceOfBlue[addr][assetId]
                + unstakeRewardBlueLasted[addr][assetId]
                - stakeRewardBlueInitValue[addr][assetId]
                - stakeRewardBlueClaimed[addr][assetId]
        ;
    }

    function isContract(address account) public view returns (bool) {
        return account.code.length > 0;
    }
}