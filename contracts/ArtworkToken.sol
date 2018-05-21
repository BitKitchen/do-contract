pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./Logger.sol";


interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
}


contract ArtworkToken is ERC721Token, ERC165, Ownable, Logger {
    using SafeMath for uint256;

    /* solhint-disable */
    bytes4 constant InterfaceSignature_ERC165 = 0x01ffc9a7;
    /*
    bytes4(keccak256('supportsInterface(bytes4)'));
    */

    bytes4 constant InterfaceSignature_ERC721Enumerable = 0x780e9d63;
    /*
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
    bytes4(keccak256('tokenByIndex(uint256)'));
    */

    bytes4 constant InterfaceSignature_ERC721Metadata = 0x5b5e139f;
    /*
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('tokenURI(uint256)'));
    */

    bytes4 constant InterfaceSignature_ERC721 = 0x80ac58cd;
    /*
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('getApproved(uint256)')) ^
    bytes4(keccak256('setApprovalForAll(address,bool)')) ^
    bytes4(keccak256('isApprovedForAll(address,address)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
    bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'));
    */

    bytes4 public constant InterfaceSignature_ERC721Optional =- 0x4f558e79;
    /*
    bytes4(keccak256('exists(uint256)'));
    */

    /**
     * @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
     * @dev Returns true for any standardized interfaces implemented by this contract.
     * @param _interfaceID bytes4 the interface to check for
     * @return true for any standardized interfaces implemented by this contract.
     */
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return ((_interfaceID == InterfaceSignature_ERC165)
            || (_interfaceID == InterfaceSignature_ERC721)
            || (_interfaceID == InterfaceSignature_ERC721Optional)
            || (_interfaceID == InterfaceSignature_ERC721Enumerable)
            || (_interfaceID == InterfaceSignature_ERC721Metadata));
    }
    /* solhint-enable */
    event Sale(address indexed _from, address indexed _to, uint256 _tokenId, uint64 _price, bytes8 _currency);

    struct Edition {
        string title;
        string artistName;
        uint32 editionNumber;
        uint32 editionCount;
    }

    mapping(uint256 => Edition) internal tokenIdToEdition;
    address managerContract;
    bool internal _initialized;

    modifier onlyManagers() {
        require(msg.sender == owner || msg.sender == managerContract);
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        if (msg.sender == managerContract) {
            _;
        } else { //this is parent modifier, super didn't seem to work
            require(isApprovedOrOwner(msg.sender, _tokenId));
            _;
        }
    }

    // Initialize constructor with token name and symbol
    constructor() public ERC721Token("Digital Objects Artwork", "DOBJ") {
    }

    function initialize(address _owner) public {
        require(!_initialized);

        owner = _owner;     //Ownable constructor
        name_ = "Digital Objects Artwork";      //ERC721Token constructor
        symbol_ = "DOBJ";  //ERC721Token constructor
        _initialized = true;

    }

    function setManager(address _manager) public onlyOwner {
        require(_manager != address(0));
        //OwnershipTransferred(owner, newOwner);
        managerContract = _manager;
    }

    function editionInfo(uint256 _tokenId) public view returns (
        string _title,
        string _artistName,
        uint32 _edition,
        uint32 _editionNumber,
        string _tokenURI
    ) {
        require(exists(_tokenId));
        Edition memory edition = tokenIdToEdition[_tokenId];
        string memory URI = tokenURI(_tokenId);
        return (
            edition.title,
            edition.artistName,
            edition.editionNumber,
            edition.editionCount,
            URI
        );
    }

    function mint(
        uint256 _tokenId,
        string _title,
        string _artistName,
        string _tokenURI,
        uint32 _editionNumber,
        uint32 _editionCount,
        uint64 _price,
        address _artist,
        address _buyer
    ) external onlyManagers {
        require(_artist != address(0));
        require(_buyer != address(0));
        //require(exists(_tokenId));
        require(bytes(_tokenURI).length > 0);
        require(_price > 0);
        super._mint(_buyer, _tokenId);
        super._setTokenURI(_tokenId, _tokenURI);
        _populateTokenData(_tokenId, _title, _artistName, _editionNumber, _editionCount);
        emit Sale(_artist, _buyer, _tokenId, _price, bytes8("USD"));
    }

    function transferFrom(address _seller, address _buyer, uint256 _tokenId, uint64 _price) public canTransfer(_tokenId) {
        super.transferFrom(_seller, _buyer, _tokenId);
        emit Sale(_seller, _buyer, _tokenId, _price, bytes8("USD"));
    }

    function burn(uint256 _tokenId) public onlyManagers {
        require(exists(_tokenId));
        super._burn(ownerOf(_tokenId), _tokenId);

        _removeTokenData(_tokenId);
    }

    function setTokenURI(uint256 _tokenId, string _uri) external onlyManagers {
        require(exists(_tokenId));
        _setTokenURI(_tokenId, _uri);
    }

    function _populateTokenData(uint256 _tokenId, string _artistName, string _title, uint32 _editionNumber, uint32 _editionCount) internal {
        Edition memory edition = Edition(_artistName, _title, _editionNumber, _editionCount);
        tokenIdToEdition[_tokenId] = edition;
    }

    function _removeTokenData(uint _tokenId) internal {
        delete tokenIdToEdition[_tokenId];
    }
}
