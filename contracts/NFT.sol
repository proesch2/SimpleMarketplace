// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title NFT
 * @author @proesch2
 * @notice NFT contract for testing purposes
 */
contract NFT is ERC721{
    uint256 id;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_){}

    function mint() public {
        _mint(msg.sender, id++);
    }
}