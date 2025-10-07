// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract ArtGallery {
    struct ArtWork {
        uint256 id;
        string title;
        string artist;
        address currOwner;
        address originalArtist;
    }

    uint256 public artCount;
    mapping(uint256 => ArtWork) public artWorks;
    mapping(address => uint256[]) public artistWorks;

    mapping(address => bool) public approvedMarketplaces;
    address public admin;

    event ArtMinted(uint256 artId, string title, address artist);
    event OwnershipTransferred(uint256 artId, address from, address to);
    event MarketplaceApproved(address marketplace);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyOwnerOrMarket(uint256 _artId) {
        require(msg.sender == artWorks[_artId].currOwner || approvedMarketplaces[msg.sender], 
        "Not authorized to perform this action");
        _;
    }

    function mintArt(string memory _title, string memory _artist) public returns (uint256) {
        artCount++;
        uint256 newArtId = artCount;

        artWorks[newArtId] = ArtWork({
            id: newArtId,
            title: _title,
            artist: _artist,
            currOwner: msg.sender,
            originalArtist: msg.sender
        });

        artistWorks[msg.sender].push(newArtId);

        emit ArtMinted(newArtId, _title, msg.sender);
        return newArtId;
    }

    function getArtDetails(uint256 _artId) public view returns (
        string memory title,
        string memory artist,
        address currOwner,
        address originalArtist
    ) {
        ArtWork memory art = artWorks[_artId];
        return (
            art.title,
            art.artist,
            art.currOwner,
            art.originalArtist
        );
    }

    function transferOwnership(uint256 _artId, address _newOwner) external onlyOwnerOrMarket(_artId) {
        ArtWork storage art = artWorks[_artId];
        address prevOwner = art.currOwner;
        art.currOwner = _newOwner;

        emit OwnershipTransferred(_artId, prevOwner, _newOwner);
    }

    function approveMarketplace(address _marketplace) external onlyAdmin {
        approvedMarketplaces[_marketplace] = true;
        emit MarketplaceApproved(_marketplace);
    }


    function getArtCount() public view returns (uint256) {
        return artCount;
    }

    function getArtistWorks(address _artist) public view returns (uint256[] memory) {
        return artistWorks[_artist];
    }

    function isOwner(uint256 _artId, address _account) public view returns (bool) {
        return artWorks[_artId].currOwner == _account;
    }
}