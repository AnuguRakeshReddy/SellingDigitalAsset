pragma solidity 0.8.6;

import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/tokens/nf-token-enumerable.sol";
import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/ownership/ownable.sol";
import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/utils/erc165.sol";

interface IERC2981Royalties {
    function royaltyArt(
      uint256 tokenId, 
      uint256 value)
        external
        view
        returns (address _artist, uint256 _royaltyAmount);
}

abstract contract ERC2981PerTokenRoyalties is ERC165, IERC2981Royalties {


    struct Artistfee {
        address artist;
        uint256 value;
    }

    mapping(uint256 => Artistfee) internal Artistfees; 

    function _setTokenRoyalty(
    uint256 id, 
    address artist,
    uint256 amount) 
    internal 
    {
        require(amount < 10001, 'ERC2981Royalties is high');

        Artistfees[id] = Artistfee(artist, amount);
    }


    function royaltyArt(
      uint256 tokenId, 
      uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount){
          Artistfee memory royalty = Artistfees[tokenId];
          return (royalty.artist, (value * royalty.value) / 10000);
    }
}


contract NFTtoken is NFTokenEnumerable, NFTokenMetadata, Ownable, ERC2981PerTokenRoyalties{

    constructor(string memory _nftname,string memory _nftSymbol){
      nftName = _nftname;
      nftSymbol = _nftSymbol;
    }

  function mint( address owner, uint256 tokenId, string calldata _uri, address realowner, uint256 shareowner) external onlyOwner
  {
    super._mint(owner, tokenId);
    super._setTokenUri(tokenId, _uri);
    
    if (shareowner > 0) {
        _setTokenRoyalty(tokenId, realowner, shareowner);
    }
    
  }


  function remove( uint256 tokenId) external onlyOwner{
    super._burn(tokenId);
  }

  function tokenUri(uint256 _tokenId, string calldata _uri) external onlyOwner{
    super._setTokenUri(_tokenId, _uri);
  }

  function _mint(address to, uint256 _tokenId) internal
    override(NFToken, NFTokenEnumerable)
    virtual
  {
    NFTokenEnumerable._mint(to, _tokenId);
  }


  function _burn( 
    uint256 tokenId)
    internal
    override(NFTokenMetadata, NFTokenEnumerable)
    virtual
  {
    NFTokenEnumerable._burn(tokenId);
    if (bytes(idToUri[tokenId]).length > 0)
    {
      delete idToUri[tokenId];
    }
  }

  function _removeNFToken(address _from, uint256 _tokenId )
    internal
    override(NFToken, NFTokenEnumerable)
  {
    NFTokenEnumerable._removeNFToken(_from, _tokenId);
  }


  function _addNFToken(address to, uint256 _tokenId)
    internal
    override(NFToken, NFTokenEnumerable)
  {
    NFTokenEnumerable._addNFToken(to, _tokenId);
  }


  function _getOwnerNFTCount(address owner)
    internal
    override(NFToken, NFTokenEnumerable)
    view
    returns (uint256)
  {
    return NFTokenEnumerable._getOwnerNFTCount(owner);
  }

}
