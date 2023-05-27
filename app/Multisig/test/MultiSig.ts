import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { utils } from "ethers";

describe("Multisig", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployMultiSigWallet() {
    // One Ether
    const amount = utils.parseEther("1").toString();

    // Confirmations required
    const confirmationsRequired = 2;

    // List of owners of multi sig wallet
    const [owner1, owner2, owner3, notOwner] = await ethers.getSigners();

    const MultiSig = await ethers.getContractFactory("MultiSig");
    const multiSig = await MultiSig.deploy(
      [owner1.address, owner2.address, owner3.address],
      confirmationsRequired,
      { value: amount }
    );

    console.log({
      multiSig,
      confirmationsRequired,
      owner1,
      owner2,
      owner3,
      notOwner,
    });

    return {
      multiSig,
      confirmationsRequired,
      owner1,
      owner2,
      owner3,
      notOwner,
    };
  }

  describe("Deployment", function () {
    describe("confirmationsRequired", function () {
      it("Should return confirmationsRequired", async function () {
        const { multiSig, owner1, confirmationsRequired } = await loadFixture(
          deployMultiSigWallet
        );

        expect(
          await multiSig.connect(owner1).getTotalConfirmationsRequired()
        ).to.equal(confirmationsRequired);
      });

      it("Should revert by calling getTotalConfirmationsRequired", async function () {
        const { multiSig, notOwner } = await loadFixture(deployMultiSigWallet);
      });
    });
  });
});
