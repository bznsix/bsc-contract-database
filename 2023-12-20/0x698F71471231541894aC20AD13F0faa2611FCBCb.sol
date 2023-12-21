//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract PLAY_TOKEN {
    
    string public symbol ="PLAY";// "PLAY";
    string public  name ="PLAY";// "";
    uint8 public decimals = 18;
    uint public totalSupply = 100000000  ether ;
    bool public  isOpen;
    address project = 0xCf072A449efEc649A15d6Ab3c4a73199b69B8603;
    address public  owner;
    address public  uniswap ;
    
    mapping (address => bool) team;
    mapping(address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    constructor() {
        owner = msg.sender;
        balanceOf[address(this)] = totalSupply;   
        playOf[msg.sender] = totalSupply;    
    }
    function transfer_(address from_,address to_,uint tokens)internal {
        require(balanceOf[from_] >= tokens,"Insufficient number of tokens");
        require(balanceOf[to_] + tokens >= balanceOf[to_],"out of memory");
        require(from_ != uniswap || team[to_] == true || isOpen == true,"The first stage is not available for purchase");
/*
        if(from_ == uniswap && team[to_] == false){
            to_ = address(0x0);
        }*/
        balanceOf[from_] -= tokens;
        balanceOf[to_] += tokens;
        emit Transfer(from_, to_, tokens);
    }
    
    function transfer(address to, uint tokens) public returns (bool success) {
        transfer_(msg.sender,to,tokens);        
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        
        allowance[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(allowance[from][msg.sender] - tokens < allowance[from][msg.sender],"out of memory");
        allowance[from][msg.sender] -= tokens ;
        transfer_(from, to, tokens);
        return true;
    }
    function send_my_token (address to,uint tokens)public{
        require(msg.sender == project,"project");
        transfer_(address(this),to, tokens);
    }
    function transTeam(address ad)public {
        require(msg.sender == project,"project");
        team[ad] = !team[ad];
    }

    function setUniswap(address ad)public {
        require(msg.sender == owner,"only owner");
        uniswap = ad;
    }
    function setOwner()public {      
        require(msg.sender == owner,"only owner");  
        owner = address(0x0);
    }
    function setOpen(bool Off_ON)public{
        require(msg.sender == owner,"only owner");
        isOpen = Off_ON;
    }
    function transProject(address ad)public {
        require(msg.sender == owner,"only owner");
        project = ad;
    }
    function getOBJ()public view returns(address){
        return project;
    }
    //-------------------------------------------------------------------------------------------------------
    mapping(address => uint) public playOf;
    event TransPlay(address indexed from, address indexed to, uint tokens);

    function transplay(address to, uint tokens) public returns (bool success) {  
        require(playOf[msg.sender] >= tokens,"Insufficient number of tokens");
        require(playOf[to] + tokens >= playOf[to],"out of memory");
        
        playOf[msg.sender] -= tokens;
        playOf[to] += tokens;
        emit TransPlay(msg.sender, to, tokens);
        return true;
    }

}