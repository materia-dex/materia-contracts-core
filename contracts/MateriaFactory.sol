pragma solidity =0.5.16;

import './interfaces/IMateriaFactory.sol';
import './MateriaPair.sol';

contract MateriaFactory is IMateriaFactory, MateriaOwnable {
    address public feeTo;

    uint public defaultMateriaFee;
    uint public defaultSwapFee;
    address public defaultPairOwner;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(uint _defaultMateriaFee, uint _defaultSwapFee) MateriaOwnable() public {
        defaultMateriaFee = _defaultMateriaFee; //Default value: 5
        defaultSwapFee = _defaultSwapFee; //Default value: 3
    }

    function allPairsLength() external view returns (uint) {
       return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Materia: identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Materia: zero address");
        require(getPair[token0][token1] == address(0), "Materia: pair already exists"); // single check is sufficient
        bytes memory bytecode = type(MateriaPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMateriaPair(pair).initialize(token0, token1, defaultMateriaFee, defaultSwapFee);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) onlyOwner external {
        feeTo = _feeTo;
    }
    
    function setDefaultMateriaFee(uint _defaultMateriaFee) onlyOwner external {
        defaultMateriaFee = _defaultMateriaFee;
    }
    
    function setDefaultSwapFee(uint _defaultSwapFee) onlyOwner external {
        defaultSwapFee = _defaultSwapFee;
    }
    
    function setFees(address pair, uint materiaFee, uint swapFee) onlyOwner external {
        IMateriaPair(pair).setSwapFee(swapFee);
        IMateriaPair(pair).setMateriaFee(materiaFee);
    }
}

