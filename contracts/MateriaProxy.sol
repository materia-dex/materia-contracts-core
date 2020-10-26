pragma solidity =0.5.16;

import './interfaces/IMateriaProxy.sol';
import './interfaces/IMateriaFactory.sol';
import './interfaces/IMVDProxy.sol';
import './interfaces/IDoubleProxy.sol';
import './interfaces/IMVDFunctionalitiesManager.sol';

contract MateriaProxy is IMateriaProxy {
    address private _proxy;
    address private _doubleProxy;
    address private _factory;
    address private _bridgeToken;

    constructor (address proxy, address factory, address bridgeToken, address feeToSetter) public {
	_proxy = proxy;
	_doubleProxy = IMVDProxy(proxy).getDoubleProxyAddress();
	_factory = factory;
	_bridgeToken = bridgeToken;
	IMateriaFactory(factory).init(bridgeToken, feeToSetter);
    }

    modifier byDFO {
	require(IMVDFunctionalitiesManager(IMVDProxy(_proxy).getMVDFunctionalitiesManagerAddress()).isAuthorizedFunctionality(msg.sender), "Materia: this action must be performed by the DFO!");
        _;
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'Materia: expired');
        _;
    }

    function setProxy(address proxy) public byDFO {
	_proxy = proxy;
    }

    function getProxy() public view returns(address) {
	return _proxy;
    }

    function setDoubleProxy(address doubleProxy) public byDFO {
	_doubleProxy = doubleProxy;
    }

    function getDoubleProxy() public view returns(address) {
	return _doubleProxy;
    }

    function changeFactory(address factory, address bridgeToken, address feeToSetter) public byDFO {
	_factory = factory;
	_bridgeToken = bridgeToken;
	IMateriaFactory(factory).init(bridgeToken, feeToSetter);
    }
    
    function getFactory() public view returns(address) {
	return _factory;
    }

    function getBridgeToken() public view returns(address) {
	return _bridgeToken;
    }

    function setEmergencyMode(bool status) public byDFO returns(bool) {
	return IMateriaFactory(_factory).setEmergencyMode(status);
    }

    function getEmergencyMode() public view returns(bool) {
	return IMateriaFactory(_factory).getEmergencyMode();
    }

    function createPair(address token) public returns(address) {
	return IMateriaFactory(_factory).createPair(token);
    }

}
