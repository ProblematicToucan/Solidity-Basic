// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    address private immutable i_owner;
    address private immutable i_priceFeed;

    uint256 private constant MINIMUM_USD = 5e18;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        i_priceFeed = _priceFeed;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(i_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() external onlyOwner {
        address[] memory funders = s_funders;
        uint256 fundersLength = funders.length;
        
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getVersion() external view returns (uint256) {
        return PriceConverter.getVersion(i_priceFeed);
    }

    // View / Pure
    function getContractOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeedContract() external view returns (address) {
        return i_priceFeed;
    }

    function getMinimumUSD() external pure returns (uint256) {
        return MINIMUM_USD;
    }

    function getFunder(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getAddressToAmountFunded(address _address) external view returns (uint256) {
        return s_addressToAmountFunded[_address];
    }
}
