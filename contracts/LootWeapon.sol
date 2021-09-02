pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ILoot.sol";
import "./Base64.sol";

/**
 * @title  LootWeapon
 * @author kjr217
 * @notice Looters! Come and collect your arms! War is upon us, we must fight!
 *         The Weaponsmith is open. Looters will be able to mint their weapons and reveal their underlying powers
 *         - attack, defense, durability, weight and magic. Mint your weapon, reveal your stats.
 */
contract LootWeapon is ERC721Enumerable, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    // OG loot contract
    ILoot loot = ILoot(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);
    // Token used as the trade in for the weaponSmith
    IERC20 public token;
    // Mapping containing the weaponSmith's records on upgraded weapons
    mapping(uint256 => uint256) public boosts;
    // Mapping containing the base stats on all weapon classes
    mapping(uint8 => uint16[5]) public bases;
    // coefficient applied to weaponSmith
    uint256 boostCoefficient;
    // weapon smith opening
    bool weaponSmithOpen;

    event TokenUpdated(address oldToken, address newToken);
    event Upgrade(uint256 tokenId, uint256 upgradeAmount);
    event BoostCoefficientUpdated(uint256 oldBoostCoefficient, uint256 newBoostCoefficient);
    event WeaponSmithOpen(bool open);

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
    string[] private namePrefixes = [
        "Agony", "Apocalypse", "Armageddon", "Beast", "Behemoth", "Blight", "Blood", "Bramble",
        "Brimstone", "Brood", "Carrion", "Cataclysm", "Chimeric", "Corpse", "Corruption", "Damnation",
        "Death", "Demon", "Dire", "Dragon", "Dread", "Doom", "Dusk", "Eagle", "Empyrean", "Fate", "Foe",
        "Gale", "Ghoul", "Gloom", "Glyph", "Golem", "Grim", "Hate", "Havoc", "Honour", "Horror", "Hypnotic",
        "Kraken", "Loath", "Maelstrom", "Mind", "Miracle", "Morbid", "Oblivion", "Onslaught", "Pain",
        "Pandemonium", "Phoenix", "Plague", "Rage", "Rapture", "Rune", "Skull", "Sol", "Soul", "Sorrow",
        "Spirit", "Storm", "Tempest", "Torment", "Vengeance", "Victory", "Viper", "Vortex", "Woe", "Wrath",
        "Light's", "Shimmering"
    ];
    string[] private nameSuffixes = [
        "Bane",
        "Root",
        "Bite",
        "Song",
        "Roar",
        "Grasp",
        "Instrument",
        "Glow",
        "Bender",
        "Shadow",
        "Whisper",
        "Shout",
        "Growl",
        "Tear",
        "Peak",
        "Form",
        "Sun",
        "Moon"
    ];
    string[] private suffixes = [
        "of Power",
        "of Giants",
        "of Titans",
        "of Skill",
        "of Perfection",
        "of Brilliance",
        "of Enlightenment",
        "of Protection",
        "of Anger",
        "of Rage",
        "of Fury",
        "of Vitriol",
        "of the Fox",
        "of Detection",
        "of Reflection",
        "of the Twins"
    ];

    /**
     * @notice allow the owners to set the tokens used as pay-in for the weaponSmith
     * @param  _token address of the new token
     */
    function setToken(address _token) external onlyOwner {
        emit TokenUpdated(address(token), _token);
        token = IERC20(_token);
    }

    /**
     * @notice allow the owners to set the coefficient used for the upgrade boost
     * @param  _boostCoefficient coefficient used to modify the upgrade amount
     */
    function setBoostCoefficient(uint256 _boostCoefficient) external onlyOwner {
        emit BoostCoefficientUpdated(boostCoefficient, _boostCoefficient);
        boostCoefficient = _boostCoefficient;
    }

    /**
     * @notice allow the owners to open the weapon smith
     * @param  _weaponSmithOpen bool to open or close the weapon smith
     */
    function setWeaponSmithOpen(bool _weaponSmithOpen) external onlyOwner {
        emit WeaponSmithOpen(_weaponSmithOpen);
        weaponSmithOpen = _weaponSmithOpen;
    }

    /**
     * @notice allow the owners to sweep any erc20 tokens sent to the contract
     * @param  _token address of the token to be swept
     * @param  _amount amount to be swept
     */
    function sweep(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getWeapon(uint256 tokenId) public view returns (string memory) {
        return loot.getWeapon(tokenId);
    }

    function getAttack(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Attack", weapons, 0);
    }
    
    function getDefense(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Defense", weapons, 1);
    }

    function getDurability(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Durability", weapons, 2);
    }

    function getWeight(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Weight", weapons, 3);
    }

    function getMagic(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "Magic", weapons, 4);
    }

    /**
     * @notice score calculator
     * @param  base the base amount taken from bases for the weapon class
     * @param  tokenId id of the token being scored
     * @param  output weapon class or description
     */
    function getScore(uint256 base, uint256 tokenId, string memory output) public pure returns (uint256){
        uint256 rando = uint(keccak256(abi.encodePacked(output, toString(tokenId)))) % 100;
        uint256 score;
        if (rando <= 10) {
            score += 10;
        } else if (rando > 10 && rando <= 25 ) {
            score += 50;
        } else if (rando > 25 && rando <= 75 ) {
            score += 100;
        } else if (rando > 75 && rando <= 90 ) {
            score += 150;
        } else if (rando > 90 && rando <= 100 ) {
            score += 250;
        }
        score += base;
        return score;
    }

    /**
     * @notice the weaponSmith, where you can upgrade your weapons send in the compatible erc20 token to upgrade
     * @param  tokenId id of the token being upgraded
     * @param  amount amount of token to be sent to the weaponSmith to be upgraded
     */
    function weaponSmith(uint256 tokenId, uint256 amount) external {
        require(weaponSmithOpen, "!open");
        require(ownerOf(tokenId) == msg.sender, "!owner");
        token.safeTransferFrom(msg.sender, address(this), amount);
        boosts[tokenId] += amount / boostCoefficient;
        emit Upgrade(tokenId, amount / boostCoefficient);
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray, uint256 baseIndex) internal view returns (string memory) {
        // get the actual weapon class and greatness
        uint256 rand = random(string(abi.encodePacked("WEAPON", toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        uint256 stat;
        if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Warhammer")))) {
            stat = getScore(bases[0][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Quarterstaff")))) {
            stat = getScore(bases[1][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Maul")))) {
            stat = getScore(bases[2][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Mace")))) {
            stat = getScore(bases[3][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Club")))) {
            stat = getScore(bases[4][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Katana")))) {
            stat = getScore(bases[5][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Falchion")))) {
            stat = getScore(bases[6][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Scimitar")))) {
            stat = getScore(bases[7][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Long Sword")))) {
            stat = getScore(bases[8][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Short Sword")))) {
            stat = getScore(bases[9][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Ghost Wand")))) {
            stat = getScore(bases[10][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Grave Wand")))) {
            stat = getScore(bases[11][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Bone Wand")))) {
            stat = getScore(bases[12][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Wand")))) {
            stat = getScore(bases[13][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Grimoire")))) {
            stat = getScore(bases[14][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Chronicle")))) {
            stat = getScore(bases[15][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Tome")))) {
            stat = getScore(bases[16][baseIndex], tokenId, keyPrefix);
        } else if (keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("Book")))) {
            stat = getScore(bases[17][baseIndex], tokenId, keyPrefix);
        }
        if (baseIndex == 3){
            output = string(abi.encodePacked(keyPrefix, ": ", toString(stat)));
            return output;
        }
        if (greatness > 14){
            stat += getScore(0, tokenId, suffixes[rand % suffixes.length]);
        }
        if (greatness >= 19){
            if (greatness == 19){
                stat += getScore(0, tokenId, string(abi.encodePacked(namePrefixes[rand % namePrefixes.length], nameSuffixes[rand % nameSuffixes.length])));
            } else {
                stat += 300;
            }
        }
        stat += boosts[tokenId];
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

        parts[7] = getDurability(tokenId);

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = getWeight(tokenId);

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = getMagic(tokenId);

        parts[12] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Weapon #', toString(tokenId), '", "description": "The Weaponsmith is open. Looters will be able to mint their weapons and reveal their underlying powers - attack, defense, durability, weight and magic. Mint your weapon, reveal your stats.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }
    
    function claimForLoot(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 8001, "Token ID invalid");
        require(loot.ownerOf(tokenId) == msg.sender, "Not Loot owner");
        _safeMint(_msgSender(), tokenId);
    }

    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId > 8000 && tokenId < 9576, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
    }

    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 9575 && tokenId < 10001, "Token ID invalid");
        _safeMint(owner(), tokenId);
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
    
    constructor() ERC721("LOOTWEAPON", "LWEAPON") Ownable() {
        bases[0] = [800,350,850,800,0];
        bases[1] = [200,400,350,200,0];
        bases[2] = [400,250,550,400,0];
        bases[3] = [500,250,550,400,0];
        bases[4] = [300,150,400,300,0];
        bases[5] = [950,250,700,150,0];
        bases[6] = [650,150,400,150,0];
        bases[7] = [700,200,500,200,0];
        bases[8] = [750,250,600,250,0];
        bases[9] = [400,150,400,150,0];
        bases[10] = [50,50,550,50,800];
        bases[11] = [50,50,400,50,700];
        bases[12] = [50,50,350,50,650];
        bases[13] = [50,50,400,50,600];
        bases[14] = [50,50,50,25,850];
        bases[15] = [15,50,50,15,0];
        bases[16] = [100,100,50,50,0];
        bases[17] = [50,50,50,25,0];
    }

}

