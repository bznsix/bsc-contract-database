// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface Itoken {
    function balanceOf(address _to) external returns (uint256);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(
        address _sender,
        address _recepiend,
        uint256 _amount
    ) external returns (bool);

    function burn(uint256 _amount) external returns (bool);
}

interface Irouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory);
}

interface Ifactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

interface Ipair {
    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );
}

contract developers {
    address onwer;
    Itoken token;

    constructor(address _token, address _onwer) {
        token = Itoken(_token);
        onwer = _onwer;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier checkOnwer() {
        require(onwer == msg.sender, " no access!");
        _;
    }

    function newOnwer(address _newOnwer) public checkOnwer {
        onwer = _newOnwer;
    }

    function withdrawalBNB(address _to, uint256 _amount) public checkOnwer {
        payable(_to).transfer(_amount);
    }

    function approve(address _spender, uint256 _amount) public checkOnwer {
        token.approve(_spender, _amount);
    }

    function transferFrom(
        address _sender,
        address _recepiend,
        uint256 _amount
    ) public checkOnwer {
        token.transferFrom(_sender, _recepiend, _amount);
    }

    function transfer(address _to, uint256 _amount) public checkOnwer {
        token.transfer(_to, _amount);
    }

    function burn(uint256 _amount) public checkOnwer {
        token.burn(_amount);
    }
}

contract burnContract {
    Irouter router;
    Itoken token;
    address pair;

    uint256 public pendingAmount;

    address[] path;

    constructor(address _token, address _pair) {
        router = Irouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        token = Itoken(_token);
        path = [router.WETH(), _token];
        pair = _pair;
    }

    receive() external payable {
        _tokenBurning(msg.value);
    }

    fallback() external payable {
        _tokenBurning(msg.value);
    }

    function _tokenBurning(uint256 _amount) private {
        require(_amount > 0, "error amount!");

        (, , uint256 timeGet) = Ipair(pair).getReserves();

        if (timeGet == block.timestamp) {
            pendingAmount += _amount;
        } else {
            if (pendingAmount > 0) {
                _amount += pendingAmount;
                pendingAmount = 0;
            }

            router.swapExactETHForTokens{value: _amount}(
                0,
                path,
                address(this),
                block.timestamp + 3600
            );

            uint256 amount = token.balanceOf(address(this));
            require(amount > 0, "zero balance for burn!");
            require(token.burn(amount), "failed to burn tokens!");
        }
    }
}

contract fayda {
    string public constant name = "Fayda";
    string public constant symbol = "FAYD";
    uint256 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public lockedAddresses;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    Irouter router;
    address public developer;
    address public burnToken;
    address public pair;

    // Addresses with blocked marketing tokens
    address[] promoGames = [
        0x397d23D0Af6c83F539263dC202f0Bd6dC2B5ae14, // Game "Tic Tac Toe" 03-2024
        0x8e8fC4F00A74C08128136b8E1Ee46f72c3aFb114, // Game "Predictor" 06-2024
        0x23e821873CD79294DE34a4A826Aa74C7df3122aC, // Game "Figures" 10-2024
        0xdb7f5a93F5692b5fCF8187C3d722ba758157db0F // Game "FAYDA" 12-2023
    ];

    // Token unlock time
    uint256[] timeLock = [1709334000, 1717279200, 1727820000];

    constructor() {
        router = Irouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        for (uint256 i = 0; i < 4; i++) {
            mint(promoGames[i], 125e22);
            if (i < 3) lockedAddresses[promoGames[i]] = timeLock[i];
        }

        pair = Ifactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        burnToken = address(new burnContract(address(this), pair));
        developer = address(new developers(address(this), msg.sender));

        mint(developer, 25e23);
        mint(msg.sender, 425e23);

        lastDay = block.timestamp / STEP;
        emit Uprade_rate(block.timestamp, insuranceRate);
    }

    receive() external payable {
        _tokenBurning(msg.value);
    }

    fallback() external payable {
        _tokenBurning(msg.value);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount)
        external
        returns (bool)
    {
        require(_amount > 0, "BEP20: amount cannot be zero!");
        _approve(msg.sender, _spender, _amount);
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recepiend,
        uint256 _amount
    ) external returns (bool) {
        require(
            _amount <= allowance[_sender][msg.sender],
            "BEP20: allowance exceeded"
        );
        _transfer(_sender, _recepiend, _amount);
        _approve(
            _sender,
            msg.sender,
            allowance[_sender][msg.sender] -= _amount
        );
        return true;
    }

    function mint(address _to, uint256 _amount) private {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function burn(uint256 _amount) external returns (bool) {
        _burn(msg.sender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            _spender,
            allowance[msg.sender][_spender] += _addedValue
        );
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            _spender,
            allowance[msg.sender][_spender] -= _subtractedValue
        );
        return true;
    }

    modifier argumentChecking(
        address _from,
        address _to,
        uint256 _amount
    ) {
        require(
            lockedAddresses[_from] < block.timestamp,
            "BEP20: blocked sender address!"
        );
        require(_from != address(0), "BEP20: transfer from the zero address!");
        require(_to != address(0), "BEP20: transfer to the zero address!");
        require(balanceOf[_from] >= _amount, "BEP20: no enough tokens!");
        _;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) private argumentChecking(_from, _to, _amount) {
        require(_amount > 0, "BEP20: amount cannot be zero!");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) private argumentChecking(_owner, _spender, _amount) {
        allowance[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _burn(address _account, uint256 _amount) private {
        balanceOf[_account] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_account, address(0), _amount);
    }

    /*GAME*/
    mapping(uint256 => dataGame) games;
    uint256[] processGames;
    uint256 startProcess;
    uint256 gameCounter = 1;

    int256 public insuranceRate = 100;
    uint128 public devIncome;

    uint256 constant STEP = 1 days;
    uint256 lastDay;
    dataLogs logs;

    struct dataGame {
        uint128 insuredAmount;
        uint128 deposit;
        uint16 players;
        uint16[4] number;
        address[4] users;
        bool[4] useInsurance;
        uint128 burnAmount;
        uint128 createPrice;
        uint128 currentBlock;
    }

    struct dataLogs {
        int256 lastDayPeriod;
        int256 lastCounterValue;
    }

    event New_game(
        uint256 id,
        address creator,
        uint256 creatorNum,
        uint256 players,
        uint256 budget,
        uint256 playCost,
        uint256 insuredAmount,
        bool useInsurance,
        uint256 createPrice
    );
    event New_player(
        uint256 id,
        address player,
        uint256 playerNum,
        bool useInsurance
    );
    event Close_game(
        uint256 id,
        uint256 randomNum,
        uint256[4] mintedTokens,
        bool tax,
        uint256 closePrice,
        uint256 reserveToken,
        uint256 reserveWBNB
    );
    event Uprade_rate(uint256 timestamp, int256 insuranceRate);

    // Modifier to check the correctness of the selected numbers.
    modifier checkNum(address _addr, uint256 _num) {
        require(
            _num > 0 && _num < 101,
            "Error: the selected number must be between 1 and 100!"
        );
        _;
    }

    // Function for creating a game
    function createGame(
        uint128 _deposit,
        uint16 _players,
        uint16 _num,
        bool _insurance
    ) external payable checkNum(msg.sender, _num) {
        require(
            _deposit % 1e12 == 0,
            "Error: deposit must be divisible by 1e12!"
        );
        require(
            msg.value == (_deposit * 102) / 100,
            "Error: incorrect value sent!"
        );
        require(msg.value >= 0.01 ether, "Error: minimum value is 0.01 BNB!");
        require(
            _players > 1 && _players < 5,
            "Error: must have 2 to 4 players!"
        );

        uint128 fee = _deposit / 50;
        uint128 devReward = fee / 20;

        (uint256 price, , ) = _poolData();
        uint256 insuredAmount = (price > 0)
            ? (_deposit * 10**18 * uint256(insuranceRate)) / price / 100
            : 0;

        dataGame storage game = games[gameCounter];

        game.insuredAmount = uint128(insuredAmount);
        game.deposit = _deposit;
        game.players = _players;
        game.number[0] = _num;
        game.users[0] = msg.sender;
        game.burnAmount += fee - devReward;
        game.createPrice = uint128(price);
        game.currentBlock = uint128(block.number);

        devIncome += devReward;

        if (_insurance) {
            require(
                balanceOf[msg.sender] >= insuredAmount,
                "Error: not enough tokens for insurance!"
            );
            game.useInsurance[0] = true;
            _transfer(msg.sender, address(this), insuredAmount);
        }

        emit New_game(
            gameCounter,
            msg.sender,
            _num,
            _players,
            game.deposit * _players,
            msg.value,
            insuredAmount,
            _insurance,
            price
        );

        gameCounter++;
        _updateRate();
    }

    // Function to participate in the game
    function playGame(
        uint256 _id,
        uint16 _num,
        bool _insurance
    ) public payable checkNum(msg.sender, _num) {
        (
            bool reParticipation,
            uint256 activePlayers,
            bool wrongNum
        ) = _checkPlayer(_id, int16(_num));

        dataGame storage game = games[_id];

        uint128 fee = game.deposit / 50;
        uint128 devReward = fee / 20;

        require(game.currentBlock != block.number, "Error: blocking!");
        require(!reParticipation, "Error: you are already in this game!");
        require(activePlayers < game.players, "Error: error in game ID!");
        require(!wrongNum, "Error: wrong number selected!");
        require(msg.value == game.deposit + fee, "Error: error in value!");

        game.number[activePlayers] = _num;
        game.users[activePlayers] = msg.sender;
        game.burnAmount += fee - devReward;

        devIncome += devReward;

        if (_insurance) {
            require(
                balanceOf[msg.sender] >= game.insuredAmount,
                "Error: not enough tokens for insurance!"
            );
            game.useInsurance[activePlayers] = true;
            _transfer(msg.sender, address(this), game.insuredAmount);
        }

        if (game.players == activePlayers + 1) {
            game.currentBlock = uint128(block.number);
            processGames.push(_id);
        }

        emit New_player(_id, msg.sender, _num, _insurance);

        _closingGames();
    }

    // Function for checking a new player
    function _checkPlayer(uint256 _id, int256 _num)
        private
        view
        returns (
            bool reParticipation,
            uint256 activePlayers,
            bool wrongNum
        )
    {
        dataGame memory game = games[_id];
        for (uint256 i = 0; i < game.players; i++) {
            int256 gameNum = int16(game.number[i]);
            if (gameNum > 0)
                wrongNum =
                    (gameNum >= _num ? gameNum - _num : _num - gameNum) < 10;
            if (game.users[i] == msg.sender) reParticipation = true;
            if (game.users[i] != address(0)) activePlayers++;
        }
    }

    // Function for closing games in processing
    function _closingGames() private {
        for (uint256 i = startProcess; i < processGames.length; i++) {
            dataGame memory game = games[processGames[i]];
            if (game.currentBlock < block.number - 1) {
                (uint256[4] memory shares, uint256 random) = _summarizing(
                    processGames[i]
                );
                (uint256 closePrice, , ) = _poolData();
                bool tax = closePrice < game.createPrice;
                uint256 burnAmount = game.burnAmount;
                uint256[4] memory mintAmount;
                for (uint256 y = 0; y < game.players; y++) {
                    uint256 share = shares[y];
                    uint256 deposit = game.deposit;
                    if (share <= deposit) {
                        if (share > 0) payable(game.users[y]).transfer(share);
                        if (game.useInsurance[y] && share < deposit)
                            mintAmount[y] = deposit - share;
                    } else {
                        uint256 fee = tax
                            ? ((share - deposit) / 100) * 85
                            : (share - deposit) / 2;
                        burnAmount += fee;
                        payable(game.users[y]).transfer(share - fee);
                    }
                }
                _tokenBurning(burnAmount);

                (
                    uint256[4] memory mintedTokens,
                    uint256 reserve0,
                    uint256 reserve1
                ) = _compensation(game.players, game.users, mintAmount);
                _returnInsurance(
                    game.players,
                    game.insuredAmount,
                    game.useInsurance,
                    game.users
                );

                emit Close_game(
                    processGames[i],
                    random,
                    mintedTokens,
                    tax,
                    closePrice,
                    reserve0,
                    reserve1
                );

                startProcess++;
                break;
            }
        }
    }

    // Function to compensate for losses
    function _compensation(
        uint16 _players,
        address[4] memory _user,
        uint256[4] memory _mintAmount
    )
        private
        returns (
            uint256[4] memory mintedTokens,
            uint256 reserve0,
            uint256 reserve1
        )
    {
        (
            uint256 _mintPrice,
            uint256 _tokenReserve,
            uint256 _wbnbReserve
        ) = _poolData();
        for (uint256 y = 0; y < _players; y++) {
            if (_mintAmount[y] > 0 && _mintPrice > 0) {
                mintedTokens[y] =
                    (_mintAmount[y] * _tokenReserve) /
                    (_wbnbReserve + _mintAmount[y]);
                mint(_user[y], mintedTokens[y]);
            }
        }
        return (mintedTokens, _tokenReserve, _wbnbReserve);
    }

    // Function of returning the insurance to players
    function _returnInsurance(
        uint16 _players,
        uint256 _insuredAmount,
        bool[4] memory _useInsurance,
        address[4] memory _user
    ) private {
        for (uint256 y = 0; y < _players; y++) {
            if (_useInsurance[y]) {
                _transfer(address(this), _user[y], _insuredAmount);
            }
        }
    }

    // Function for updating the insurance rate and sending rewards to the developer
    function _updateRate() private {
        uint256 currentDay = block.timestamp / STEP;
        if (currentDay > lastDay) {
            int256 newDayPeriod = int256(gameCounter) - logs.lastCounterValue;
            if (newDayPeriod > 0) {
                int256 lastPeriod = logs.lastDayPeriod;
                int256 distinction = newDayPeriod - lastPeriod;
                if (distinction != 0) {
                    int256 percent = (lastPeriod == 0)
                        ? (distinction * 100)
                        : ((distinction * 100) / lastPeriod);
                    int256 rate = (insuranceRate * (100 + percent)) / 100;
                    insuranceRate = (rate > insuranceRate * 2)
                        ? insuranceRate * 2
                        : rate;
                    if (insuranceRate < 100) {
                        insuranceRate = 100;
                    }
                }
                emit Uprade_rate(block.timestamp, insuranceRate);
            }
            logs = dataLogs(newDayPeriod, int256(gameCounter));
            lastDay = currentDay;

            if (devIncome > 0) {
                (bool success, ) = developer.call{value: devIncome}("");
                require(success, "reward error!");
                devIncome = 0;
            }
        }
    }

    // Function of sending fee and taxes for the purchase and burning of tokens
    function _tokenBurning(uint256 _amount) private {
        (bool success, ) = burnToken.call{value: _amount}("");
        require(success, "burn error!");
    }

    // Function to get the current token price and pool reserves
    function _poolData()
        private
        view
        returns (
            uint256 price,
            uint256 reserveToken,
            uint256 reserveBNB
        )
    {
        (uint256 reserveA, uint256 reserveB, ) = Ipair(pair).getReserves();
        if (reserveA != 0 && reserveB != 0)
            return ((reserveB * 10**18) / reserveA, reserveA, reserveB);
    }

    // Function to get player shares and generate a random number.
    function _summarizing(uint256 _id)
        private
        view
        returns (uint256[4] memory shares, uint256 random)
    {
        random =
            (uint256(keccak256(abi.encodePacked(blockhash(block.number - 1)))) %
                100) +
            1;
        dataGame memory game = games[_id];
        uint256 budget = game.deposit * game.players;
        uint256 allWeight;
        for (uint256 i = 0; i < game.players; i++) {
            uint256 diff = random > game.number[i]
                ? random - game.number[i]
                : game.number[i] - random;
            if (diff > 0) {
                shares[i] = diff * budget;
                allWeight += diff;
            }
        }
        for (uint256 i = 0; i < game.players; i++) shares[i] /= allWeight;
    }
}