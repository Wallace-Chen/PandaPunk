// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./access/Ownable.sol";
import "./utils/EnumerableSet.sol";
import "./utils/math/SafeMath.sol";

contract PandaPunk is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    uint public constant MAX_PANDAS = 10;
    bool public hasSaleStarted = false;

    uint256 private rand_seed;
    EnumerableSet.UintSet private token_rep;
    
    // Truth.　
    string public constant R = "Punk and Panda.";

    constructor() ERC721("PandaPunk","PANDAPUNK")  {
        setBaseURI("");
        rand_seed = 0;
        //populate the token id repository
        for (uint256 i=1; i<=MAX_PANDAS; i=i.add(1)){
            token_rep.add(i);
        }
    }
    
    function tokensOfOwner(address _owner) external view returns(uint256[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index=index.add(1)) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }
    
    function calculatePrice() public view returns (uint256) {
        require(hasSaleStarted == true, "Sale hasn't started");
        require(totalSupply() < MAX_PANDAS, "Sale has already ended");

        uint currentSupply = totalSupply();
        if (currentSupply >= 9900) {
            // return 1000000000000000000;        // 9900-10000: 1.00 ETH
            return 20000000000000000;          // 0 - 500     0.02 ETH
        } else if (currentSupply >= 9500) {
            // return 640000000000000000;         // 9500-9500:  0.64 ETH
            return 20000000000000000;          // 0 - 500     0.02 ETH
        } else if (currentSupply >= 7500) {
            // return 320000000000000000;         // 7500-9500:  0.32 ETH
            return 20000000000000000;          // 0 - 500     0.02 ETH
        } else if (currentSupply >= 3500) {
            // return 160000000000000000;         // 3500-7500:  0.16 ETH
            return 20000000000000000;          // 0 - 500     0.02 ETH
        } else if (currentSupply >= 1500) {
            // return 80000000000000000;          // 1500-3500:  0.08 ETH 
            return 20000000000000000;          // 0 - 500     0.02 ETH
        } else if (currentSupply >= 500) {
            // return 40000000000000000;          // 500-1500:   0.04 ETH 
            return 20000000000000000;          // 0 - 500     0.02 ETH
        } else {
            return 20000000000000000;          // 0 - 500     0.02 ETH
        }
    }

   function adoptPandaPunk(uint256 numPandas) public payable {
        require(totalSupply() < MAX_PANDAS, "Sale has already ended");
        require(numPandas > 0 && numPandas <= 20, "You can adopt minimum 1, maximum 20 chubbies");
        require(totalSupply().add(numPandas) <= MAX_PANDAS, "Exceeds MAX_PANDAS");
        require(msg.value >= calculatePrice().mul(numPandas), "Ether value sent is below the price");

        for (uint i = 0; i < numPandas; i=i.add(1)) {
            uint256 tokenId = _getTokenId(msg.sender);
            _safeMint(msg.sender, tokenId);
        }
    }

    function _getTokenId(address from) private returns (uint256){
        uint256 numLeft = token_rep.length();
        require(numLeft>0, "Error: no token left!");
        uint256 index = _random(from) % numLeft;
        uint256 tokenId = token_rep.at(index);
        token_rep.remove(tokenId);
        return tokenId;
    }


    function _random(address from) private returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), from, rand_seed)));
        rand_seed = randomNumber;
        return randomNumber;
   }
    
    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }
    
    function startSale() public onlyOwner {
        hasSaleStarted = true;
    }
    function pauseSale() public onlyOwner {
        hasSaleStarted = false;
    }
    
    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function reserveGiveaway(uint256 numPandas) public onlyOwner {
        uint256 currentSupply = totalSupply();
        require(currentSupply.add(numPandas) <= 5, "Exceeded giveaway supply");
        require(currentSupply.add(numPandas) <= MAX_PANDAS, "Exceeds MAX_PANDAS");
        require(hasSaleStarted == false, "Sale has already started");
        // Reserved for people who helped this project and giveaways
        for (uint256  index = 0; index < numPandas; index=index.add(1)) {
            uint256 tokenId = _getTokenId(owner());
            _safeMint(owner(), tokenId);
        }
    }
}
