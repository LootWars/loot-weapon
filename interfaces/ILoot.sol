pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

interface ILoot{
    function ownerOf(uint256 tokenId) external view returns(address);
    function getWeapon(uint256 tokenId) external view returns (string memory);
}
