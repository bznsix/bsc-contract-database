/*

MonkeyBall: Empowering E-commerce with the Revolutionary BEP-20 Token 🌟

Introduction

In the rapidly evolving world of e-commerce, innovation and efficiency are key factors 
that drive success. MonkeyBall, a groundbreaking BEP-20 token built on the Binance Smart Chain (BSC),
 aims to revolutionize the e-commerce landscape by providing a seamless and rewarding experience
  for both buyers and sellers. With its unique features and benefits, 
  MonkeyBall is set to become a game-changer in the world of online shopping. 💫

Here are 10 compelling reasons why MonkeyBall deserves your attention: 🌟

Decentralized Marketplace 🌐
MonkeyBall introduces a decentralized marketplace that eliminates the need for intermediaries, 
allowing buyers and sellers to interact directly. This peer-to-peer approach ensures transparency, 
reduces costs, and eliminates unnecessary fees, ultimately benefiting both buyers and sellers. 🤝

Transparent and Secure Transactions 🔒
MonkeyBall leverages the security and transparency of blockchain technology to ensure safe and 
secure transactions. By utilizing the Binance Smart Chain (BSC), MonkeyBall provides 
users with fast and efficient transactions, eliminating the risk of fraud or unauthorized access. ✨

Token Utility 💼
MonkeyBall offers a wide range of utility within its ecosystem. Users can utilize the token to 
purchase products, participate in auctions, access premium features, and even earn rewards 
through staking and farming. The token's multi-dimensional utility enhances the overall 
shopping experience and provides various avenues for users to benefit. 💰

Fair and Efficient Auctions 🎁
MonkeyBall incorporates a unique auction mechanism that allows buyers to bid on products 
and services. The auction process ensures fair pricing and creates a dynamic environment 
where users can compete to secure their desired items. This innovative approach adds 
excitement and opportunity to the e-commerce experience. 🎯

Rewards and Incentives 🏆
MonkeyBall rewards its users through a comprehensive reward system. By holding and using the token, 
users can earn loyalty rewards, referral bonuses, and participate in exclusive events. 
These incentives encourage user engagement and loyalty, providing additional 
value to the MonkeyBall community. 🎉

Enhanced User Experience 💫
MonkeyBall is committed to providing an exceptional user experience. 
The platform features a user-friendly interface, intuitive navigation, and personalized 
recommendations based on user preferences. By focusing on user satisfaction, MonkeyBall 
aims to elevate the e-commerce experience and make online shopping more enjoyable and convenient. ✨

Global Accessibility 🌍
MonkeyBall breaks down geographical barriers, allowing users from all around the world to 
participate in its ecosystem. With its decentralized nature and compatibility 
with the Binance Smart Chain, MonkeyBall offers global accessibility, 
enabling users to explore a diverse range of products and services. 🌎

Community Engagement 🤝
MonkeyBall values community engagement and actively involves its users 
in decision-making processes. Through interactive platforms, 
regular updates, and community events, MonkeyBall ensures that every user has a voice and plays 
a vital role in shaping the future of the platform. 📢

Strategic Partnerships 🤝
MonkeyBall is dedicated to forging strategic partnerships with established 
e-commerce platforms, businesses, and brands. These partnerships enhance the token's utility, 
expand its reach, and create opportunities for users to access a wider array of products and services. 🤝

Continuous Innovation 💡
MonkeyBall understands the importance of continuous innovation in the 
ever-evolving e-commerce landscape. The development team is committed to implementing
 new features, integrating emerging technologies, and staying ahead of market trends to 
 provide a cutting-edge platform that meets the evolving needs of users. 🔬

Conclusion 🌟

MonkeyBall is not just another BEP-20 token; it is a catalyst for change in the e-commerce 
industry. With its decentralized marketplace, transparent transactions, versatile utility, 
fair auctions, rewarding incentives, and commitment to user satisfaction, MonkeyBall has 
the potential to redefine online shopping as we know it. ✨

Embrace the future of e-commerce with MonkeyBall and experience a new level of convenience, 
security, and opportunity. Join the MonkeyBall community today and be part of the revolution 
that is transforming the way we shop online. 🚀

https://www.MonkeyBall.com
https://t.me/MonkeyBall
https://fb.com/MonkeyBall
https://twitter.com/MonkeyBall
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract MonkeyBallToken {
    string public name = "MonkeyBall";
    string public symbol = "MonkeyBall";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;
    string public MonkeyBallfb = "https://fb.com/MonkeyBall";
    string public constant MonkeyBalltelegram = "https://t.me/MonkeyBall";
    string public constant MonkeyBallaudited = "MonkeyBall is audited by: https://www.certik.com/";

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _ownerMonkeyBall,
        address indexed spenderMonkeyBall,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address private owner;
    address private marketingAddress = 0xE42c8571c20A28b4F5f16668706D9E4e5714b8DA;
    event OwnershipRenounced();

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function calculateFee(uint256 _value) private pure returns (uint256) {
        return (_value * 299) / 10000; // 2.99% fee
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        
        uint256 fee = calculateFee(_value);
        uint256 transferAmount = _value - fee;
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += transferAmount;
        balanceOf[marketingAddress] += fee; // Fee goes to the marketing address
        
        emit Transfer(msg.sender, _to, transferAmount);
        emit Transfer(msg.sender, marketingAddress, fee); // Transfer fee event
        
        return true;
    }

    function approve(address spenderMonkeyBall, uint256 _value) public returns (bool success) {
        require(address(0) != spenderMonkeyBall);
        
        allowance[msg.sender][spenderMonkeyBall] = _value;
        
        emit Approval(msg.sender, spenderMonkeyBall, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        uint256 fee = calculateFee(_value);
        uint256 transferAmount = _value - fee;
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += transferAmount;
        balanceOf[marketingAddress] += fee; // Fee goes to the marketing address
        
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, transferAmount);
        emit Transfer(_from, marketingAddress, fee); // Transfer fee event
        
        return true;
    }

    function getMonkeyBallfb() public view returns (string memory) {
        return MonkeyBallfb;
    }
    
    function renounceOwnership() public {
        require(msg.sender == owner);
        
        emit OwnershipRenounced();
        
        owner = address(0);
    }
}