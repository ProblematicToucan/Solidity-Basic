// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice(address chainlink) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            chainlink
        );
        (, int256 answer,,,) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount, address chainlink) internal view returns (uint256) {
        uint256 ethPrice = getPrice(chainlink);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion(address chainlink) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            chainlink
        );
        return priceFeed.version();
    }
}
