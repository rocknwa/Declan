//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Decln {

    //
    // Events
    //

    event GigCreated(uint64 gigId);
    event BidPlaced(uint64 gigId, address bidder);
    event FreelancerJoined(address freelancer);
    event AcceptBid(uint64 gigId, address freelancer);

    //
    // State
    // 

    struct Freelancer {
        string name;
        address freelancerAddress;
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

    struct Bidder {
        string freelancerName;
        string[] freelancerSkills;
        string freelancerPortfolioURL;
        uint64 bidAmount;
    }

    struct Gig {
        uint64 id;
        address owner;
        string ownerEmail;
        address freelancer;
        string title;
        string description;
        uint64 gigTimeline;
        uint64 deadline;
        uint64 budget;
        bool featureGig;
        mapping(address => Bidder) bidders;
        string status;
        address escrower;
        uint64 escrowAmount;
        uint64 warningCount;
    }

    mapping(address => Freelancer) public freelancers;
    mapping(address => GigOwner) public gigOwners;
    mapping(uint64 => Gig) public gigs;

    uint64 public noOfFreelancers;
    uint64 public noOfGigOwners;
    uint64 public noOfCreatedGigs;

    //
    // logic
    // 

    // Function to create a freelancer account
    function createFreelancerAccount(
        string memory name,
        address freelancerAddress,
        string memory portfolioURL,
        string[] memory skills,
        string[] memory categories,
        bool verified,
        uint32 stars,
        string memory email,
        string memory country,
        uint32 jobCount
    ) public {
        freelancers[freelancerAddress] = Freelancer(
            name,
            freelancerAddress,
            portfolioURL,
            skills,
            categories,
            verified,
            stars,
            email,
            country,
            jobCount
        );

        emit FreelancerJoined(freelancerAddress);
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
        uint64 gigTimeline,
        uint64 budget
    ) public returns (uint64) {
        uint64 newGigId = getCurrentGigId();

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
    function placeBid(uint64 gigId, uint64 bidAmount) public {
        Gig storage gig = gigs[gigId];

        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("open")), "Gig is not open");
        require(bidAmount <= gig.budget, "Bid amount must be less than or equal to gig budget");

        Freelancer storage freelancer = freelancers[msg.sender];
        require(freelancer.freelancerAddress != address(0), "Freelancer not found");

        gig.bidders[msg.sender] = Bidder(
            freelancer.name,
            freelancer.skills,
            freelancer.portfolioURL,
            bidAmount
        );
        gig.status = "bid_placed";

        emit BidPlaced(gigId, msg.sender);
    }

    // Function to accept a freelancer bid
    function acceptBid(uint64 gigId, uint64 bidAmount, address freelancer, address escrower) public {
        Gig storage gig = gigs[gigId];

        require(keccak256(abi.encodePacked(gig.status)) != keccak256(abi.encodePacked("WIP")), "Gig has a freelancer working on it already");

        gig.freelancer = freelancer;
        gig.deadline += gig.gigTimeline;
        gig.escrowAmount = bidAmount;
        gig.escrower = escrower;
        gig.status = "WIP";

        // Transfer the budget amount to the escrow account
        // escrower.transfer(gig.budget);

        emit AcceptBid(gigId, freelancer);
    }

    // Function to confirm gig completion
    function completeGig(uint64 gigId) public {
        Gig storage gig = gigs[gigId];

        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("open")), "Gig is not open");

        // Transfer funds from escrow to freelancer account
        // Add your custom funds transfer logic here

        gig.status = "completed";
    }

    // Function to confirm gig
    function confirmGig(uint64 gigId) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("completed")), "Gig is not completed");

        gig.status = "confirm";

        // Transfer funds from escrow to freelancer account
        // Add your custom funds transfer logic here
    }

    // Function to extend deadline
    function extendDeadline(uint64 gigId, uint64 newDeadline) public {
        Gig storage gig = gigs[gigId];
        require(keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("WIP")), "Gig is not in progress");

        gig.deadline += newDeadline;
        gig.warningCount += 1;
    }

    // Function to report a gig
    function reportGig(uint64 gigId) public {
        Gig storage gig = gigs[gigId];
        if (keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("WIP")) && gig.warningCount == 3) {
            // Transfer funds from escrow to gig owner account
            // Add your custom funds transfer logic here
        }
        if (keccak256(abi.encodePacked(gig.status)) == keccak256(abi.encodePacked("completed")) && gig.warningCount == 3) {
            // Transfer funds from escrow to freelancer account
            // Add your custom funds transfer logic here
            // getFreelancers struct and increment their no of completed gigs
        }

        gig.status = "reported";
    }

    // Verify Freelancer
    function verifyFreelancer(address freelancerAddress, uint32 stars) public {
        Freelancer storage freelancer = freelancers[freelancerAddress];
        require(!freelancer.verified, "Freelancer already verified");

        freelancer.verified = true;
        freelancer.stars = stars;
    }

    // Update Freelancer
    function updateFreelancer(address freelancerAddress, string memory name, string memory portfolioURL, string[] memory skills, string[] memory categories, bool verified, uint32 stars, string memory email, string memory country, uint32 jobCount) public {
        Freelancer storage freelancer = freelancers[freelancerAddress];
        freelancer.name = name;
        freelancer.portfolioURL = portfolioURL;
        freelancer.skills = skills;
        freelancer.categories = categories;
        freelancer.verified = verified;
        freelancer.stars = stars;
        freelancer.email = email;
        freelancer.country = country;
        freelancer.jobCount = jobCount;
    }

    // Internal helper function to get gig 
    function getGig(uint64 gigId) internal view returns (Gig storage) {
        Gig storage gig = gigs[gigId];
        require(gig.id != 0, "Gig not found");
        return gig;
    }

    // Internal helper function to generate a unique gig ID
    function getCurrentGigId() internal view returns (uint64) {
        return noOfCreatedGigs;
    }

}
