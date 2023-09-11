import { expect } from 'chai';
import { ethers} from 'hardhat';
import { NFT } from '../typechain-types/';


describe('ERC721Token', function () {
  let erc721Token: NFT;
  let owner: any;
  let addr1: any;
  let addr2: any;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const ERC721TokenFactory = await ethers.getContractFactory('ERC721Token');
    erc721Token = await (await ERC721TokenFactory.deploy()).waitForDeployment()
  });

  describe('Deployment', function () {
    it('Should set the owner as the deployer', async function () {
      expect(await erc721Token.ownerOf(0)).to.equal(owner.address);
    });
  });

  describe('Minting', function () {
    it('Should mint and transfer tokens correctly', async function () {
      await erc721Token.mint(addr1.address, 1);
      expect(await erc721Token.balanceOf(addr1.address)).to.equal(1);
      expect(await erc721Token.ownerOf(1)).to.equal(addr1.address);

      await erc721Token.mint(addr2.address, 2);
      expect(await erc721Token.balanceOf(addr2.address)).to.equal(1);
      expect(await erc721Token.ownerOf(2)).to.equal(addr2.address);
    });
  });

  describe('Transfers', function () {
    it('Should transfer tokens correctly', async function () {
      await erc721Token.transferFrom(addr1.address, addr2.address, 1);
      expect(await erc721Token.balanceOf(addr1.address)).to.equal(0);
      expect(await erc721Token.balanceOf(addr2.address)).to.equal(2);
      expect(await erc721Token.ownerOf(1)).to.equal(addr2.address);
    });

    it('Should not allow unauthorized transfers', async function () {
      await expect(erc721Token.connect(addr1).transferFrom(addr2.address, addr1.address, 2)).to.be.revertedWith('Not authorized');
    });
  });

  // Add more test cases for other functions and edge cases as needed
});
