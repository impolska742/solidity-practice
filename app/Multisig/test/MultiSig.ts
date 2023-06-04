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

    describe("Submit Transaction", () => {
      it("Should submit transaction and increase transaction count", async function () {
        const { multiSig, owner1, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const prev = (await multiSig.connect(owner1).getTotalTransactions()).toNumber();
        const submitTxn = await multiSig.connect(owner1).submit(_to, _value, _data);
        await submitTxn.wait()
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

      it("Should revert - Transaction has been executed", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
        const executeTxn = await multiSig.connect(deployer).execute(0)
        await executeTxn.wait()
        await expect(multiSig.connect(deployer).approve(0)).to.revertedWith("Transaction has been executed");
      });
    });

    describe("Reject Transaction", () => {
      it("Should reject transaction", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer } = await loadFixture(deployMultiSigWallet);
        const _to = nonDeployer.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const rejectTxn1 = await multiSig.connect(deployer).reject(0);
        await rejectTxn1.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev - 1);
      });

      it("Should reject twice", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer } = await loadFixture(deployMultiSigWallet);
        const _to = nonDeployer.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const rejectTxn1 = await multiSig.connect(deployer).reject(0);
        await rejectTxn1.wait();
        const rejectTxn2 = await multiSig.connect(nonDeployer).reject(0);
        await rejectTxn2.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(0);
      });

      it("Should revert - Not Owner", async function () {
        const { multiSig, owner1:deployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        await expect(multiSig.connect(notOwner1).reject(0)).to.revertedWith("Not Owner!");
      });

      it("Should revert - Txn does not exist", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer } = await loadFixture(deployMultiSigWallet);
        const _to = nonDeployer.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        await expect(multiSig.connect(nonDeployer).reject(1)).to.revertedWith("Transaction does not exist");
      });

      it("Should revert - Transaction has been executed", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
        const executeTxn = await multiSig.connect(deployer).execute(0)
        await executeTxn.wait()
        await expect(multiSig.connect(deployer).reject(0)).to.revertedWith("Transaction has been executed");
      });
    })

    describe("Execute Transaction", () => {
      it("Should execute transaction", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1, confirmationsRequired } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.greaterThanOrEqual(confirmationsRequired);
        const prevUserBalance = await notOwner1.getBalance()
        const prevContractBalance = await multiSig.getBalance()
        const executeTxn = await multiSig.connect(deployer).execute(0);
        await executeTxn.wait();
        expect(await notOwner1.getBalance()).to.equal(prevUserBalance.add(_value))
        expect(await multiSig.getBalance()).to.equal(prevContractBalance.sub(_value))
      });

      it("Should revert - Not Owner", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
        await expect(multiSig.connect(notOwner1).execute(0)).to.revertedWith("Not Owner!");
      });

      it("Should revert - Txn does not exist", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
        await expect(multiSig.connect(deployer).execute(1)).to.revertedWith("Transaction does not exist");
      });

      it("Should revert - Txn not approved by enough owner", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        await expect(multiSig.connect(deployer).execute(0)).to.revertedWith("Transaction not approved by enough owners");
      });

      it("Should revert - Transaction has been executed", async function () {
        const { multiSig, owner1:deployer, owner2:nonDeployer, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5"); 
        const _data = "0x00";
        const submitTxn = await multiSig.connect(deployer).submit(_to, _value, _data);
        await submitTxn.wait();
        const prev = (await multiSig.transactions(0)).totalConfirmations.toNumber()
        const approveTxn = await multiSig.connect(nonDeployer).approve(0);
        await approveTxn.wait();
        expect((await multiSig.transactions(0)).totalConfirmations.toNumber()).to.equal(prev + 1);
        const executeTxn = await multiSig.connect(deployer).execute(0)
        await executeTxn.wait()
        await expect(multiSig.connect(deployer).execute(0)).to.revertedWith("Transaction has been executed");
      });
    })

    describe("Events", () => {
      it("Should emit Submit Event", async () => {
        const { multiSig, owner1, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const txIndex = await multiSig.connect(owner1).getTotalTransactions()
        await expect(multiSig.connect(owner1).submit(_to, _value, _data)).to.emit(multiSig, "Submit").withArgs(owner1.address, txIndex, notOwner1.address, _value, _data);
      })

      it("Should emit Approve Event", async () => {
        const { multiSig, owner1, owner2, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const txIndex = await multiSig.connect(owner1).getTotalTransactions()
        await expect(multiSig.connect(owner1).submit(_to, _value, _data)).to.emit(multiSig, "Submit").withArgs(owner1.address, txIndex, notOwner1.address, _value, _data);
        await expect(multiSig.connect(owner2).approve(0)).to.emit(multiSig, "Approve").withArgs(owner2.address, txIndex)
      })

      it("Should emit Reject Event", async () => {
        const { multiSig, owner1, owner2, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const txIndex = await multiSig.connect(owner1).getTotalTransactions()
        await expect(multiSig.connect(owner1).submit(_to, _value, _data)).to.emit(multiSig, "Submit").withArgs(owner1.address, txIndex, notOwner1.address, _value, _data);
        await expect(multiSig.connect(owner2).reject(0)).to.emit(multiSig, "Reject").withArgs(owner2.address, txIndex)
      })

      it("Should emit Execute Event", async () => {
        const { multiSig, owner1, owner2, notOwner1 } = await loadFixture(deployMultiSigWallet);
        const _to = notOwner1.address;
        const _value = utils.parseEther("0.5").toString();
        const _data = "0x00";
        const txIndex = await multiSig.connect(owner1).getTotalTransactions()
        await expect(multiSig.connect(owner1).submit(_to, _value, _data)).to.emit(multiSig, "Submit").withArgs(owner1.address, txIndex, notOwner1.address, _value, _data);
        await expect(multiSig.connect(owner2).approve(0)).to.emit(multiSig, "Approve").withArgs(owner2.address, txIndex)
        await expect(multiSig.connect(owner1).execute(0)).to.emit(multiSig, "Execute").withArgs(owner1.address, txIndex)
      })

      it("Should emit Deposit Event", async () => {
        const { multiSig, owner1 } = await loadFixture(deployMultiSigWallet);
        const _to = multiSig.address
        const _value = utils.parseEther("0.5")
        await expect(owner1.sendTransaction({ to: _to,value: _value})).to.emit(multiSig, "Deposit").withArgs(owner1.address, _value, (await multiSig.getBalance()).add(_value))
      })
    })
  });
});
