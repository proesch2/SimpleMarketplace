// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace is IERC721Receiver {

    uint256 public index;
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public funds;
    uint256[] public available;

    struct Listing{
        address recipient;  // receiver of fees on sale
        address token;      // address of token contract
        uint256 id;         // id of token
        uint256 price;      // starting price for sale or highest bid
    }

    event Listed(address token, uint256 id, address lister);
    event Bought(address token, uint256 id, address buyer, uint256 price);

    /**
     * 
     * @param listing struct containing information
     */
    function list(Listing memory listing) external {

        // transfer 
        IERC721(listing.token).safeTransferFrom(msg.sender, address(this), listing.id);

        require(listing.price > 0, "Cannot list without price");

        // add listing to storage
        listings[index] = listing;
        listings[index].recipient = msg.sender;
        available.push(index);
        ++index;

        emit Listed(listing.token, listing.id, msg.sender);
    }

    /**
     * 
     * @param _index listing index of available to purchase
     */
    function buy(uint256 _index) external payable {
        Listing memory l = listings[available[_index]];
        address token = l.token;
        require(token != address(0), "Invalid index");

        uint256 price = l.price;

        // check and allocate funds
        require(msg.value >= price, "Not enough value sent to purchase");
        funds[l.recipient] += price;

        // remove listing, shift available ids
        delete listings[available[_index]];
        available[_index] = available[available.length-1];
        available.pop();

        // transfer token
        IERC721(token).safeTransferFrom(address(this), msg.sender, l.id);

        emit Bought(token, l.id, msg.sender, price);
    }

    /**
     * 
     * @param recipient address to reciever funds of caller
     */
    function withdraw(address recipient) external {
        uint256 amount = funds[msg.sender];
        funds[msg.sender] = 0;
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){

    }

}