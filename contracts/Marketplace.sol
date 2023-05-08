pragma solidity ^0.8.0;

import "@openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin-contracts/token/ERC721/IERC721.sol";

contract Marketplace is IERC721Receiver {

    uint256 public index;
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public funds;
    uint256[] public available;

    struct Listing{
        address recipient,  // receiver of fees on sale
        address token,      // address of token contract
        uint256 id,         // id of token
        uint256 price,      // starting price for sale or highest bid
        ListingType type    // type of sale to be done
    }

    enum ListingType {Fixed};

    event Listed(address token, uint256 id, address lister);
    event Bought(address token, uint256 id, address buyer, uint256 price);

    /**
     * 
     * @param listing struct containing information
     */
    function list(Listing listing) external {

        // transfer 
        IERC721(listing.token).safeTransferFrom(msg.sender, address(this), listing.id);

        if(listing.type == ListingType.Fixed) {
            require(listing.price > 0, "Cannot list without price");
        } else {
            throw InvalidListing();
        }

        // add listing to storage
        listings[index] = listing;
        listings[index].recipient = msg.sender;
        available.push(index);
        ++index;

        emit Listed(token, id, msg.sender);
    }

    /**
     * 
     * @param _index listing index to purchase
     */
    function buy(uint256 _index) external payable {
        Listing memory l = listings[_index];
        address token = l.token;
        require(token != address(0), "Invalid index");

        uint256 price;
        if(l.type == ListingType.Fixed){
            // check sender has sent enough to purchase
            uint256 price = l.price;
            require(msg.value >= price, "");
            funds[l.recipient] += price;

            // transfer token
            IERC721(token).safeTransfer(msg.sender, l.id);
        }


        emit Bought(token, id, msg.sender, price);
    }

    /**
     * 
     * @param recipient address to reciever funds of caller
     */
    function withdraw(address recipient){
        uint256 amount = funds[msg.sender];
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
    ) external returns (bytes4);

}