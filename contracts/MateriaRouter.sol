pragma solidity =0.5.16;

import './interfaces/IMateriaFactory.sol';
import './interfaces/IMVDProxy.sol';
import './interfaces/IDoubleProxy.sol';
import './interfaces/IMVDFunctionalitiesManager.sol';

contract MateriaRouter {
    address public doubleProxy;
    address public factory;

    constructor (address proxy, address _factory, address feeToSetter) public {
	doubleProxy = IMVDProxy(proxy).getDoubleProxyAddress();
	factory = _factory;
	IMateriaFactory(factory).init(feeToSetter);
    }

    modifier byDFO {
        if(doubleProxy != address(0)) {
            require(IMVDFunctionalitiesManager(IMVDProxy(IDoubleProxy(doubleProxy).proxy()).getMVDFunctionalitiesManagerAddress()).isAuthorizedFunctionality(msg.sender), "Unauthorized Action!");
        }
        _;
    }

    function setFactory(address newFactory, address feeToSetter) external byDFO {
	factory = newFactory;
	IMateriaFactory(factory).init(feeToSetter);
    }

    function setEmergency(bool status) external byDFO {
	IMateriaFactory(factory).setEmergencyMode(status);
    }
}
