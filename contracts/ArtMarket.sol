// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "contracts/ArtGallery.sol";

contract ArtMarket {
    ArtGallery public artGallery;

    struct Listing {
        uint256 artId;
        address seller;
        address originalArtist;
        uint256 price;
        bool isActive;
    }
    
    struct Purchase {
        uint256 artId;
        address seller;
        address buyer;
        uint256 price;
    }

    uint256 public listingCount;
    uint256 public purchaseCount;
    uint256 public royaltyPercent = 10;

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Purchase) public purchases;
    mapping(address => uint256) public earnings;

    event ArtListed(uint256 listingId, uint256 artId, address seller, uint256 price);
    event ArtPurchased(uint256 artId, address buyer, address seller, uint256 price, uint256 royalty);
    event ListingCancelled(uint256 listingId);
    event RoyaltyPaid(uint256 artId, address artist, uint256 amount);

    constructor(address _artGalleryAddr) {
        artGallery = ArtGallery(_artGalleryAddr);
    } 

    // function listArt(uint256 _artId, address _originalArtist, uint256 _price) public returns (uint256) {
    function listArt(uint256 _artId, uint256 _price) public returns (uint256) {
        require(_price > 0, "Price must be > 0");
        require(artGallery.isOwner(_artId, msg.sender), "You don't own this art piece");

        (,,,, address originalArtist) = artGallery.artWorks(_artId);
        
        listingCount++;
        listings[listingCount] = Listing({
            artId: _artId,
            seller: msg.sender,
            originalArtist: originalArtist,
            price: _price,
            isActive: true
        });

        emit ArtListed(listingCount, _artId, msg.sender, _price);
        return listingCount;
    }

    function buyArt(uint256 _listingId) public payable {
        Listing storage listing = listings[_listingId];
        require(listing.isActive, "Listing is not active");
        require(msg.sender != listing.seller);
        require(msg.value >= listing.price, "Insufficient funds");

        uint256 royaltyAmount = 0;
        uint256 sellerAmount = listing.price;

         if (listing.originalArtist != listing.seller) {
            royaltyAmount = (listing.price * royaltyPercent) / 100;
            sellerAmount = listing.price - royaltyAmount;
            earnings[listing.originalArtist] += royaltyAmount;
            emit RoyaltyPaid(listing.artId, listing.originalArtist, royaltyAmount);
        }

        earnings[listing.seller] += sellerAmount;

        purchaseCount++;
        purchases[purchaseCount] = Purchase({
            artId: listing.artId,
            buyer: msg.sender,
            seller: listing.seller,
            price: listing.price
        });

        emit ArtPurchased(listing.artId, msg.sender, listing.seller, listing.price, royaltyAmount);

        listing.isActive = false;
        artGallery.transferOwnership(listing.artId, msg.sender);

        // refund excess payment
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }
    }

    function cancelListing(uint256 _listingId) public {
        require(listings[_listingId].seller == msg.sender, "Not your listing");
        require(listings[_listingId].isActive, "Already active");
        listings[_listingId].isActive = false;
        emit ListingCancelled(_listingId);
    }

    function withdrawEarnings() public {
        uint256 amount = earnings[msg.sender];
        require(amount > 0, "No earnings");
        earnings[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getListingDetails(uint256 _listingId) public view returns (
        uint256 artId,
        address seller,
        address originalArtist,
        uint256 price,
        bool isActive
    ) {
        Listing memory listing = listings[_listingId];
        return (
            listing.artId,
            listing.seller,
            listing.originalArtist,
            listing.price,
            listing.isActive
        );
    }
}