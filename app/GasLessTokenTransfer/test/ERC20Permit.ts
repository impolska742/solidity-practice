import { ethers } from "hardhat";
import { BigNumberish, constants, Signature, Wallet } from 'ethers'
import { expect } from "chai";

export async function getPermitSignature(
  wallet: Wallet,
  token: any,
  spender: string,
  value: BigNumberish = constants.MaxUint256,
  deadline = constants.MaxUint256,
): Promise<Signature> {
  const [nonce, name, version, chainId] = await Promise.all([
    token.nonces(wallet.address),
    token.name(),
    '1',
    wallet.getChainId(),
  ])

  const domain = {
    name,
    version,
    chainId,
    verifyingContract: token.address,
  }

  const types = {
    "Permit" : [
      {
        name: 'owner',
        type: 'address',
      },
      {
        name: 'spender',
        type: 'address',
      },
      {
        name: 'value',
        type: 'uint256',
      },
      {
        name: 'nonce',
        type: 'uint256',
      },
      {
        name: 'deadline',
        type: 'uint256',
      },
    ]
  }

  const valueToSign = {
    owner: wallet.address,
    spender,
    value,
    nonce,
    deadline,
  }

  const result = await wallet._signTypedData(domain, types, valueToSign);
  const signature = ethers.utils.splitSignature(result);
  return signature
}

describe("ERC20Permit", function () {
    it("ERC20 permit", async function () { 
        const accounts = await ethers.getSigners();
        const signer = accounts[0];

        const reciever = accounts[1];

        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy();

        await token.deployed()

        await token.mint(signer.address, 10000);
        const amount = 1000;
        const fee = 50;

        expect((await token.balanceOf(signer.address))).to.equal(ethers.BigNumber.from(10000));

        const deadLine = ethers.constants.MaxUint256;

        const {v, r, s} = await getPermitSignature(signer as unknown as Wallet, token, token.address, amount, deadLine)

        console.log({v, r, s});

        await token.gaslessTransfer(signer.address, reciever.address, amount, fee, deadLine, v, r, s);
    });
})