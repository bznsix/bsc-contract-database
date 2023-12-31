pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Generated by : https://www.cues.sg
 * Cues.sg : We make technology accessible.
 * Contract Type : Jackpot
*/

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Lottery {

	address owner;
	bool public paused = false;
	address[] public players;
	address[] public winners;
	uint256 public playerLimit = uint256(3);
	uint256 public taxRate = uint256(100000);
	uint256 public jackpotCoinPrice0 = uint256(100000000000000);
	uint256 public jackpotCoinPrice0SourceAmtInBank = uint256(0);
	uint256 public retainedForJackpotCoin0 = uint256(0);
	event JackpotEntered (address indexed participatingAddress, uint256 indexed participationNumber);
	event JackpotDone (address indexed winningAddress);

	constructor() {
		owner = msg.sender;
	}

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function random(uint256 input) internal view returns (uint256) {
		return
			uint256(
				keccak256(
					abi.encodePacked(
						block.timestamp +
							block.difficulty +
							block.gaslimit +
							block.number +
							input +
							((
								uint256(
									keccak256(abi.encodePacked(block.coinbase))
								)
							) / block.timestamp) 
							
					)
				)
			);
	}

/**
 * Function changeValueOf_paused
 * Notes for _paused : Toggle to pause lottery
 * The function takes in 1 variable, (a boolean) _paused. It can only be called by functions outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * updates paused as _paused
*/
	function changeValueOf_paused(bool _paused) external onlyOwner {
		paused  = _paused;
	}

/**
 * Function changeValueOf_playerLimit
 * Notes for _playerLimit : Change the number of players in the lottery.
 * The function takes in 1 variable, (zero or a positive integer) _playerLimit. It can only be called by functions outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (length of players) is equals to 0
 * updates playerLimit as _playerLimit
*/
	function changeValueOf_playerLimit(uint256 _playerLimit) external onlyOwner {
		require(((players).length == uint256(0)), "Can only be changed if there are zero players in the pool");
		playerLimit  = _playerLimit;
	}

/**
 * Function changeValueOf_taxRate
 * Notes for _taxRate : Change the tax rate in the lottery. 10000 is 1%.
 * The function takes in 1 variable, (zero or a positive integer) _taxRate. It can only be called by functions outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (length of players) is equals to 0
 * updates taxRate as _taxRate
*/
	function changeValueOf_taxRate(uint256 _taxRate) external onlyOwner {
		require(((players).length == uint256(0)), "Can only be changed if there are zero players in the pool");
		taxRate  = _taxRate;
	}

/**
 * Function changeValueOf_jackpotCoinPrice0
 * Notes for _jackpotCoinPrice0 : 10^9 represents 1 AntiBotLiquidityGeneratorToken
 * The function takes in 1 variable, (zero or a positive integer) _jackpotCoinPrice0. It can only be called by functions outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * updates jackpotCoinPrice0 as _jackpotCoinPrice0
*/
	function changeValueOf_jackpotCoinPrice0(uint256 _jackpotCoinPrice0) external onlyOwner {
		jackpotCoinPrice0  = _jackpotCoinPrice0;
	}

/**
 * Function jackpotCoinPrice0SourceTaxWithdrawAmt
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20(Address 0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to jackpotCoinPrice0SourceAmtInBank
 * if jackpotCoinPrice0SourceAmtInBank is strictly greater than 0 then (calls ERC20(Address 0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)'s at transfer function  with variable recipient as (the address that called this function), variable amount as jackpotCoinPrice0SourceAmtInBank)
 * updates jackpotCoinPrice0SourceAmtInBank as 0
*/
	function jackpotCoinPrice0SourceTaxWithdrawAmt() public onlyOwner {
		require((ERC20(address(0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)).balanceOf(address(this)) >= jackpotCoinPrice0SourceAmtInBank), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		if ((jackpotCoinPrice0SourceAmtInBank > uint256(0))){
			ERC20(address(0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)).transfer(msg.sender, jackpotCoinPrice0SourceAmtInBank);
		}
		jackpotCoinPrice0SourceAmtInBank  = uint256(0);
	}

/**
 * Function playJackpot
 * The function takes in 0 variables. It can only be called by functions outside of this contract. It does the following :
 * checks that not paused
 * calls ERC20(Address 0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)'s at transferFrom function  with variable sender as (the address that called this function), variable recipient as (the address of this contract), variable amount as jackpotCoinPrice0
 * updates jackpotCoinPrice0SourceAmtInBank as (jackpotCoinPrice0SourceAmtInBank) + (((jackpotCoinPrice0) * (taxRate)) / (1000000))
 * updates retainedForJackpotCoin0 as (retainedForJackpotCoin0) + (((jackpotCoinPrice0) * ((1000000) - (taxRate))) / (1000000))
 * adds the address that called this function to players
 * emits event JackpotEntered with inputs the address that called this function, length of players
 * if (length of players) is equals to playerLimit then (creates an internal variable winningAddress with initial value players with element (random number with seed (length of players)) modulo (length of players); then checks that (ERC20(Address 0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)'s at balanceOf function  with variable recipient as (the address of this contract)) is greater than or equals to retainedForJackpotCoin0; then if retainedForJackpotCoin0 is strictly greater than 0 then (calls ERC20(Address 0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)'s at transfer function  with variable recipient as winningAddress, variable amount as retainedForJackpotCoin0); then updates retainedForJackpotCoin0 as 0; then updates players as Empty List; then adds winningAddress to winners; and then emits event JackpotDone with inputs winningAddress)
*/
	function playJackpot() external {
		require(!(paused), "Jackpot currently paused by owner");
		ERC20(address(0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)).transferFrom(msg.sender, address(this), jackpotCoinPrice0);
		jackpotCoinPrice0SourceAmtInBank  = (jackpotCoinPrice0SourceAmtInBank + ((jackpotCoinPrice0 * taxRate) / uint256(1000000)));
		retainedForJackpotCoin0  = (retainedForJackpotCoin0 + ((jackpotCoinPrice0 * (uint256(1000000) - taxRate)) / uint256(1000000)));
		players.push(msg.sender);
		emit JackpotEntered(msg.sender, (players).length);
		if (((players).length == playerLimit)){
			address winningAddress = players[(random((players).length) % (players).length)];
			require((ERC20(address(0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)).balanceOf(address(this)) >= retainedForJackpotCoin0), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
			if ((retainedForJackpotCoin0 > uint256(0))){
				ERC20(address(0x273aDa5300b3a32cB10aAD2b7960e4C5fd8BF345)).transfer(winningAddress, retainedForJackpotCoin0);
			}
			retainedForJackpotCoin0  = uint256(0);
			players  = new address[](0);
			winners.push(winningAddress);
			emit JackpotDone(winningAddress);
		}
	}
}
