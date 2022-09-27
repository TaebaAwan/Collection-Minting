// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MintingNFT is ERC721, ERC721URIStorage {
    using SafeMath for uint;

address public owner; 
mapping(address => uint) _balances;

constructor() ERC721("MintingNFT", "IECT") 
    {
        owner = msg.sender;
        totalMintingLimit= 50;
        _balances[owner]= totalMintingLimit;
    }
    bool _pause;

    event Minted(address indexed _to, uint256 indexed _tokenId);

/**
     * @dev pauseContract is used to pause all the functions of the contract.
     * @dev unpauseContract is used to unpause all the functions of the contract.
     * Requirement:
     * - This function can only called by the owner of the contract.
*/
  function pauseContract() public onlyOwner{ 
      _pause = true;
    }

    function unpauseContract() public onlyOwner {
      _pause = false;
    }
    
modifier paused(){   //No one can mint the NFT if the owner has paused the minting
    require(owner == msg.sender, "You are not the owner of this contract"); 
    require(_pause == false, "The minting is paused by the owner"); 
 _; }

struct whitelistUSERS{
        string name;
        uint nftminted;
        bool exists;
    }

struct platformAdmin{
        string name;
        uint nftminted;
        bool exists;
    }

struct publicUSERS{
        string name;
        uint nftminted;
        bool exists;
    }

    mapping (address => whitelistUSERS) whitelistUsers; // whitelist admins
    mapping (address => platformAdmin) platformMiners;  // platform admins
    mapping (address => publicUSERS) publicUsers;

struct nftInfo{
    uint nftID;
    string nftName;
    string metadataHash ;
    }

mapping (uint => nftInfo ) public nftData;

    uint public totalMintingLimit;
    uint public whitelisMintingLimit= 20 ;
    uint public platformLimit = 10;
    uint public publicMintingLimit = 20  ;
    uint public maxMintingLimit = 5 ;

modifier onlyWhitelistedUsers(address userID) {
       require(whitelistUsers[userID].exists == true , "Sorry, You are not a whitelist user!");
        _; }

string baseURI; 

 /**
     * @dev _baseURI is used to set the baseURI of NFT.
     * @dev updateBaseURI is used to update the baseURI of NFT.
     * Requirement:
     * - This function can only called by the registered whitelist admins.
     * - This function cannot be called if the contract is paused.
     * @param baseuri - baseuri
*/
function _baseURI(string memory baseuri) public virtual paused onlyWhitelistedUsers(msg.sender) 
returns (string memory) {
      baseURI = baseuri;
        return baseURI;
    } 

function updateBaseURI(string memory baseuri) public virtual onlyWhitelistedUsers(msg.sender) paused {
        baseURI = baseuri;
    }
/**
     * @dev addWhitelistAdmins is used to register a whitelist admin.
     * @dev removeWhitelistAdmins is used to remove a registered whitelist admin.
     * Requirement:
     * - This function can only called by the owner of the contract.
     * - This function cannot be called if the contract is paused.
*/
uint public totalWhitelistUsers=0;

    function addWhitelistAdmins(address _whitelistUser, string memory _name, uint _nftsminted, bool _exists) 
    public paused onlyOwner {
        require(whitelistUsers[_whitelistUser].exists != true , "You are already registered");
        whitelistUsers[_whitelistUser]= whitelistUSERS(_name, _nftsminted,_exists) ;
        totalWhitelistUsers++;
}

    function removeWhitelistAdmins(address _whitelistUser) public paused onlyOwner {
       require(whitelistUsers[_whitelistUser].exists == true , "You are not registered");
        delete whitelistUsers[_whitelistUser];
        totalWhitelistUsers--;
}
uint public totalPlatformMiners = 0;
/**
     * @dev addPlatformMiners is used to register a Platform Miner.
     * Requirement:
     * - This function cannot be called if the contract is paused.
*/

    function addPlatformMiners(address _platformMiner, string memory _name, uint _nftsminted, bool _exists) 
    public paused  {
        require(platformMiners[_platformMiner].exists != true , "You are already registered");
        platformMiners[_platformMiner]= platformAdmin( _name, _nftsminted, _exists);
        totalPlatformMiners++;
}
bool publicSale;

/**
     * @dev activatePublicSale is used to activate the public sale of NFTs.
     * - This function can only called by the owner of the contract.
     * - As soon as the public sale will be activated all the remaining Whitelist Admins minting limit 
     will be transferred to public minting limit.
*/
function activatePublicSale() public onlyOwner {
        publicSale = true;    
        if(totalNFTsMintedByWhitelistMiners < whitelisMintingLimit) {
        uint unusedTokens = whitelisMintingLimit - totalNFTsMintedByWhitelistMiners;
        publicMintingLimit += unusedTokens;
     }
}

modifier publicSaleActive(){   
    require(publicSale == true, "The public sale has ended! You can not mint the NFT"); 
 _; }

modifier publicSaleNOTActive(){   
    require(publicSale == false, "The public sale has started! You can not mint the NFT"); 
 _; }

uint totalNFTsMintedByWhitelistMiners =0;
 /**
     * @dev whitelistMinting is used to let whitelist miners mint NFTs.
     * Requirement:
     * - This function can only called if the public sale is not active.
     * - This function cannot be called if the contract is paused.
     * @param to - to, tokenId -tokenId, _name - _name, hash- hash
*/
function whitelistMinting(address to, uint tokenId, string memory _name, string memory hash)
 public paused publicSaleNOTActive {
        require(to != address(0), "Token can not be minted to a zero address");
        require(whitelistUsers[to].exists == true , "You are not registered");
        require(totalNFTsMintedByWhitelistMiners < whitelisMintingLimit, "Max Whitelist minitinng limit has exceeded"); 
        require(whitelistUsers[to].nftminted < maxMintingLimit, "You have exceeded the minting limit"); 
        _balances[to] = whitelistUsers[to].nftminted++;
        _safeMint(to, tokenId);
         
         emit Minted (to, tokenId);

        nftData[tokenId] = nftInfo( tokenId, _name, hash);
        totalNFTsMintedByWhitelistMiners++;
}

uint totalNFTsMintedByPlatformMiners =0;
 /**
     * @dev platformMinting is used to let platform miners mint NFTs.
     * Requirement:
     * - This function cannot be called if the contract is paused.
     * @param to - to, tokenId -tokenId, _name - _name, hash- hash
*/
function platformMinting( address to, uint tokenId, string memory _name, string memory hash)
 public paused onlyOwner {
        require(to != address(0), "Token can not be minted to a zero address");
        require(platformMiners[to].exists == true , "You are not registered");
        require(totalNFTsMintedByPlatformMiners < platformLimit, "Max Public minitinng limit has exceeded"); 
        require(platformMiners[to].nftminted < maxMintingLimit, "You have exceeded the minting limit"); 
        _balances[to] = platformMiners[to].nftminted++;
        _safeMint(to, tokenId);
            emit Minted (to, tokenId);
        nftData[tokenId] = nftInfo(tokenId, _name, hash);
        totalNFTsMintedByPlatformMiners++;
}

    uint totalNFTsMintedByPublicMiners =0;
    uint public totalPublicUsers = 0;
 /**
     * @dev publicMinting is used to let public miners & whitelist miner mint NFTs.
     * Requirement:
     * - This function can only called if the public sale is active.
     * - This function cannot be called if the contract is paused.
     * @param to - to, tokenId -tokenId, tokenName- tokenName, _name - _name, _exists- _exists, 
     hash- hash, _nftsminted - _nftsminted
*/
function publicMinting(address to, string memory _name, uint _nftsminted, bool _exists,
    uint tokenId, string memory tokenName, string memory hash) 
    public paused publicSaleActive {
      
    require(to != address(0), "Token can not be minted to a zero address");

    if (publicUsers[to].exists || whitelistUsers[to].exists){
        require(whitelistUsers[to].nftminted < maxMintingLimit, "You have exceeded the minting limit");
        require(publicUsers[to].nftminted < maxMintingLimit, "You have exceeded the minting limit");

        require(totalNFTsMintedByPublicMiners < publicMintingLimit, "Max Public minitinng limit has exceeded");
     
        _safeMint(to, tokenId);
        emit Minted (to, tokenId);

        _balances[to] = whitelistUsers[to].nftminted++;
        _balances[to] = publicUsers[to].nftminted++;

        nftData[tokenId] = nftInfo( tokenId, tokenName, hash);
        totalNFTsMintedByPublicMiners++; 
} else{
    publicUsers[to]= publicUSERS( _name, _nftsminted, _exists);
    totalPublicUsers++;
    
    require(totalNFTsMintedByPublicMiners < publicMintingLimit, "Max Public minitinng limit has exceeded");

    _safeMint(to, tokenId);
    emit Minted (to, tokenId);

    _balances[to] = whitelistUsers[to].nftminted++;
    _balances[to] = publicUsers[to].nftminted++;

    nftData[tokenId] = nftInfo( tokenId, tokenName, hash);
    totalNFTsMintedByPublicMiners++; 

}
    }

  function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked((baseURI), nftData[tokenId].metadataHash));
    }

    // The following functions are overrides required by Solidity.

function balanceOf(address _owner) public view virtual override returns (uint256) {
        require(_owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[_owner];
    } 

modifier onlyOwner(){   
    require(owner == msg.sender, "You are not the owner of this contract"); 
 _; }
    function supportsInterface() internal view virtual  {
    
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _requireMinted(uint256 tokenId) internal override view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
}

// https://ipfs.io/ipfs/
// https://testnets.opensea.io/collection/nft-art-exhibition
