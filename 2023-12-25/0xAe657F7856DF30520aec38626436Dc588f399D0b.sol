// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RevenueSharing {

    // Data Structures
    address payable public developer = payable(0x5208b6338Bf6CD141ee3276889D9E37830bB2299); // <-- Developer address here
    mapping(address => uint256) public investorContributions;
    mapping(address => address) public referrers;
    mapping(address => bool) public isInvestor;
    mapping(address => string) public referralLinks; // Map addresses to referral links
    address[] public investorAddresses;

    // Event to log distribution information
    event LogDistribution(address indexed investor, uint256 percentage, uint256 payment);

    // Event to log new referrals
    event LogReferral(address indexed investor, address indexed referrer);

    // Event to log new connections
    event LogConnect(address indexed investor, string referralLink);

    // Function to connect a wallet and generate a referral link
    function connectWallet() public {
        require(!isInvestor[msg.sender], "Wallet already connected");

        // Add sender as a new investor
        investorAddresses.push(msg.sender);
        isInvestor[msg.sender] = true;

        // Generate a unique referral link based on the user's address
        string memory referralLink = generateReferralLink(msg.sender);
        referralLinks[msg.sender] = referralLink;

        emit LogConnect(msg.sender, referralLink);
    }

    // Function to generate a referral link based on the user's address
    function generateReferralLink(address investor) internal pure returns (string memory) {
        return string(abi.encodePacked("http://aro.bscxzero.com//referral?addr=", toAsciiString(investor)));
    }

    // Function to trigger automatic distribution upon receiving funds
    receive() external payable {
        // Check if sender is already an investor
        if (!isInvestor[msg.sender]) {
            connectWallet();
        }

        // Check if there's a referrer and reward them
        if (referrers[msg.sender] != address(0)) {
            address referrer = referrers[msg.sender];
            uint256 referralReward = msg.value * 5 / 100;
            payable(referrer).transfer(referralReward);
        }

        uint256 revenue = msg.value;

        // Send developer share instantly
        uint256 developerShare = revenue * 40 / 100;
        developer.transfer(developerShare);

        // Distribute remaining share to investors
        distributeRevenue(revenue - developerShare);
    }

    function distributeRevenue(uint256 investorShare) internal {
        address[] memory investors = getInvestorAddresses();
        uint256 investorSharePerAddress = investorShare / investors.length;

        for (uint256 i = 0; i < investors.length; i++) {
            address investor = investors[i];

            // Distribute an equal share to each investor
            payable(investor).transfer(investorSharePerAddress);

            // Update the investor's contribution
            investorContributions[investor] += investorSharePerAddress;

            emit LogDistribution(investor, 100, investorSharePerAddress);
        }
    }

    function getInvestorAddresses() public view returns (address[] memory) {
        return investorAddresses;
    }

    // Function to convert address to ASCII string
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    // Function to convert a byte to a char
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}