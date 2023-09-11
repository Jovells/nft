pragma solidity ^0.5.9;

/**
 * @title ERC-1155 Multi Token Standard
 * @dev See https://eips.ethereum.org/EIPS/eip-1155
 * Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
contract ERC1155 {
    mapping(address => mapping(uint256 => uint256)) private balances;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    string private uri;

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    constructor(string memory _uri) public {
        uri = _uri;
    }

    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {
        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; ++i) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) internal {
        require(_to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, _from, _to, _id, _value, _data);

        uint256 fromBalance = balances[_from][_id];
        require(fromBalance >= _value, "ERC1155: insufficient balance for transfer");
        balances[_from][_id] = fromBalance - _value;
        balances[_to][_id] += _value;

        emit TransferSingle(operator, _from, _to, _id, _value);

        _doSafeTransferAcceptanceCheck(operator, _from, _to, _id, _value, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {
        require(msg.sender == _from || operatorApprovals[_from][msg.sender], "ERC1155: caller is not owner nor approved");
        _safeTransferFrom(_from, _to, _id, _value, _data);
    }

    function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) internal {
        require(_to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, _from, _to, _ids, _values, _data);

        require(_ids.length == _values.length, "ERC1155: ids and values length mismatch");

        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 value = _values[i];

            uint256 fromBalance = balances[_from][id];
            require(fromBalance >= value, "ERC1155: insufficient balance for transfer");
            balances[_from][id] = fromBalance - value;
            balances[_to][id] += value;
        }

        emit TransferBatch(operator, _from, _to, _ids, _values);

        _doSafeBatchTransferAcceptanceCheck(operator, _from, _to, _ids, _values, _data);
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external {
        require(msg.sender == _from || operatorApprovals[_from][msg.sender], "ERC1155: caller is not owner nor approved");
        _safeBatchTransferFrom(_from, _to, _ids, _values, _data);
    }

    function _beforeTokenTransfer(
        address operator,
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal {}

    function _beforeTokenTransfer(
        address operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) internal {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) private {
        if (_to.isContract()) {
            try IERC1155Receiver(_to).onERC1155Received(operator, _from, _id, _value, _data) returns (bytes4 response) {
                if (response != IERC1155Receiver(_to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) private {
        if (_to.isContract()) {
            try IERC1155Receiver(_to).onERC1155BatchReceived(operator, _from, _ids, _values, _data) returns (bytes4 response) {
                if (response != IERC1155Receiver(_to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }
}

interface IERC1155Receiver {
    function onERC1155Received(address operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns (bytes4);
    function onERC1155BatchReceived(address operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns (bytes4);
}
