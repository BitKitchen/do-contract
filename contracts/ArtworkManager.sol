pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ArtworkToken.sol";
import "./Logger.sol";

contract ArtworkTokenInterface is ArtworkToken {
}


contract ArtworkManager is Ownable, Logger {

    address artworkToken;
    ArtworkTokenInterface artworkTokenContract;

    constructor(address _address) public {
        artworkTokenContract = ArtworkTokenInterface(_address);
    }

    function createArtworkToken(
        uint256 _tokenId,
        string _title,
        string _artistName,
        string _tokenURI,
        uint32 _editionNumber,
        uint32 _editionCount,
        uint64 _price,
        address _artist,
        address _buyer
    ) public onlyOwner {
        artworkTokenContract.mint(
            _tokenId,
            _title,
            _artistName,
            _tokenURI,
            _editionNumber,
            _editionCount,
            _price,
            _artist,
            _buyer
        );
    }

    function getSupply() public view returns (uint256) {
        return artworkTokenContract.totalSupply();
    }

    function transferToken(
        uint256 _tokenId,
        uint64 _price,
        address _seller,
        address _buyer
    ) public onlyOwner {
        artworkTokenContract.transferFrom(_seller, _buyer, _tokenId, _price);
    }
}
