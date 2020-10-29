pragma solidity =0.5.16;

import './interfaces/IMateriaFactory.sol';
import './MateriaPair.sol';
import './interfaces/IMVDProxy.sol';

contract MateriaFactory is IMateriaFactory {
    address public feeTo;
    address public feeToSetter;
    address private _materiaProxy;
    address private _bridgeToken;
    bool private _emergencyMode;
    
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor() public {
	    _emergencyMode = false;
    }
    
    modifier byMateriaProxy {
	    require(msg.sender == _materiaProxy, "Materia: the factory must be called by the proxy");
	    _;
    }

    modifier checkEmergency {
	    require(!_emergencyMode, "Materia: emergency mode enabled");
	    _;
    }
    
    function init(address bridgeToken, address _feeToSetter) external {
	    require(_materiaProxy == address(0), "Materia: this factory was already initialized");
	    _materiaProxy = msg.sender;
	    _bridgeToken = bridgeToken;
        feeToSetter = _feeToSetter;
    }

    function setMateriaProxy(address newMateriaProxy) external byMateriaProxy checkEmergency {
	    _materiaProxy = newMateriaProxy;
    }

    function getMateriaProxy() external view returns(address) {
	    return _materiaProxy;
    }
    
    function setEmergencyMode(bool status) external byMateriaProxy returns(bool) {
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

    function createPair(address tokenA, address tokenB) external byMateriaProxy checkEmergency returns (address pair) {
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

