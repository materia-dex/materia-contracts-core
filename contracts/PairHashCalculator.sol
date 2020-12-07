pragma solidity =0.5.16;

import './MateriaPair.sol';

/* This contract is only an helper, actually this is not deployed
   and there is no reason to deploy it since it can be effectively
   executed off chain, e.g. in a JavaScript VM. */

contract PairHashCalculator {

    function getPairHash() public pure returns(bytes32) {
        return keccak256(type(MateriaPair).creationCode);
    }

}