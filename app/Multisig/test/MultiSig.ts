import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
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
    const [owner1, owner2, owner3, notOwner1, notOwner2] =
      await ethers.getSigners();

    const MultiSig = await ethers.getContractFactory("MultiSig");
    const multiSig = await MultiSig.deploy(
      [owner1.address, owner2.address, owner3.address],
      confirmationsRequired,
      { value: amount }
    );

    return {
      multiSig,
      confirmationsRequired,
      owner1,
      owner2,
      owner3,
      notOwner1,
      notOwner2,
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
        const { multiSig, notOwner1 } = await loadFixture(deployMultiSigWallet);

        await expect(
          multiSig.connect(notOwner1).getTotalConfirmationsRequired()
        ).to.be.revertedWith("Not Owner!");
      });
    });

    // // Write test case for submit transaction function with respect to "MutliSig.sol" Contract in this directory
    // it("Should submit transaction", async function () {
    //   const { multiSig, owner1, notOwner1 } = await loadFixture(
    //     deployMultiSigWallet
    //   );

    //   const _to = notOwner1.address;
    //   const _value = utils.parseEther("0.5").toString();
    //   const _data = "0x00";

    //   await multiSig.connect(owner1).submit(_to, _value, _data);

    // });

    // Write test case for confirm transaction function with respect to "MutliSig.sol" Contract in this directory

    // Write test case for revoke confirmation function with respect to "MutliSig.sol" Contract in this directory

    // Write test case for execute transaction function with respect to "MutliSig.sol" Contract in this directory
  });
});
