pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/ILoot.sol";
import "./Base64.sol";

contract WeaponStats is ERC721Enumerable, ReentrancyGuard, Ownable {

    ILoot loot = ILoot(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);

    string[] private weapons = [
        "Warhammer",
        "Quarterstaff",
        "Maul",
        "Mace",
        "Club",
        "Katana",
        "Falchion",
        "Scimitar",
        "Long Sword",
        "Short Sword",
        "Ghost Wand",
        "Grave Wand",
        "Bone Wand",
        "Wand",
        "Grimoire",
        "Chronicle",
        "Tome",
        "Book"
    ];

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function getAttack(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Attack", weapons);
    }
    
    function getDefense(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Defense", weapons);
    }
    
    function getWeight(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Weight", weapons);
    }
    
    function getDurability(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Durability", weapons);
    }

    function getMagic(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Magic", weapons);
    }

    function getScore(uint256 base, uint256 tokenId, string memory output) public pure returns (uint256){
        uint256 rando = uint(keccak256(abi.encodePacked(output, toString(tokenId)))) % 100;
        uint256 score;
        if (rando <= 10) {
            score += 1;
        } else if (rando > 10 && rando <= 25 ) {
            score += 5;
        } else if (rando > 25 && rando <= 75 ) {
            score += 10;
        } else if (rando > 75 && rando <= 90 ) {
            score += 15;
        } else if (rando > 90 && rando <= 100 ) {
            score += 25;
        }
        score += base;
        return score;
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal pure returns (string memory) {
        // get the actual weapon class and greatness
        uint256 rand = random(string(abi.encodePacked("WEAPON", toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        uint256 stat;
        if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Warhammer")))) {
            stat = getScore(10, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Quarterstaff")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Maul")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Mace")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Club")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Katana")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Falchion")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Scimitar")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Long Sword")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Short Sword")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Ghost Wand")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Grave Wand")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Bone Wand")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Wand")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Grimoire")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Chronicle")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Tome")))) {
            stat = getScore(80, tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Book")))) {
            stat = getScore(80, tokenId, keyPrefix);
        }
        if (greatness > 14){
            stat += 10;
        }
        if (greatness >= 19){
            stat += 20;
        }
        output = string(abi.encodePacked(keyPrefix, ": ", toString(stat)));

        return output;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[13] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = loot.getWeapon(tokenId);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = getAttack(tokenId);

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = getDefense(tokenId);

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = getWeight(tokenId);

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = getDurability(tokenId);

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = getMagic(tokenId);

        parts[12] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Sheet #', toString(tokenId), '", "description": "Ability Scores are randomized table top RPG style stats generated and stored on chain. Feel free to use Ability Scores in any way you want.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }
    
    function claimForLoot(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 8001, "Token ID invalid");
        require(loot.ownerOf(tokenId) == msg.sender, "Not Loot owner");
        _safeMint(_msgSender(), tokenId);
    }


    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    constructor() ERC721("Weapons stats", "WSTATS") Ownable() {}
}

