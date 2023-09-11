// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {ERC721} from "./erc-721.sol";


contract NFT is ERC721 {
    // Mapping from token ID to owner address
    mapping(uint256 => address) private tokenOwners;

    // Mapping from owner address to token count
    mapping(address => uint256) private ownedTokensCount;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private operatorApprovals;

    // Implement other storage variables and modifiers as needed

    bytes4 constant internal ERC721_RECEIVED = 0x150b7a02;


    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Invalid address");
        return ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwners[_tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _transferFrom(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");
        tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    // Implement additional functions and modifiers as needed

    // Private function to safely transfer tokens
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private {
        _transferFrom(_from, _to, _tokenId);
        // Check if the recipient is a contract and if so, call the onERC721Received function
        if (_isContract(_to)) {
            bytes4 retval = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(retval == ERC721_RECEIVED, "Transfer to non-ERC721Receiver implementer");
        }
    }

    // Private function to transfer tokens
    function _transferFrom(address _from, address _to, uint256 _tokenId) private {
        require(_from != address(0), "Invalid sender address");
        require(_to != address(0), "Invalid recipient address");
        address owner = ownerOf(_tokenId);
        require(owner == _from, "Sender is not the token owner");
        require(owner == msg.sender || getApproved(_tokenId) == msg.sender || isApprovedForAll(owner, msg.sender), "Not authorized");
        tokenOwners[_tokenId] = _to;
        ownedTokensCount[_from] -= 1;
        ownedTokensCount[_to] += 1;
        emit Transfer(_from, _to, _tokenId);
    }

    // Private function to check if an address is a contract
    function _isContract(address _addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// Example ERC721Receiver interface
interface ERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns (bytes4);
}
