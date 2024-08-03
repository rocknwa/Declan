//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Declan {

    //
    // Events
    //

    // Event emitted when a new gig is created
    event GigCreated(uint256 gigId);

    // Event emitted when a bid is placed on a gig
    event BidPlaced(uint256 gigId, address bidder);

    // Event emitted when a freelancer joins
    event FreelancerJoined(address freelancer);

    // Event emitted when a bid is accepted
    event AcceptBid(uint256 gigId, address freelancer);

    //
    // Structs
    //

    struct Freelancer {
        string name;
        address addr;
        string portfolioURL;
        string[] skills;
        string[] categories;
        bool verified;
        uint32 stars;
        string email;
        string country;
        uint32 jobCount;
    }

    struct GigOwner {
        string gigOwner;
        address gigOwnerAddress;
        string gigOwnerCompany;
        bool isVerified;
        uint32 stars;
    }

    struct Gig {
        uint256 id;
        address owner;
        string ownerEmail;
        address freelancer;
        string title;
        string description;
        uint256 gigTimeline;
        uint256 deadline;
        uint256 budget;
        bool featureGig;
        mapping(address => Bidder) bidders;
        string status;
        address escrower;
        uint256 escrowAmount;
        uint256 warningCount;
    }

    struct Bidder {
        string freelancerName;
        string[] freelancerSkills;
        string freelancerPortfolioURL;
        uint256 bidAmount;
    }

    //
    // State
    //

    mapping(address => Freelancer) public freelancers;
    mapping(address => GigOwner) public gigOwners;
    mapping(uint256 => Gig) public gigs;

    uint256 public noOfFreelancers;
    uint256 public noOfGigOwners;
    uint256 public noOfCreatedGigs;

    constructor() {
        noOfFreelancers = 0;
        noOfGigOwners = 0;
        noOfCreatedGigs = 0;
    }

    //
    // Functions
    //

    // Function to create a freelancer account
    function createFreelancerAccount(
        string memory name,
        address addr,
        string memory portfolioURL,
        string[] memory skills,
        string[] memory categories,
        bool verified,
        uint32 stars,
        string memory email,
        string memory country,
        uint32 jobCount
    ) public {
        freelancers[addr] = Freelancer(
            name,
            addr,
            portfolioURL,
            skills,
            categories,
            verified,
            stars,
            email,
            country,
            jobCount
        );

        emit FreelancerJoined(addr);
    }

    // Function to create a gig owner account
    function createGigOwnerAccount(
        string memory gigOwner,
        address gigOwnerAddress,
        string memory gigOwnerCompany,
        bool isVerified,
        uint32 stars
    ) public {
        gigOwners[gigOwnerAddress] = GigOwner(
            gigOwner,
            gigOwnerAddress,
            gigOwnerCompany,
            isVerified,
            stars
        );
    }

    // Function to create a new gig
    function createGig(
        address owner,
        string memory ownerEmail,
        string memory title,
        string memory description,
        uint256 gigTimeline,
        uint256 budget
    ) public returns (uint256) {
        uint256 newGigId = getCurrentGigId();

        Gig storage gig = gigs[newGigId];
        gig.id = newGigId;
        gig.owner = owner;
        gig.ownerEmail = ownerEmail;
        gig.freelancer = owner;
        gig.title = title;
        gig.description = description;
        gig.gigTimeline = gigTimeline;
        gig.deadline = 0;
        gig.budget = budget;
        gig.featureGig = false;
        gig.status = "open";
        gig.escrower = owner;
        gig.escrowAmount = 0;
        gig.warningCount = 0;

        emit GigCreated(newGigId);

        noOfCreatedGigs += 1;

        return newGigId;
    }

    // Function to place a bid on a gig
    function placeBid(uint256 gigId, uint256 bidAmount) public {
        Gig storage gig = gigs[gigId];

        // Perform validation checks
        require(keccak256(bytes(gig.status)) == keccak256("open"), "Gig is not open");
        require(bidAmount >= gig.budget, "Bid amount must be greater than or equal to gig budget");

        // Retrieve the bidder's information from the freelancers mapping
        address bidderAddress = msg.sender;
        Freelancer storage freelancer = freelancers[bidderAddress];
        require(bytes(freelancer.name).length != 0, "Freelancer not found");

        // Store the bid information
        gig.bidders[bidderAddress] = Bidder(
            freelancer.name,
            freelancer.skills,
            freelancer.portfolioURL,
            bidAmount
        );
        gig.status = "bid_placed";

        emit BidPlaced(gigId, bidderAddress);
    }

    // Function to accept a freelancer bid
    function acceptBid(
        uint256 gigId,
        uint256 bidAmount,
        address freelancer,
        address escrower
    ) public {
        Gig storage gig = gigs[gigId];

        // Perform validation checks
        require(keccak256(bytes(gig.status)) != keccak256("WIP"), "Gig has a freelancer working on it already");

        gig.freelancer = freelancer;
        gig.deadline += gig.gigTimeline;
        gig.escrowAmount = bidAmount;
        gig.escrower = escrower;
        gig.status = "WIP";

        // Transfer the budget amount to the escrow account
        // escrower.deposit(gig.budget)

        emit AcceptBid(gigId, freelancer);
    }

    // Function to confirm gig completion
    function completeGig(uint256 gigId) public {
        Gig storage gig = gigs[gigId];

        // Perform validation checks and confirm completion
        require(keccak256(bytes(gig.status)) == keccak256("open"), "Gig is not open");

        // Transfer funds from escrow to freelancer account
        // Add your custom funds transfer logic here

        // Mark gig as completed
        gig.status = "completed";
    }

    function confirmGig(uint256 gigId) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(bytes(gig.status)) == keccak256("completed"), "Gig is not completed");

        gig.status = "confirm";

        // Transfer funds from escrow to freelancer account
        // Add your custom funds transfer logic here
    }

    function extendDeadline(uint256 gigId, uint256 newDeadline) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(bytes(gig.status)) != keccak256("completed"), "Gig is not completed");

        gig.status = "WIP";
        gig.deadline += newDeadline;
        gig.warningCount += 1;
    }

    function reportGig(uint256 gigId) public {
        Gig storage gig = gigs[gigId];
        if (keccak256(bytes(gig.status)) == keccak256("WIP") && gig.warningCount == 3) {
            // Transfer funds from escrow to gigowner account
            // Add your custom funds transfer logic here
        }
        if (keccak256(bytes(gig.status)) == keccak256("completed") && gig.warningCount == 3) {
            // Transfer funds from escrow to freelancer account
            // Add your custom funds transfer logic here
            // getFreelancers struct and increment his no of completed gig
        }

        gig.status = "reported";
    }

    // Verify Freelancer
    function verifyFreelancer(address freelancerAddress, uint32 stars) public {
        Freelancer storage freelancer = freelancers[freelancerAddress];
        if (!freelancer.verified) {
            freelancer.verified = true;
            freelancer.stars = stars;
        }
    }

    // Update Freelancer
    function updateFreelancer(address freelancerAddress) public view{
        Freelancer storage freelancer = freelancers[freelancerAddress];
        // update freelancer's parameter
    }

    // Internal helper function to get gig
    function getGig(uint256 gigId) internal view returns (Gig storage) {
        Gig storage gig = gigs[gigId];
        require(gig.id != 0, "Gig not found");
        return gig;
    }

    // Internal helper function to generate a unique gig ID
    function getCurrentGigId() internal view returns (uint256) {
        return noOfCreatedGigs;
    }
}
