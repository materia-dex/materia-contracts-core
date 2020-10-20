pragma solidity ^0.7.4;

import './interfaces/IMVDProxy.sol';
import './interfaces/IStateHolder.sol';

contract EmergencyModeFunctionality {

    string private _metadataLink;

    constructor(string memory metadataLink) {
        _metadataLink = metadataLink;
    }

    function getMetadataLink() public view returns(string memory) {
        return _metadataLink;
    }

    function onStart(address, address) public {
        IMVDProxy proxy = IMVDProxy(msg.sender);
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());
        stateHolder.setBool("exchange.emergency.mode", false);
    }

    function onStop(address) public {
        IStateHolder stateHolder = IStateHolder(IMVDProxy(msg.sender).getStateHolderAddress());
        stateHolder.clear("exchange.emergency.mode");
    }

    function setEmergencyMode(address sender, uint256, bool value) public {
        IMVDProxy proxy = IMVDProxy(msg.sender);
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());
        stateHolder.setBool("exchange.emergency.mode", value);
    }
}

