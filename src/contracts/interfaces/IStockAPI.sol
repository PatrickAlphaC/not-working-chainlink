pragma solidity >=0.6.0;

interface IStockAPI {
function requestStockPrice(address _cbContract, bytes4 _cbFunction) external returns (bytes32 requestId);
}
