// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MomentoX is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MomentoX", "MOX") {}

// ****************** non ERC721 **********************************************************//
    mapping(address => uint256[]) private mappingOwnerNFTs;   // Owner to NFTs tokenId owned
    mapping(uint256 => uint256) private mappingNftInfusedEth; // NFT to amount ETH infused
    event EthInfused(address _who, uint256 _nftId, uint _amount);
    event EthClaimed(address _who, uint256 _nftId, uint _amount);
    event NftTransfered(address _from, address _to, uint256 _nftId);

    function _removeNftFromOwner(address owner, uint256 nftId) private {
        for (uint256 i = 0; i < mappingOwnerNFTs[owner].length; i++) {
            if (mappingOwnerNFTs[owner][i] == nftId) {
                for (uint j = i; j < mappingOwnerNFTs[owner].length - 1; j++) {
                    mappingOwnerNFTs[owner][j] = mappingOwnerNFTs[owner][j + 1];
                }
                mappingOwnerNFTs[owner].pop();
                break;
            }
        }
    }
    
    function safeMintInfused(address to, string memory uri, uint256 ethWei) public payable {
        require(msg.value == ethWei, "ETH sent is not equal to desired infused ETH");
        uint256 tokenId = _tokenIdCounter.current();
        safeMint(to, uri);
        mappingOwnerNFTs[to].push(tokenId);
        mappingNftInfusedEth[tokenId] = ethWei;

        emit EthInfused(to, tokenId, ethWei);
    }

    function getOwnerNFT(address owner) public view returns (uint256[] memory) {
        return mappingOwnerNFTs[owner];
    }

    function getNftInfusedEth(uint256 nftId) public view returns (uint256) {
        return mappingNftInfusedEth[nftId];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function claimEth(uint256 nftId) public {
        require(msg.sender == ownerOf(nftId), "Only owner of NFT can claim Eth");
        uint256 ethNFT = mappingNftInfusedEth[nftId];

        mappingNftInfusedEth[nftId] = 0;
        payable(msg.sender).transfer(ethNFT);

        emit EthClaimed(msg.sender, nftId, ethNFT);
    }

    function safeTransferInfusedNft(address to, uint256 nftId) public {
        
        safeTransferFrom(msg.sender, to, nftId);
        // update previous owner NFTs
        _removeNftFromOwner(msg.sender, nftId);
        // update new owner NFTs
        mappingOwnerNFTs[to].push(nftId);

        emit NftTransfered(msg.sender, to, nftId);
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // ****************** End of non ERC721 **********************************************************//


    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}