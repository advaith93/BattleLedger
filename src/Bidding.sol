//SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract DefenceBidding{
    struct RFP{   //structure that holds data of Request For Proposals
        uint id;
        string description;
        uint budget;
        uint deadline;
        bool active;
        address selectedVendor;
    } //used by the govt
    
    struct Bid {
        address vendor; //address of the vender that wants to supply
        bytes32 encryptedBid;  //encrypted so that others cannot see the value
    }

    uint256 public rfpCount;
    mapping(uint256 => RFP) public rfps;
    mapping(uint256 => Bid[]) public bids;

    address private government; //Only the govt can create the RFPs


    event RFPCreated(uint id, string description, uint256 budget, uint256 deadline);

    event BidSubmitted(uint rfpId, address vendor);

    event WinnerSelected(uint rfpId, address winner);

    modifier onlyGovt() {
        require(msg.sender == government, "Not authorized");
        _;
    }

    constructor(){
        government = msg.sender; //sets the deployer of the contract as government
    }

    function createRFP(string memory _description, uint256 _budget, uint256 _deadline) external onlyGovt{
        require(_deadline > block.timestamp, "Deadline already over!"); //verifies if the deadline is valid

        rfpCount++;

        rfps[rfpCount] = RFP(rfpCount, _description, _budget, _deadline, true, address(0));

        emit RFPCreated(rfpCount, _description, _budget, _deadline);
    }

    function submitBid(uint _rfpId, bytes32 _encryptedBid) external {
        require(rfps[_rfpId].active, "RFP inactive!"); // checks if the Request is valid or not by looking into the boolean value inside the RFP struct
        require(block.timestamp < rfps[_rfpId].deadline, "Deadline over!");

        bids[_rfpId].push(Bid(msg.sender, _encryptedBid));

        emit BidSubmitted(_rfpId, msg.sender);
    }

    function selectWinner(uint _rfpId) external onlyGovt {
        require(block.timestamp >= rfps[_rfpId].deadline, "Bidding still going on! ");
        require(rfps[_rfpId].active, "RFP already closed!");
        require(bids[_rfpId].length > 0,"No bids present!");

        address winner = bids[_rfpId][0].vendor;
        rfps[_rfpId].selectedVendor = winner;
        rfps[_rfpId].active = false;

        emit WinnerSelected(_rfpId, winner);
    }
}