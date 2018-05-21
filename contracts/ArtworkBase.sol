pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

//edition_count: i64,
//extension: Option<&'static str>,
//title: Option<String>,
//description: Option<String>,
//price: i64,

contract ArtworkBase is Ownable {

    struct Artwork {
        //uint id; //store ID from database?
        string title;
        string description;
        string url;
        //string protocol; //support distinguishing between https, ipfs, bzz, etc in the future
        uint32 editionCount;
        uint64 price; //always in lowest denomination if fiat, i.e. cents for USD. Always wei for ether
        //bytes4 denomination;
        address artist;
        address owner;
    }

    Artwork[] public artworks;
    uint public artworkCount;

    constructor() public {
        owner = msg.sender; // this isn't neccesary as it's set automatically when Ownable constructor is called
    }

    function createArtwork(string _title, string _description, string _url, uint32 _editionCount, uint64 _price, address _artist) public onlyOwner { //public for now
        Artwork memory artwork = Artwork(
            _title,
            _description,
            _url,
            _editionCount,
            _price,
            _artist,
            _artist
        );
        artworkCount = artworks.push(artwork);
    }

    function getArtworkCount() public view returns (uint) {
        return artworks.length;
    }
}
