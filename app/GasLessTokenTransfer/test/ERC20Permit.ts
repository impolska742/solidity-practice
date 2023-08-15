import { ethers } from "hardhat";
import { BigNumberish, constants, Signature, Wallet } from 'ethers'
import { splitSignature } from 'ethers/lib/utils'


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

  console.log({nonce, name, version, chainId})

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

  console.log({
    domain,
    types,
    valueToSign
    
  })

  return splitSignature(
    await wallet._signTypedData(
      domain,
      types,
      valueToSign
    )
  )
}

describe("ERC20Permit", function () {
    it("ERC20 permit", async function () { 
        const accounts = await ethers.getSigners();
        const signer = accounts[0];

        const reciever = accounts[1];

        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy();

        await token.deployed()

        const GasLessTokenTransfer = await ethers.getContractFactory("GasLessTokenTransfer");
        const gaslessTokenTransfer = await GasLessTokenTransfer.deploy(token.address);

        await token.mint(signer.address, 10000);
        const amount = 1000;
        const fee = 50;

        const deadLine = ethers.constants.MaxUint256;

        const {v, r, s} = await getPermitSignature(signer as unknown as Wallet, token, gaslessTokenTransfer.address, amount, deadLine)

        await gaslessTokenTransfer.send(signer.address, reciever.address, amount, fee, deadLine, v, r, s);
    });
})