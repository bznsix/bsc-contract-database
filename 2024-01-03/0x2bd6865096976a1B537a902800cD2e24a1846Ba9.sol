// SPDX-License-Identifier: BUSL-1.1
//version 26.0
//0x03eB7Fe6801893F6006127B5248809e8CFbdd89D
//0x98f4cffad363ecdd0c34a6df87fef1101655477d

//BSC TESTNET
//0xc5bB1119Df3BEf3AF379Eb72a2e7246e712ef782
//0x2bd6865096976a1B537a902800cD2e24a1846Ba9 brave ac2
//0xb1dD28f7b36ceC099d36F5432C004872eC09115b brave ac2
//0x68fF7fFcc9C53558f687eA2ED7F7E28268000278 fire ac2


//BSC MAINNET
//0x2bd6865096976a1B537a902800cD2e24a1846Ba9 brave ac2



pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";


import "https://github.com/BetterSmartContract/BetterV0/blob/main/BettingOracle_ChainLink.sol";

contract BettingContract {
    address public developer;

    BettingOracle_ChainLink public better_oracle;

    struct SupportedToken {
        uint256 id;
        address token;
        uint256 decimails;
        bool valid;
        address oracle_address;
    }

    struct Bet {
        uint256 bet_id;
        uint256 betting_id;
        address user;
        uint256 predictedPrice;
        uint256 amount;
        bool winner;
        bool claimed;
        bool rebeted;
        uint256 winningsRatio;
        uint256 winningsAmount;
    }

    enum Status {
        Open,
        Pending,
        Closed
    }

    Status constant default_value = Status.Open;

    struct Betting {
        uint256 id;
        address token;
        address creater;
        uint256 startTime;
        uint256 endTime;
        uint256 pendingTime;
        uint256 correctPrice;
        uint256 totalBets;
        uint256 totalAmount;
        Status status;
        bool hadWinner;
    }

    uint256 public bettingCount;
    uint256 public betCount;
    uint256 public SupportedTokenCount;
    mapping(uint256 => Betting) public bettings;
    mapping(uint256 => Bet) public bets;
    mapping(uint256 => SupportedToken) public supported_tokens;

    

    event SupportedTokenAdded(
        uint256 id,
        address token,
        address oracle_address
    );
    event BettingCreated(
        uint256 id,
        address token,
        address creater,
        uint256 startTime,
        uint256 endTime,
        uint256 pendingTime,
        bool hadWinner
    );
    event BetPlaced(
        uint256 bet_id,
        uint256 betting_id,
        address user,
        uint256 predictedPrice,
        uint256 amount,
        bool winner,
        bool claimed,
        bool rebeted,
        uint256 winningsRatio,
        uint256 winningsAmount
    );
    event BettingClosed(uint256 id, uint256 correctPrice);
    event WinningClaimed(address user, uint256 amount);

    //timeLeap
    //1209600 = 14 days
    //604800 = 7 days
    //1080 = 18 minutes
    //720 = 12 minutes
    //360 = 6 minutes
    //60 = 1 minute

    uint256 timeLeap_start = 60;
    uint256 public timeLeap_end;
    uint256 public timeLeap_pending;

    uint256 public fee_percentage; // 4 = 4%
    uint256 public range_percentage; // 6 = 6%
    uint256 ratio_decimails; //10 ** 18 = 1000000000000000000


    constructor(uint256 in_timeLeap_end, uint256 in_timeLeap_pending, uint256 in_fee_percentage, uint256 in_range_percentage, uint256 in_ratio_decimails) {

        developer = msg.sender;
        timeLeap_end = in_timeLeap_end;
        timeLeap_pending = in_timeLeap_pending;

        fee_percentage = in_fee_percentage;
        range_percentage = in_range_percentage;
        ratio_decimails = in_ratio_decimails;

    }

    /**
     * to update timeLeap
     */
    function update_timeLeap(uint256 in_timeLeap_end, uint256 in_timeLeap_pending) public {
        require(
            developer == msg.sender,
            "only developer can update timeLeap"
        );
        
        timeLeap_end = in_timeLeap_end;
        timeLeap_pending = in_timeLeap_pending;
    }
        

    /**
     * to add supported token for betting
     */
    function AddSupportedToken(
        address token_address,
        uint256 decimails,
        address oracle_address
    ) public returns (bool) {
        require(
            developer == msg.sender,
            "only developer can add supported tokens @ AddSupportedToken()"
        );
        bool newToken = true;

        for (uint256 i = 0; i <= SupportedTokenCount; i++) {
            if (supported_tokens[i].token == token_address) {
                newToken = false;
            }
        }

        if (newToken) {
            SupportedTokenCount++;

            SupportedToken storage newSupportedToken = supported_tokens[
                SupportedTokenCount
            ];
            newSupportedToken.id = SupportedTokenCount;
            newSupportedToken.token = token_address;
            newSupportedToken.decimails = decimails;
            newSupportedToken.valid = true;
            newSupportedToken.oracle_address = oracle_address;

            emit SupportedTokenAdded(
                SupportedTokenCount,
                token_address,
                oracle_address
            );
        }

        return newToken;
    }

    /**
     * to update supported token at supported_tokens[]
     */
    function UpdateSupportedToken(
        uint256 id,
        address token_address,
        bool valid,
        address oracle_address
    ) public {
        require(
            developer == msg.sender,
            "only developer can update supported tokens @ UpdateSupportedToken()"
        );
        require(
            supported_tokens[id].token == token_address,
            "token address is not matched @ UpdateSupportedToken()"
        );

        supported_tokens[id].oracle_address = oracle_address;
        supported_tokens[id].valid = valid;
    }

    /**
     * main function
     * to create Betting for Bet
     * endTime means due time of predict price
     */
    function CreateBetting(
        address token_address,
        uint256 endTime
    ) public returns (uint256) {

        uint256 startTime = block.timestamp + timeLeap_start;

        require(
            startTime >= block.timestamp,
            "Betting cannot start in the past @ CreateBetting()"
        );

        uint256 check_endTime = endTime - timeLeap_end;
        require(check_endTime > startTime, "Invalid end time (endTime < startTime) @ CreateBetting()");

        uint256 pendingTime = endTime - timeLeap_pending;
        require(pendingTime > startTime, "Invalid pending time (pendingTime < startTime) @ CreateBetting()");
   

        address creater = msg.sender;
        bettingCount++;

        bool supportedToken = false;

        for (uint256 i = 0; i <= SupportedTokenCount; i++) {
            if (
                supported_tokens[i].token == token_address &&
                supported_tokens[i].valid == true
            ) {
                supportedToken = true;
            }
        }

        require(
            supportedToken == true,
            "token address not supported! @ CreateBetting()"
        );

        Betting storage newBetting = bettings[bettingCount];
        newBetting.token = token_address;
        newBetting.creater = creater;
        newBetting.id = bettingCount;
        newBetting.startTime = startTime;
        newBetting.endTime = endTime;
        newBetting.pendingTime = pendingTime;
        newBetting.correctPrice = 0;
        newBetting.totalBets = 0;
        newBetting.totalAmount = 0;
        newBetting.status = Status.Open;
        newBetting.hadWinner = false;

        emit BettingCreated(
            bettingCount,
            token_address,
            creater,
            startTime,
            endTime,
            pendingTime,
            false
        );

        return bettingCount;
    }

    /**
     * main function
     * to create Bets
     */
    function CreateBet(
        address token_address,
        uint256 betting_id,
        uint256 predictedPrice,
        uint256 amount
    ) public returns (uint256) {
        require(
            token_address == bettings[betting_id].token,
            "incompatible token address @ CreateBet()"
        );
        /*
        require(
            betting_id > 0 && betting_id <= bettingCount,
            "Invalid betting ID @ CreateBet()"
        );
        */
        require(
            bettings[betting_id].status == Status.Open,
            "Betting is not open for bets @ CreateBet()"
        );
        require(
            block.timestamp < bettings[betting_id].pendingTime,
            "Betting is closed for new bets @ CreateBet()"
        );
        require(amount > 0, "Invalid bet amount @ CreateBet()");

        (
            uint256 bet_id_in_current_betting_id,
            uint256 bet_id_in_all_bet_list
        ) = bet_id_by_user(betting_id, msg.sender);
        require(bet_id_in_all_bet_list == 0, "wrong betting id @ CreateBet()");
        require(
            bet_id_in_current_betting_id == 0,
            "You already bed on this betting! @ CreateBet()"
        );

        IERC20 token = IERC20(token_address);
        require(
            token.balanceOf(msg.sender) >= amount,
            "Insufficient token balance @ CreateBet()"
        );
        require(
            token.approve(address(this), amount),
            "Not approving token transfer! @ CreateBet()"
        );
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed @ CreateBet()"
        );

        uint256 total_fee = FeeCollector(
                betting_id,
                amount
            );

        uint256 new_bet_amount = amount - total_fee;

        betCount++;

        uint256 currrent_bet_length = bet_length(betting_id);
        uint256 new_bet_id = currrent_bet_length + 1;

        bettings[betting_id].totalBets++;
        bettings[betting_id].totalAmount += new_bet_amount;

        Bet storage newBet = bets[betCount];
        newBet.bet_id = new_bet_id;
        newBet.betting_id = betting_id;
        newBet.user = msg.sender;
        newBet.predictedPrice = predictedPrice;
        newBet.amount = new_bet_amount;
        newBet.winner = false;
        newBet.claimed = false;
        newBet.rebeted = false;
        newBet.winningsRatio = 0;
        newBet.winningsAmount = 0;

        emit BetPlaced(
            new_bet_id,
            betting_id,
            msg.sender,
            predictedPrice,
            amount,
            false,
            false,
            false,
            0,
            0
        );

        return betCount;
    }

    /**
     * all betters can close betting if betting is passing pending time
     * loop current betting by betting id to calculate winners
     */
    function CloseBetting(uint256 _betting_id) public {
        (
            ,
            uint256 bet_id_in_all_bet_list
        ) = bet_id_by_user(_betting_id, msg.sender);

        bool better = false;
        Betting storage betting = bettings[_betting_id];

        if (bets[bet_id_in_all_bet_list].betting_id == _betting_id && bets[bet_id_in_all_bet_list].amount > 0 ) {
            better = true;
        }
        
        if( betting.creater == msg.sender){
            better = true;
        }

        require(
            better == true,
            "only betters or creater can close betting @ CloseBetting()"
        );

        require(
            betting.status == Status.Open,
            "Betting is not open @ CloseBetting()"
        );
        require(
            block.timestamp >= betting.pendingTime,
            "Betting pendingTime has not passed yet @ CloseBetting()"
        );
        require(
            block.timestamp >= betting.endTime,
            "Betting endTime has not passed yet @ CloseBetting()"
        );

        uint256 token_decimails;
        address oracle_address;

        // get token decimals
        for (uint256 i = 0; i <= SupportedTokenCount; i++) {
            if (
                supported_tokens[i].token == betting.token &&
                supported_tokens[i].valid == true
            ) {
                token_decimails = supported_tokens[i].decimails;
                oracle_address = supported_tokens[i].oracle_address;
            }
        }

        better_oracle = BettingOracle_ChainLink(oracle_address);

        (uint256 _correctPrice, ) = better_oracle
            .fetch_closest_price_to_timestamp(
                betting.token,
                betting.endTime,
                token_decimails
            );

        //to do: use oracle to replace this line
        bettings[_betting_id].correctPrice = _correctPrice;

        bool hasWinner = false;

        uint256 all_winner_bet_amount = 0;

        uint256 correct_price_range = (_correctPrice * range_percentage) / 200;

        uint256 correct_price_upper_bond = _correctPrice + correct_price_range;

        uint256 correct_price_lower_bond = _correctPrice - correct_price_range;

        //loop current betting to calculate winners
        for (uint256 i = 0; i <= betCount; i++) {
            if (bets[i].betting_id == _betting_id) {
                if (bets[i].amount != 0) {
                    // meet the price range
                    if (
                        bets[i].predictedPrice >= correct_price_lower_bond &&
                        bets[i].predictedPrice <= correct_price_upper_bond
                    ) {
                        bets[i].winner = true;
                        hasWinner = true;

                        all_winner_bet_amount += bets[i].amount;
                    }
                }
            }
        }

        //loop current betting to calculate winning ratio and winning amount
        if (hasWinner == true) {
            for (uint256 i = 0; i <= betCount; i++) {
                if (bets[i].betting_id == _betting_id) {
                    if (bets[i].winner == true) {
                        //uint256 winnings_ratio = (bets[i].amount * ratio_decimails )/ all_winner_bet_amount;

                        //bets[i].winningsRatio = (bets[i].amount * ratio_decimails )/ all_winner_bet_amount;
                        //bets[i].winningsAmount = (((bets[i].amount * ratio_decimails )/ all_winner_bet_amount) * (bettings[_betting_id].totalAmount - all_winner_bet_amount)) / ratio_decimails;
                        bets[i].winningsRatio = calculate_winningsRatio(
                            i,
                            all_winner_bet_amount
                        );
                        bets[i].winningsAmount = calculate_winningsAmount(
                            _betting_id,
                            i,
                            all_winner_bet_amount
                        );
                    }
                }
            }
        }

        //betting is closed, waiting for user to claim winnings
        betting.status = Status.Pending;
        betting.hadWinner = hasWinner;
    }

    /**
     * calculate_winningsRatio for CloseBetting(uint256 _betting_id)
     */
    function calculate_winningsRatio(
        uint256 bet_id,
        uint256 all_winner_bet_amount
    ) private view returns (uint256) {
        return (bets[bet_id].amount * ratio_decimails) / all_winner_bet_amount;
    }

    /**
     * calculate_winningsAmount for CloseBetting(uint256 _betting_id)
     */
    function calculate_winningsAmount(
        uint256 _betting_id,
        uint256 bet_id,
        uint256 all_winner_bet_amount
    ) private view returns (uint256) {
        return
            (((bets[bet_id].amount * ratio_decimails) / all_winner_bet_amount) *
                (bettings[_betting_id].totalAmount - all_winner_bet_amount)) /
            ratio_decimails;
    }

    /**
     * if betting has no winners, all better can not claims
     * if betting has winner, only winners can claims
     */
    function WinningClaims(address token_address, uint256 _bettingId) public {
        (
            uint256 bet_id_in_current_betting_id,
            uint256 bet_id_in_all_bet_list
        ) = bet_id_by_user(_bettingId, msg.sender);

        require(
            bet_id_in_all_bet_list > 0,
            "wrong bet id in bet list @ WinningClaims()"
        );
        require(
            bet_id_in_current_betting_id > 0,
            "wrong bet id in betting list @ WinningClaims()"
        );
        require(
            bets[bet_id_in_all_bet_list].betting_id == _bettingId,
            "wrong betting id @ WinningClaims()"
        );

        require(
            bettings[_bettingId].status == Status.Pending,
            "Betting is not pending @ WinningClaims()"
        );

        require(
            bettings[_bettingId].hadWinner == true,
            "This betting has no winner. @ WinningClaims()"
        );

        require(
            bets[bet_id_in_all_bet_list].user == msg.sender,
            "You did not bet on this betting. @ WinningClaims()"
        );
        require(
            bets[bet_id_in_all_bet_list].winner == true,
            "You did not win over this bet. @ WinningClaims()"
        );

        uint256 winnings = bets[bet_id_in_all_bet_list].winningsAmount;
        uint256 bet_amount = bets[bet_id_in_all_bet_list].amount;
        uint256 transfer_amount = winnings + bet_amount;
        /*
        require(
            transfer_amount > 0,
            "Your winning amount is zero. @ WinningClaims()"
        );
        */
        require(
            bets[bet_id_in_all_bet_list].claimed == false,
            "You have already claimed your winnings. @ WinningClaims()"
        );
        require(
            bets[bet_id_in_all_bet_list].rebeted == false,
            "You have already rebeted your winnings. @ WinningClaims()"
        );

        if (transfer_amount > 0) {

            IERC20 token = IERC20(token_address);

            token.transfer(msg.sender, transfer_amount);

            bets[bet_id_in_all_bet_list].claimed = true;

            emit WinningClaimed(msg.sender, transfer_amount);
        }
    }

    /**
     * if betting has no winners, all better can rebet
     * if betting has winner, only winners can rebet
     */
    function ReBet(
        address token_address,
        uint256 _originalbetting_bettingId,
        uint256 _newbetting_bettingId,
        uint256 predictedPrice
    ) public returns (bool) {
        (
            uint256 bet_id_in_current_betting_id,
            uint256 bet_id_in_all_bet_list
        ) = bet_id_by_user(_originalbetting_bettingId, msg.sender);
        require(
            bet_id_in_all_bet_list > 0,
            "wrong bet id in bet list @ ReBet()"
        );
        require(
            bet_id_in_current_betting_id > 0,
            "wrong bet id in betting list @ ReBet()"
        );
        require(
            bets[bet_id_in_all_bet_list].betting_id ==
                _originalbetting_bettingId,
            "wrong betting id @ ReBet()"
        );

        require(
            bettings[_originalbetting_bettingId].status == Status.Pending,
            "Betting is not pending @ ReBet()"
        );
        require(
            bettings[_originalbetting_bettingId].token == token_address,
            "incompatible token address for _originalbetting_bettingId @ ReBet()"
        );

        require(
            bets[bet_id_in_all_bet_list].user == msg.sender,
            "You did not bet on this betting. @ ReBet()"
        );
        require(
            bets[bet_id_in_all_bet_list].claimed == false,
            "You have already claimed your winnings. @ ReBet()"
        );
        require(
            bets[bet_id_in_all_bet_list].rebeted == false,
            "You have already rebeted your winnings. @ ReBet()"
        );

        uint256 rebet_amount = 0;

        if (bettings[_originalbetting_bettingId].hadWinner == true) {
            require(
                bets[bet_id_in_all_bet_list].winner == true,
                "Only winner can rebet. @ ReBet()"
            );
            //only winner can rebet
            uint256 winnings = bets[bet_id_in_all_bet_list].winningsAmount;
            uint256 bet_amount = bets[bet_id_in_all_bet_list].amount;
            rebet_amount = winnings + bet_amount;
        } else {
            // if betting has no winners, all better can rebet
            rebet_amount = bets[bet_id_in_all_bet_list].amount;
        }

        require(
            rebet_amount > 0,
            "You don't have enough amount to rebet @ ReBet()"
        );

        if (rebet_amount > 0) {

            uint256 new_bet_length = CreateBet(
                token_address,
                _newbetting_bettingId,
                predictedPrice,
                rebet_amount
            );

            if (new_bet_length > bet_id_in_all_bet_list) {
                bets[bet_id_in_all_bet_list].rebeted = true;

                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * total fee eaquals 2 times of fee_percentage for betting creater and developer
     */
    function FeeCollector(
        uint256 _bettingId,
        uint256 amount
    ) private returns (uint256) {
       

        address token_address = bettings[_bettingId].token;

        IERC20 token = IERC20(token_address);

        uint256 fee = (amount * fee_percentage) / 100;

        address recipient = bettings[_bettingId].creater;

        //fee for betting creater
        token.transferFrom(msg.sender, recipient, fee/2);

        //fee for developer
        token.transferFrom(msg.sender, developer, fee/2);

        return fee;
    }

    /**
    return last uint256 key index of bet from indicated bettingId
    */
    function bet_length(uint256 _bettingId) public view returns (uint256) {
        uint256 currentBetting_bet_length = bettings[_bettingId].totalBets;

        return currentBetting_bet_length;
    }

    /**
    return uint256 key index of specific bet from indicated bettingId
    */
    function bet_id_by_user(
        uint256 _bettingId,
        address user
    ) public view returns (uint256, uint256) {
        uint256 bet_id_in_all_bet_list = 0;
        uint256 bet_id_in_current_betting_id = 0;

        for (uint256 i = 0; i <= betCount; i++) {
            if (bets[i].betting_id == _bettingId) {
                if (bets[i].user == user) {
                    bet_id_in_all_bet_list = i;
                    bet_id_in_current_betting_id = bets[i].bet_id;
                    break;
                }
            }
        }
        return (bet_id_in_current_betting_id, bet_id_in_all_bet_list);
    }
    

    

    /**
     * to render all bettings
     *
     * return Betting [] in reverse index
     * return Betting [] length
     */
    function render_bettings() public view returns (Betting[] memory, uint256) {
        Betting[] memory allBettings = new Betting[](bettingCount);

        uint256 k = 0;

        for (uint256 i = bettingCount; i > 0; i--) {
            allBettings[k] = bettings[i];
            k++;
        }

        return (allBettings, k);
    }

    /**
     * to render betting of specific betting id
     * parameter:
     * uint256 _betting_id
     * return Betting []
     */
    function render_betting_data_of_specific_betting_id(
        uint256 _betting_id
    ) public view returns (Betting[] memory) {

        Betting[] memory thisBetting = new Betting[](1);

        uint _length = bettingCount;

        for (uint256 i = _length; i > 0; i--) {

            if (bettings[i].id == _betting_id) {
                thisBetting[0] = bettings[i];
                break;
            }

        }

        return thisBetting;

    }

     /**
     * to render bettings of specific bet creater
     * parameter:
     * address _user
     * return Betting [] in reverse index
     * return Betting [] length
     */
    function render_bettings_of_specific_betting_creater( address _creater ) public view returns (Betting[] memory, uint256) {
        uint256 current_bettings_length = 0;

        uint _length = bettingCount;

        for (uint256 i = 0; i <= _length; i++) {
            if (bettings[i].creater == _creater) {
                current_bettings_length++;
            }
        }

        Betting[] memory myBettings = new Betting[](current_bettings_length);

        uint256 render_count = 0;
        uint256 k = 0;

        for (uint256 i = _length; i > 0; i--) {
            if (bettings[i].creater == _creater) {
                myBettings[k] = bettings[i];
                render_count++;
                k++;
            }

            if (render_count >= current_bettings_length) {
                break;
            }
        }

        return (myBettings, k);
    }

    /**
     * to render bets of specific betting id
     * parameter:
     * uint256 _betting_id
     * return Bet [] in reverse index
     * return Bet [] length
     */
    function render_bets_of_specific_betting_id(
        uint256 _betting_id
    ) public view returns (Bet[] memory, uint256) {
        uint256 current_bets_length = 0;

        uint _length = betCount;

        for (uint256 i = 0; i <= _length; i++) {
            if (bets[i].betting_id == _betting_id) {
                current_bets_length++;
            }
        }

        Bet[] memory allBets = new Bet[](current_bets_length);

        uint256 render_count = 0;
        uint256 k = 0;

        //for (uint256 i = _shifts; i < betCount; i++){
        for (uint256 i = _length; i > 0; i--) {
            if (bets[i].betting_id == _betting_id) {
                allBets[k] = bets[i];
                render_count++;
                k++;
            }

            if (render_count >= current_bets_length) {
                break;
            }
        }

        return (allBets, k);
    }

    /**
     * to render bets of specific bet creater
     * parameter:
     * address _user
     * return Bet [] in reverse index
     * return Bet [] length
     */
    function render_bets_of_specific_bet_creater(
        address _user
    ) public view returns (Bet[] memory, uint256) {
        uint256 current_bets_length = 0;

        uint _length = betCount;

        for (uint256 i = 0; i <= _length; i++) {
            if (bets[i].user == _user) {
                current_bets_length++;
            }
        }

        Bet[] memory allBets = new Bet[](current_bets_length);

        uint256 render_count = 0;
        uint256 k = 0;

        //for (uint256 i = _shifts; i < betCount; i++){
        for (uint256 i = _length; i > 0; i--) {
            if (bets[i].user == _user) {
                allBets[k] = bets[i];
                render_count++;
                k++;
            }

            if (render_count >= current_bets_length) {
                break;
            }
        }

        return (allBets, k);
    }

    
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BettingOracle_ChainLink {
    address public developer;

    AggregatorV3Interface internal priceFeed;

    struct ChainLink_Price_Feed_Contract_Addresses {
        uint256 id;
        address token_address;
        address ENS_address;
        AggregatorV3Interface this_priceFeed;
        uint ENS_address_decimails;
        bool valid;
    }

    mapping(uint256 => ChainLink_Price_Feed_Contract_Addresses)
        public token_address_in_contract_addresses;

    uint256 public ContractAddresses_Id;
    uint256 public current_ContractAddresses_Id;

    /*
    struct TokenPrice {
        uint256 id;
        address token_address;
        address ENS_address;
        uint80 roundID;
        uint256 Timestamp;
        int price;
    }

    mapping(uint256 => TokenPrice) public Token_Price;  

    uint256 public TokenPrice_Id;
    */
    uint public returned_target_price;
    int256 public target_price;
    uint80 public target_roundID;

    /**
     * Network: Sepolia
     * Aggregator: ETH/USD
     * Address:	0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */
    /**
     * Network: Sepolia
     * Aggregator: USDC / USD
     * Address: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
     */
    constructor() {
        developer = msg.sender;
    }

    /**
     * to add ChainLink ENS address into struct ChainLink_Price_Feed_Contract_Addresses.
     * parameters:
     * token_address:supported ERC20 token.
     * ENS_address: https://docs.chain.link/data-feeds/price-feeds/addresses
     */
    function add_ENS_address(
        address token_address,
        address ENS_address
    ) public returns (uint256) {
        require(developer == msg.sender, "only developer can add ENS address!");

        ContractAddresses_Id++;

        AggregatorV3Interface this_priceFeed = AggregatorV3Interface(
            ENS_address
        );

        uint ENS_address_decimails = this_priceFeed.decimals();

        ChainLink_Price_Feed_Contract_Addresses
            storage new_ChainLink_Price_Feed_Contract_Addresses = token_address_in_contract_addresses[
                ContractAddresses_Id
            ];
        new_ChainLink_Price_Feed_Contract_Addresses.id = ContractAddresses_Id;
        new_ChainLink_Price_Feed_Contract_Addresses
            .token_address = token_address;
        new_ChainLink_Price_Feed_Contract_Addresses.ENS_address = ENS_address;
        new_ChainLink_Price_Feed_Contract_Addresses
            .this_priceFeed = this_priceFeed;
        new_ChainLink_Price_Feed_Contract_Addresses
            .ENS_address_decimails = ENS_address_decimails;
        new_ChainLink_Price_Feed_Contract_Addresses.valid = true;

        return ContractAddresses_Id;
    }

    /**
     * to set ChainLink ENS address for current price feed query of indicated token address.
     * parameters:
     * token_address:supported ERC20 token address in struct ChainLink_Price_Feed_Contract_Addresses.
     * returns: AggregatorV3Interface object
     */
    function set_ENS_address(
        address token_address
    ) public returns (AggregatorV3Interface) {
        if (
            current_ContractAddresses_Id != 0 &&
            token_address_in_contract_addresses[current_ContractAddresses_Id]
                .token_address ==
            token_address
        ) {
            return
                token_address_in_contract_addresses[
                    current_ContractAddresses_Id
                ].this_priceFeed;
        } else {
            bool priceFeed_exist = false;

            for (uint256 i = 0; i <= ContractAddresses_Id; i++) {
                if (
                    token_address_in_contract_addresses[i].token_address ==
                    token_address &&
                    token_address_in_contract_addresses[i].valid == true
                ) {
                    priceFeed = token_address_in_contract_addresses[i]
                        .this_priceFeed;
                    current_ContractAddresses_Id = i;
                    priceFeed_exist = true;
                }
            }

            require(
                priceFeed_exist == true,
                "token address is not supported @ set_ENS_address()!"
            );

            return priceFeed;
        }
    }

    /**
     * to update ChainLink ENS address in struct ChainLink_Price_Feed_Contract_Addresses.
     * parameters:
     * id: id of ChainLink_Price_Feed_Contract_Addresses
     * token_address:supported ERC20 token in the ChainLink_Price_Feed_Contract_Addresses.
     * ENS_address: https://docs.chain.link/data-feeds/price-feeds/addresses
     * valid: valid or not for this address in the ChainLink_Price_Feed_Contract_Addresses.
     */
    function update_ENS_address(
        uint256 id,
        address token_address,
        address ENS_address,
        bool valid
    ) public {
        require(
            developer == msg.sender,
            "only developer can update ENS address!"
        );

        AggregatorV3Interface this_priceFeed = AggregatorV3Interface(
            ENS_address
        );

        uint ENS_address_decimails = this_priceFeed.decimals();

        token_address_in_contract_addresses[id].token_address = token_address;
        token_address_in_contract_addresses[id].ENS_address = ENS_address;
        token_address_in_contract_addresses[id].this_priceFeed = this_priceFeed;
        token_address_in_contract_addresses[id]
            .ENS_address_decimails = ENS_address_decimails;
        token_address_in_contract_addresses[id].valid = valid;
    }

    /**
     * Returns the round data.
     */
    function getRoundData(
        uint80 _roundId
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        // prettier-ignore
        (
            uint80 roundID,
            int256 answer,
            uint startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.getRoundData(_roundId);
        return (roundID, answer, startedAt, updatedAt, answeredInRound);
    }

    /**
     * Returns the latest price.
     */
    function getLatestPrice()
        public
        view
        returns (uint80, int, uint, uint, uint80)
    {
        // prettier-ignore
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        return (roundID, price, startedAt, timeStamp, answeredInRound);
    }

    /**
     * to add last price from ChainLink price feed into struct TokenPrice
     * parameters:
     * token_address:supported ERC20 token in the ChainLink_Price_Feed_Contract_Addresses.
     * returns:
     * priceFeed.latestRoundData object
     * uint80 roundID, int price, uint startedAt,uint timeStamp, uint80 answeredInRound
     */
    /*
    function add_last_token_price(address token_address) public returns (uint80, int, uint, uint,uint80) {

        priceFeed = set_ENS_address(token_address);

        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = getLatestPrice();

        bool exist = false;

        for (uint256 i = 0; i <= TokenPrice_Id; i++) {
            
            if( Token_Price[i].token_address == token_address && Token_Price[i].roundID == roundID ) {

                exist = true;

                break;

            }

        }

        if(exist == false){

            TokenPrice_Id++;
    

            TokenPrice storage new_Token_Price = Token_Price[TokenPrice_Id];
            new_Token_Price.id = TokenPrice_Id;
            new_Token_Price.token_address = token_address_in_contract_addresses[current_ContractAddresses_Id].token_address;
            new_Token_Price.ENS_address = token_address_in_contract_addresses[current_ContractAddresses_Id].ENS_address;
            new_Token_Price.roundID = roundID;
            new_Token_Price.Timestamp = timeStamp;
            new_Token_Price.price = price;


        }

        return (roundID, price, startedAt,timeStamp, answeredInRound );

        

    }
    */

    /**
     * Returns historical price for a round id.
     * roundId is NOT incremental. Not all roundIds are valid.
     * You must know a valid roundId before consuming historical data.
     *
     * ROUNDID VALUES:
     *    InValid:      18446744073709562300
     *    Valid:        18446744073709554683
     *
     * @dev A timestamp with zero value means the round is not complete and should not be used.
     */
    function getHistoricalPrice(
        uint80 roundId
    ) public view returns (int256, uint) {
        // prettier-ignore
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            uint timeStamp,
            /*uint80 answeredInRound*/
        ) = priceFeed.getRoundData(roundId);
        //require(timeStamp > 0, "Round not complete");
        if (timeStamp == 0) {
            price = 0;
        }
        return (price, timeStamp);
    }

    /**
     * to fetch the price from ChainLink price feed of specified timeStamp
     * parameters:
     * token_address:supported ERC20 token in the ChainLink_Price_Feed_Contract_Addresses.
     * timeStamp:preffered timestamp.
     * token_decimails:token_decimails of supported ERC20 token
     * returns:
     * priceFeed.getRoundData() object by roundId
     * int256 price.
     * uint80 timeStamp.
     */
    function fetch_closest_price_to_timestamp(
        address token_address,
        uint timeStamp,
        uint token_decimails
    ) public returns (uint256, uint80) {
        set_ENS_address(token_address);

        uint80 roundID;
        int price;
        uint startedAt;
        uint last_timeStamp;
        uint80 answeredInRound;

        /*first get roundID of last price*/
        (
            roundID,
            price,
            startedAt,
            last_timeStamp,
            answeredInRound
        ) = getLatestPrice();

        /*use roundID of last price to find old data*/
        bool found = false;
        uint80 next_roundID = roundID;
        uint ENS_address_decimails;

        int next_price;
        uint next_timeStamp;

        while (found == false) {
            (next_price, next_timeStamp) = getHistoricalPrice(next_roundID);

            target_price = next_price;
            target_roundID = next_roundID;

            /*find the smallest timestamp_difference, means closest timestamp to the target*/
            if (
                next_timeStamp <= timeStamp &&
                next_timeStamp > 0 &&
                next_price > 0
            ) {
                ENS_address_decimails = token_address_in_contract_addresses[
                    current_ContractAddresses_Id
                ].ENS_address_decimails;
                found = true;
                break;
            }

            next_roundID--;
        }

        /* calculates correct deciamls */
        uint correct_decimals = token_decimails - ENS_address_decimails;
        returned_target_price = uint(target_price) * (10 ** correct_decimals);

        return (returned_target_price, target_roundID);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
