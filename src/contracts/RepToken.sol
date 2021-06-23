pragma solidity >=0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/IStockAPI.sol";

contract RepToken is ChainlinkClient {
    using SafeMath for uint256;

    IStockAPI public iStockAPI;

    constructor(address iStockAPIAddress) public {
        owner = payable(msg.sender);
        stockAPI = iStockAPI(iStockAPIAddress);
    }

    address payable public owner;

    uint256 public volume;

    function evaluatePredictions() external {
        stockAPI.requestStockPrice(
            address(this),
            this.fulfillEvaluation.selector
        );
    }

    function parseInt(string memory _a, uint256 _b)
        private
        pure
        returns (uint256)
    {
        bytes memory bresult = bytes(_a);
        uint256 mintt;
        bool decimals_;
        for (uint256 i = 0; i < bresult.length; i = i.add(1)) {
            if ((uint8(bresult[i]) >= 48) && (uint8(bresult[i]) <= 57)) {
                if (decimals_) {
                    if (_b == 0) break;
                    else _b = _b.sub(1);
                }
                mintt = mintt.mul(10);
                mintt = mintt.add(uint8(bresult[i]) - 48);
            } else if (uint8(bresult[i]) == 46) decimals_ = true;
        }
        if (_b > 0) mintt = mintt.mul(10**_b);
        return mintt;
    }

    function fulfillEvaluation(bytes32 _requestId, bytes32 _close)
        public
        recordChainlinkFulfillment(_requestId)
    {
        uint256 i;
        while (i < 32 && _close[i] != 0) {
            i = i.add(1);
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _close[i] != 0; i = i.add(1)) {
            bytesArray[i] = _close[i];
        }
        uint256 close = parseInt(string(bytesArray), 5);
        volume = close;
    }

    function kill() public {
        require(msg.sender == owner, "Not the contract creator.");
        selfdestruct(owner);
    }

    function withdrawLink() external {
        LinkTokenInterface linkToken =
            LinkTokenInterface(chainlinkTokenAddress());
        require(
            linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))),
            "Unable to transfer."
        );
    }
}
