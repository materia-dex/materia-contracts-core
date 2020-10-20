pragma solidity ^0.7.4;

contract EmergencyMode {

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
        stateHolder.setAddress("exchange.emergency.mode.setter", 0xF1B0c1C3b333a2AC7750ca203FA815Be2Ee18123);
    }

    function onStop(address) public {
        IStateHolder stateHolder = IStateHolder(IMVDProxy(msg.sender).getStateHolderAddress());
        stateHolder.clear("exchange.emergency.mode");
        stateHolder.clear("exchange.emergency.mode.setter");
    }

    function setEmergencyMode(bool value) public {
        IMVDProxy proxy = IMVDProxy(msg.sender);
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());

        require(stateHolder.getAddress("exchange.emergency.mode.setter") == msg.sender, 'Unauthorized Setter'); 
        
        stateHolder.setBool("exchange.emergency.mode", value);
    }
}

interface IMVDProxy {
    function getStateHolderAddress() external view returns(address);
}

interface IStateHolder {
    function clear(string calldata varName) external returns(string memory oldDataType, bytes memory oldVal);
    function setBool(string calldata varName, bool val) external returns(bool);
    function getBool(string calldata varName) external view returns (bool);
    function getAddress(string calldata varName) external view returns (address);
    function setAddress(string calldata varName, address val) external returns (address);
}