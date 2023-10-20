//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

contract Provenance{
    enum ActionStatus {
        REMOVED,
        ADDED
    }

    struct Product {
        address producer_address;
        string name;
        uint date_time_of_origin;
        ActionStatus action_status;
    }

    mapping(address => mapping(address => bool)) public auth_producer;
	mapping(uint256 => address) public producer_list;
	mapping(address => bool) public is_producer;
    mapping(string => Product) public products;
    string[] public product_list;
    uint256 public producer_count;
    uint256 public product_count;
    
    constructor() {
        producer_count = 0;
        product_count = 0;
    }

	function authProducer(address to) public {
		if(!is_producer[msg.sender]){
			producer_count ++;
			producer_list[producer_count] = msg.sender;
			is_producer[msg.sender] = true;
		}
		if(!is_producer[to]){
			producer_count ++;
			producer_list[producer_count] = to;
			is_producer[to] = true;
		}

		if(msg.sender > to)
        	auth_producer[msg.sender][to] = true;
    	else
        	auth_producer[to][msg.sender] = true;
	}

    function addProduct(string memory pub_number, string memory name) public {
        require(products[pub_number].action_status != ActionStatus.ADDED, "This product is already exist.");
        products[pub_number] = Product(msg.sender, name, block.timestamp, ActionStatus.ADDED);
        product_list.push(pub_number);
        product_count ++;
    }
}
