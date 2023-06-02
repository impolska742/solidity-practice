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
    const [owner1, owner2, owner3, notOwner1, notOwner2] = await ethers.getSigners();
    const MultiSig = await ethers.getContractFactory("MultiSig");
    const multiSig = await MultiSig.deploy(
      [owner1.address, owner2.address, owner3.address],
      confirmationsRequired,
      { value: amount }
    );
    return { multiSig, confirmationsRequired, owner1, owner2, owner3, notOwner1, notOwner2};
  }

  describe("Deployment", function () {
    describe("Getting Confirmations", function () {
      it("Should return confirmationsRequired", async function () {
        const { multiSig, owner1, confirmationsRequired } = await loadFixture(deployMultiSigWallet);
        expect(await multiSig.connect(owner1).getTotalConfirmationsRequired()).to.equal(confirmationsRequired);
      });

      it("Should revert by calling getTotalConfirmationsRequired", async function () {
        const { multiSig, notOwner1 } = await loadFixture(deployMultiSigWallet);
        await expect(multiSig.connect(notOwner1).getTotalConfirmationsRequired()).to.be.revertedWith("Not Owner!");
      });
    });

    // Write test case for submit transaction function with respect to "MutliSig.sol" Contract in this directory
    describe("Submit Transaction", () => {
      it("Should submit transaction and increase transaction count", async function () {
        const { multiSig, owner1, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const prev = (await multiSig.connect(owner1).getTotalTransactions()).toNumber();
        await multiSig.connect(owner1).submit(_to, _value, _data);
        const next = (await multiSig.connect(owner1).getTotalTransactions()).toNumber();
        expect(next).to.equal(prev + 1);
      });

      it("Should revert as the caller is not owner", async function () {
        const { multiSig, owner1, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = owner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        await expect(multiSig.connect(notOwner1).submit(_to, _value, _data)).to.revertedWith("Not Owner!");
      });
    });

    describe("Approve Transaction", () => {
      it("Should approve transaction", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer } = await loadFixture(deployMultiSigWallet);
        const _to = nonDeployer.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.connect(deployer).transactions(0)).totalConfirmations.toNumber();
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
      });

      it("Should revert - Not Owner", async function () {
        const { multiSig, owner1:deployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        await expect(multiSig.connect(notOwner1).approve(0)).to.revertedWith("Not Owner!");
      });

      it("Should revert - Txn does not exist", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer } = await loadFixture(deployMultiSigWallet);
        const _to = nonDeployer.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        await expect(multiSig.connect(nonDeployer).approve(1)).to.revertedWith("Transaction does not exist");
      });

      it("Should revert - Already Approved", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer } = await loadFixture(deployMultiSigWallet);
        const _to = nonDeployer.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        await expect(multiSig.connect(deployer).approve(0)).to.revertedWith("Transaction already approved");
      });
    });
  });
});
