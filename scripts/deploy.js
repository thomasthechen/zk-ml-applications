// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Hotdog = await ethers.getContractFactory("HotdogModelVerifier");
  const hotdog = await Hotdog.deploy();
  await hotdog.deployed();

  console.log("Hotdog address:", hotdog.address);

  const Language = await ethers.getContractFactory("LanguageModelVerifier");
  const language = await Language.deploy();
  await language.deployed();

  console.log("Insult address:", language.address)

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(hotdog, language);
}

function saveFrontendFiles(hotdog, language) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Language: language.address, Hotdog: hotdog.address}, undefined, 2)
  );

  const HotdogArtifact = artifacts.readArtifactSync("HotdogModelVerifier");

  fs.writeFileSync(
   path.join(contractsDir, "HotdogModelVerifier.json"),
   JSON.stringify(HotdogArtifact, null, 2)
  );

  const LanguageArtifact = artifacts.readArtifactSync("LanguageModelVerifier");
  fs.writeFileSync(
    path.join(contractsDir, "LanguageModelVerifier.json"),
    JSON.stringify(LanguageArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
