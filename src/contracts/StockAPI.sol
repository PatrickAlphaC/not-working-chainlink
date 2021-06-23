pragma solidity >=0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract StockAPI is ChainlinkClient {
    constructor() public {
        owner = payable(msg.sender);
        setPublicChainlinkToken();
        oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40;
        jobId = "187bb80e5ee74a139734cac7475f3c6e";
        fee = 0.01 * 10**18; // 0.01 LINK
    }

    address payable public owner;
    address private oracle;

    uint256 private fee;

    bytes32 private jobId;

    function requestStockPrice(address _cbContract, bytes4 _cbFunction)
        external
        returns (bytes32 requestId)
    {
        Chainlink.Request memory request =
            buildChainlinkRequest(jobId, _cbContract, _cbFunction);
        request.add(
            "get",
            "https://api.twelvedata.com/time_series?symbol=DAI&exchange=XETR&start_date=2021-06-17 17:28&end_date=2021-06-17 17:28&interval=1min&apikey=d8f072b5b5314d29b71c1ff807cf4109"
        );
        request.add("path", "values.0.close");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
}
