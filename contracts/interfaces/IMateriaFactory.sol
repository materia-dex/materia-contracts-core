pragma solidity >=0.5.0;

interface IMateriaFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function init(address bridgeToken, address _feeToSetter) external;

    function setRouter(address newRouter) external; 
    function getRouter() external view returns(address);

    function getEmergencyMode() external view returns(bool); 
    function setEmergencyMode(bool status) external returns(bool);
    
    function getBridgeToken() external view returns(address);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
