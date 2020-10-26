pragma solidity =0.5.16;

import './interfaces/IMateriaFactory.sol';
import './MateriaPair.sol';
import './interfaces/IMVDProxy.sol';

contract MateriaFactory is IMateriaFactory {
    address public feeTo;
    address public feeToSetter;
    address private _router;
    address private _bridgeToken;
    bool private _emergencyMode;
    
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor() public {
	_emergencyMode = false;
    }
    
    modifier byRouter {
	require(msg.sender == _router, "Materia: the factory must be called by the proxy");
	_;
    }

    modifier checkEmergency {
	require(!_emergencyMode, "Materia: emergency mode enabled");
	_;
    }
    
    function init(address bridgeToken, address _feeToSetter) external {
	require(_router == address(0), "Materia: this factory was already initialized");
	_router = msg.sender;
	_bridgeToken = bridgeToken;
        feeToSetter = _feeToSetter;
    }

    function setRouter(address newRouter) external byRouter checkEmergency {
	_router = newRouter;
    }

    function getRouter() external view returns(address) {
	return _router;
    }
    
    function setEmergencyMode(bool status) external byRouter returns(bool) {
	return _emergencyMode = status;
    }

    function getEmergencyMode() external view returns(bool) {
	return _emergencyMode;
    }
    
    function getBridgeToken() external view returns(address) {
	return _bridgeToken;
    }
    
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address token) external byRouter checkEmergency returns (address pair) {
	address tokenA = token;
	address tokenB = _bridgeToken;
        require(tokenA != tokenB, "Materia: identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Materia: zero address");
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

    function setFeeTo(address _feeTo) external checkEmergency {
        require(msg.sender == feeToSetter, "Materia: forbidden");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external checkEmergency {
        require(msg.sender == feeToSetter, "Materia: forbidden");
        feeToSetter = _feeToSetter;
    }
}

