// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./EthereumConverter.sol";

error NotOwner();

contract Funding {
    using EthereumConverter for uint256;

    mapping(address => uint256) public addressToFunder;
    address[] public funders;
    address public owner;
    uint256 public MINIMUM_USD = 50 * 10 ** 18;

    constructor() {
        owner = msg.sender;
    }
    
    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        addressToFunder[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner!");
       // if (msg.sender != owner) { revert NotOwner(); }
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToFunder[funder] = 0;
        }
        funders = new address[](0);
 
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

     fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    


}

