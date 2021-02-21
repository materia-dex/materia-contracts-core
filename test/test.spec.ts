import { expect, use } from 'chai';
import { Contract } from 'ethers';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';
import { AddressZero } from 'ethers/constants'

import MateriaFactory from '../build/MateriaFactory.json'

use(solidity);

describe('Test example: create a factory', () => {
    const [wallet] = new MockProvider().getWallets();
    let factory: Contract;

    beforeEach(async () => {
        factory = await deployContract(wallet, MateriaFactory, [5, 3]);
    });

    it('Initially there are zero pairs', async () => {
        expect(await factory.allPairsLength()).to.equal(0);
    });
});
