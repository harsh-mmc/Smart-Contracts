// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.16;

// Unexpected Revert, DoS
contract Auction {
    address currentLeader;
    uint highestBid;

    function bid() public payable {
        require(msg.value > highestBid);

        require(payable(currentLeader).send(highestBid)); // Refund the old leader, if it fails then revert

        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}

contract refundPayments {
    address[] private refundAddresses;
    mapping (address => uint) public refunds;

    // A single failure could deny the whole contract, so favor pull over push payments
    function refundAll() public {
        for(uint x; x < refundAddresses.length; x++) { // arbitrary length iteration based on how many addresses participated
            require(payable(refundAddresses[x]).send(refunds[refundAddresses[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }
}

contract blockLimit {
    struct Payee {
    address addr;
    uint256 value;
}

Payee[] payees;
uint256 nextPayeeIndex;

    function payOut() internal {
        uint256 i = nextPayeeIndex;
        while (i < payees.length && gasleft() > 200000) {
            bool success = payable( payees[i].addr).send(payees[i].value);
            require (success, "Stop all transactions :(");
            i++;
        }
        nextPayeeIndex = i;
    }
}

contract KingOfEther {
    address public king;
    uint public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}


