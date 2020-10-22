pragma solidity =0.5.16;

import './interfaces/IMateriaFactory.sol';
import './interfaces/IMVDProxy.sol';
import './interfaces/IDoubleProxy.sol';
import './interfaces/IMVDFunctionalitiesManager.sol';

contract MateriaRouter {
    address public doubleProxy;
    address public factory;

    constructor (address _doubleProxy, address _factory) public {
	doubleProxy = _doubleProxy;
	factory = _factory;
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
