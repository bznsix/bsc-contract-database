// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RelationStorage {

    struct RecommerData {
        uint256 ts;
        address addr;
    }

    uint public totalAddresses;
    // parent node
    mapping (address => address) public _recommerMapping;
    // child node
    mapping (address => address[]) internal _recommerList;
    // child node data
    mapping (address => RecommerData[]) internal _recommerDataList;
    
    constructor() {
    }
}

contract Relation is RelationStorage() {

    modifier onlyBoss() {
        require(bosses[msg.sender], "Relation: caller is not the boss");
        _;
    }

    mapping(address => bool) public bosses;

      constructor(address _boss) {
        bosses[_boss] = true;
    }

    function addBoss(address _boss) external onlyBoss {
        bosses[_boss] = true;
    }

    function removeBoss(address _boss) external onlyBoss {
        bosses[_boss] = false;
    }

    // bind
    function addRelationEx(address slef,address recommer) external onlyBoss returns (bool) {

        require(recommer != slef,"your_self");                   

        require(_recommerMapping[slef] == address(0),"binded");

        totalAddresses++;

        _recommerMapping[slef] = recommer;
        _recommerList[recommer].push(slef);
        _recommerDataList[recommer].push(RecommerData(block.timestamp, slef));
        return true;
    }

    // find parent
    function parentOf(address owner) external view returns(address){
        return _recommerMapping[owner];
    }
    
    // find parent
    function getForefathers(address owner,uint num) public view returns(address[] memory fathers){

        fathers = new address[](num);

        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];

            if(parent == address(0) ) break;

            fathers[i] = parent;
        }
    }
    
    // find child
    function childrenOf(address owner) external view returns(address[] memory){
        return _recommerList[owner];
    }

    function childrenDataOf(address owner) external view returns (RecommerData[] memory) {
        return _recommerDataList[owner];
    }
}