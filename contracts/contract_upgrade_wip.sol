// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeclanWork {
    // Escrow contract
    struct Escrow {
        address buyer;
        address seller;
        address arbiter;
        State state;
    }
    
    // Defining an enum 'State'
    enum State {
        AwaitPayment,
        AwaitDelivery,
        Complete
    }
    
    // GigOwner struct
    struct GigOwner {
        string gigOwner;
        address gigOwnerAddress;
        bool isVerified;
        string[] stars;
    }

    // Freelancer struct
    struct Freelancer {
        string name;
        address freelancerAddress;
        string portfolioURL;
        string[] skills;
        string[] categories;
        bool verified;
        string[] stars;
    }

    // Bidder struct
    struct Bidder {
        string freelancerName;
        string[] freelancerSkills;
        string freelancerPortfolioURL;
        uint256 bidAmount;
    }

    // Gig struct
    struct Gig {
        uint64 id;
        address buyer;
        address seller;
        string title;
        string description;
        string gigTimeline;
        int16 deadline;
        uint256 budget;
        bool featureGig;
        Freelancer freelancer;
        mapping(address => Bidder) bidders;
        string status;
        bool completed;
        uint256 escrow;
    }

    // State variables
    mapping(address => Freelancer) public freelancers;
    mapping(address => GigOwner) public gigOwners;
    mapping(uint64 => Gig) public gigs;

    uint64 public noOfFreelancers;
    uint64 public noOfGigOwners;
    uint64 public noOfCreatedGigs;

    Escrow public escrow;

    constructor() {
        escrow.arbiter = msg.sender;
        escrow.state = State.AwaitPayment;
    }

    // Function to create a freelancer account
    function createFreelancerAccount(
        string memory name,
        string memory portfolioURL,
        string[] memory skills,
        string[] memory categories,
        string[] memory stars
    ) public {
        freelancers[msg.sender] = Freelancer(name, msg.sender, portfolioURL, skills, categories, false, stars);
        noOfFreelancers++;
    }

    // Function to create a gig owner account
    function createGigOwnerAccount(
        string memory gigOwner,
        address gigOwnerAddress,
        bool isVerified,
        string[] memory stars
    ) public {
        gigOwners[msg.sender] = GigOwner(gigOwner, gigOwnerAddress, isVerified, stars);
        noOfGigOwners++;
    }

    // Function to create a new gig
    function createGig(
        address buyer,
        address seller,
        string memory title,
        string memory description,
        uint256 budget,
        int16 deadline,
        string memory gigTimeline,
        bool featureGig,
        Freelancer memory freelancer,
        string memory status,
        bool completed,
        uint256 escrowAmount
    ) public returns (uint64) {
        uint64 newGigId = noOfCreatedGigs++;
        Gig storage newGig = gigs[newGigId];
        newGig.id = newGigId;
        newGig.buyer = buyer;
        newGig.seller = seller;
        newGig.title = title;
        newGig.description = description;
        newGig.gigTimeline = gigTimeline;
        newGig.deadline = deadline;
        newGig.budget = budget;
        newGig.featureGig = featureGig;
        newGig.freelancer = freelancer;
        newGig.status = status;
        newGig.completed = completed;
        newGig.escrow = escrowAmount;

        emit GigCreated(newGigId);
        return newGigId;
    }

    // Function to place a bid on a gig
    function placeBid(uint64 gigId, uint256 bidAmount) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("open")), "Gig is not open");
        require(bidAmount <= gig.budget, "Bid amount must be less than or equal to gig budget");

        Freelancer storage freelancer = freelancers[msg.sender];
        require(freelancer.freelancerAddress != address(0), "Freelancer not found");

        gig.bidders[msg.sender] = Bidder(freelancer.name, freelancer.skills, freelancer.portfolioURL, bidAmount);
        gig.status = "bid_placed";
        emit BidPlaced(gigId, msg.sender);
    }

    // Function to confirm gig completion
    function completeGig(uint64 gigId) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("open")), "Gig is not open");

        // Transfer funds from escrow to freelancer account
        // Add your custom funds transfer logic here

        gig.status = "completed";
        gig.completed = true;
    }

    // Function to confirm gig
    function confirmGig(uint64 gigId) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("completed")), "Gig is not completed");
        gig.escrow = 0;
    }

    // Verify Freelancer
    function verifyFreelancer(address freelancerAddress) public {
        Freelancer storage freelancer = freelancers[freelancerAddress];
        require(!freelancer.verified, "Freelancer is already verified");
        freelancer.verified = true;
    }

    // Event definitions
    event GigCreated(uint64 gigId);
    event BidPlaced(uint64 gigId, address bidder);
}
