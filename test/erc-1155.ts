import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('ERC1155 Contract', function () {
  let erc1155Contract;
  let owner;
  let recipient;
  let tokenIds;
  const uri = 'https://example.com/api/token/{id}.json';

  beforeEach(async function () {
    [owner, recipient] = await ethers.getSigners();

    // Deploy the ERC1155 contract
    const ERC1155 = await ethers.getContractFactory('ERC1155');
    erc1155Contract = await ERC1155.deploy(uri);

    // Mint some tokens for the owner
    tokenIds = [1, 2, 3];
    const values = [10, 20, 30];
    await erc1155Contract.mint(owner.address, tokenIds, values, []);
  });

  it('should have a URI for the tokens', async function () {
    expect(await erc1155Contract.uri(1)).to.equal(uri.replace('{id}', '1'));
  });

  it('should return correct balance for owner', async function () {
    expect(await erc1155Contract.balanceOf(owner.address, 1)).to.equal(10);
    expect(await erc1155Contract.balanceOf(owner.address, 2)).to.equal(20);
    expect(await erc1155Contract.balanceOf(owner.address, 3)).to.equal(30);
  });

  it('should transfer tokens between accounts', async function () {
    await erc1155Contract.safeTransferFrom(owner.address, recipient.address, 1, 5, '0x');

    expect(await erc1155Contract.balanceOf(owner.address, 1)).to.equal(5);
    expect(await erc1155Contract.balanceOf(recipient.address, 1)).to.equal(5);
  });

  it('should batch transfer tokens between accounts', async function () {
    const ids = [1, 2, 3];
    const values = [5, 10, 15];
    await erc1155Contract.safeBatchTransferFrom(owner.address, recipient.address, ids, values, '0x');

    for (let i = 0; i < ids.length; i++) {
      expect(await erc1155Contract.balanceOf(owner.address, ids[i])).to.equal(5);
      expect(await erc1155Contract.balanceOf(recipient.address, ids[i])).to.equal(values[i]);
    }
  });

  it('should approve operator to transfer tokens', async function () {
    const operator = await ethers.Wallet.createRandom();
    const tokenId = 1;
    await erc1155Contract.setApprovalForAll(operator.address, true);

    await erc1155Contract.connect(operator).safeTransferFrom(owner.address, recipient.address, tokenId, 5, '0x');

    expect(await erc1155Contract.balanceOf(owner.address, tokenId)).to.equal(5);
    expect(await erc1155Contract.balanceOf(recipient.address, tokenId)).to.equal(5);
  });

  it('should check approval status for operator', async function () {
    const operator = await ethers.Wallet.createRandom();
    const tokenId = 1;
    await erc1155Contract.setApprovalForAll(operator.address, true);

    expect(await erc1155Contract.isApprovedForAll(owner.address, operator.address)).to.equal(true);
    expect(await erc1155Contract.isApprovedForAll(recipient.address, operator.address)).to.equal(false);
  });
});
