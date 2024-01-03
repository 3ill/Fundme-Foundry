// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./PriceConverter.sol";

error notOwner(string _errorMessage);
error insufficientToken();

/**
 * @title FundMe Contract
 * @author 3illBaby
 * @notice This contract demos a crowd funding system on the blockchain
 * @dev This contract uses a priceConverter Library powered by chainLink
 */

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18;
    address[] public funders;
    address public Owner;
    mapping(address => uint256) public amountFunded;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeedAddress) {
        Owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    modifier onlyOwner() {
        if (msg.sender != Owner) {
            revert notOwner("Not the Owner of the contract");
        }
        _;
    }

    function getVersion() external view returns (uint) {
        return PriceConverter.getVersion(priceFeed);
    }

    function fund() public payable {
        if (msg.value.getConversionRate(priceFeed) < minimumUsd) {
            revert insufficientToken();
        }
        funders.push(msg.sender);
        amountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i; i < funders.length; i++) {
            amountFunded[funders[i]] = 0;
        }

        funders = new address[](0);

        /**
            @notice: Call is the recommended way to send ETH to a contract 

        **/
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "This transaction failed");
    }
}
