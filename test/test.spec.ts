import {expect, use} from 'chai';
import {Contract} from 'ethers';
import {deployContract, MockProvider, solidity} from 'ethereum-waffle';
import {AddressZero} from 'ethers/constants'

import MateriaFactory from '../build/MateriaFactory.json'
import MateriaRouter from '../build/MateriaRouter.json'

use(solidity);

describe('Test example: create a factory', () => {
    const [wallet] = new MockProvider().getWallets();
    let factory: Contract;

    beforeEach(async () => {
	factory = await deployContract(wallet, MateriaFactory, []);
    });

    it('Initially there are zero pairs', async () => {
	expect(await factory.allPairsLength()).to.equal(0);
    });
});

describe('Router and factory cross referencing', () => {
    const [wallet] = new MockProvider().getWallets();
    let factory: Contract;
    let router: Contract;

    beforeEach(async () => {
	factory = await deployContract(wallet, MateriaFactory, []);
	let doubleProxy = AddressZero; //makes no sense
	router = await deployContract(wallet, MateriaRouter, [doubleProxy, factory.address]);
	let feeToSetter = AddressZero;
	await factory.init(feeToSetter);
    });

    it('Setting router while in emergency mode', async () => {
	await router.setEmergency(true);
	//await expect(.setRouter(AddressZero)).to.be.reverted;
    });
    
    //it('Change factory keeping the router', () => {
    //    let newFactory = await deployContract(wallet, MateriaFactory, []);
    //	  let feeToSetter = AddressZero;
    //    router.setFactory(newFactory.address);
    //});
});
