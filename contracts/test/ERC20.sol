pragma solidity =0.5.16;

import '../MateriaERC20.sol';

contract ERC20 is MateriaERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
