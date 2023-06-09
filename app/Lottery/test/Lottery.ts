import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { utils } from "ethers";
import { expect } from "chai";

describe("Lottery", () => {
    async function deployLottery() {
        const ticketPrice = utils.parseEther("0.1");
        const [address1, address2, address3] = await ethers.getSigners();
        const Lottery = await ethers.getContractFactory("Lottery");
        const lottery = await Lottery.deploy(
            ticketPrice,
            2681,
        );
        return { address1, address2, address3, lottery, ticketPrice };
    }

    describe("Purchase", () => { 
        it("Should purchase ticket", async function () {
            const { address1, lottery, ticketPrice } = await loadFixture(deployLottery);
            const prev = (await lottery.getParticipants()).toNumber()
            const purchaseTxn = await lottery.connect(address1).purchase({value: ticketPrice})
            await purchaseTxn.wait();
            expect((await lottery.getParticipants()).toNumber()).to.equal(prev + 1);
        })

        it("Should revert : Ticket price is not correct", async function () {
            const { address1, lottery } = await loadFixture(deployLottery);
            await expect(lottery.connect(address1).purchase({value: 0})).to.revertedWith("Ticket price is not correct")
        })
    })

    describe('Select Winner', () => { 
        it("Should give a random number", async () => {
            const Lottery = await ethers.getContractFactory("Lottery");
            const lottery = await Lottery.deploy(utils.parseEther("0.1"), 2681);
            await lottery.deployed();

            console.log(lottery.address)
            
            console.log({
                x: await lottery.randomResult()
            })
        })
    })
})