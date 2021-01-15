pragma solidity =0.5.16;

import './interfaces/IMateriaFactory.sol';
import './MateriaPair.sol';
import './interfaces/IMVDProxy.sol';

contract MateriaFactory is IMateriaFactory {
    address public feeTo;
    address public feeToSetter;
    
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function init(address _feeToSetter) external {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
       return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Materia: identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Materia: zero address");
        //require(token0 == _bridgeToken || token1 == _bridgeToken, "Materia: pair must be with the bridge token");
        require(getPair[token0][token1] == address(0), "Materia: pair already exists"); // single check is sufficient
        bytes memory bytecode = type(MateriaPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMateriaPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "Materia: forbidden");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "Materia: forbidden");
        feeToSetter = _feeToSetter;
    }
}

