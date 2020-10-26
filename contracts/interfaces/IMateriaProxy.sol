pragma solidity >=0.5.0;

interface IMateriaProxy {

    function setProxy(address proxy) external;
    function getProxy() external view returns(address);
    function setDoubleProxy(address doubleProxy) external;
    function getDoubleProxy() external view returns(address);
    function changeFactory(address factory, address bridgeToken, address feeToSetter) external;
    function getFactory() external view returns(address);
    function getBridgeToken() external view returns(address);
    function setEmergencyMode(bool status) external returns(bool);
    function getEmergencyMode() external view returns(bool);
    function createPair(address token) external returns(address);

}
