// scripts/readData.js
const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    // Replace with your deployed contract address
    const declanWorkAddress = "0xYourDeployedContractAddress";
    const DeclanWork = await hre.ethers.getContractFactory("DeclanWork");
    const declanWork = await DeclanWork.attach(declanWorkAddress);

    const noOfFreelancers = await declanWork.noOfFreelancers();
    console.log("Number of Freelancers:", noOfFreelancers.toString());

    const noOfGigOwners = await declanWork.noOfGigOwners();
    console.log("Number of Gig Owners:", noOfGigOwners.toString());

    const noOfCreatedGigs = await declanWork.noOfCreatedGigs();
    console.log("Number of Created Gigs:", noOfCreatedGigs.toString());

    // Replace with an actual freelancer address
    const freelancerAddress = "0xFreelancerAddress";
    const freelancer = await declanWork.freelancers(freelancerAddress);
    console.log("Freelancer Details:", freelancer);

    // Replace with an actual gig owner address
    const gigOwnerAddress = "0xGigOwnerAddress";
    const gigOwner = await declanWork.gigOwners(gigOwnerAddress);
    console.log("Gig Owner Details:", gigOwner);

    // Replace with an actual gig ID
    const gigId = 1;
    const gig = await declanWork.gigs(gigId);
    console.log("Gig Details:", gig);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
