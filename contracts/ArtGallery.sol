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

    event ArtMinted(uint256 artId, string title, address artist);

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

    function transferOwnership(uint256 _artId, address _newOwner) external {
        ArtWork storage art = artWorks[_artId];
        art.currOwner = _newOwner;
    }

    function getArtCount() public view returns (uint256) {
        return artCount;
    }

    function getArtistWorks(address _artist) public view returns (uint256[] memory) {
        return artistWorks[_artist];
    }
}