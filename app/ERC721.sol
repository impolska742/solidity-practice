// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface IERC721Reciever {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(address indexed from, address indexed to, uint tokenId);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    mapping(uint => address) internal _ownerOf;
    mapping(address => uint) internal _balanceOf;
    mapping(uint => address) internal _approvals;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint tokenId) external view returns (address owner) {
        require(_ownerOf[tokenId] != address(0), "token does not exist");
        return _ownerOf[tokenId];
    }

    function balanceOf(address owner) external view returns (uint balance) {
        require(owner != address(0), "token does not exist");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address to, uint tokenId) external {
        address owner = _ownerOf[tokenId];

        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "Not Authorized!"
        );

        _approvals[tokenId] = to;

        emit Approval(owner, msg.sender, tokenId);
    }

    function getApproved(
        uint tokenId
    ) external view returns (address operator) {
        require(_ownerOf[tokenId] != address(0), "To ken does not exist");
        return _approvals[tokenId];
    }

    function _isApprovedForOwner(
        address owner,
        address spender,
        uint tokenId
    ) internal view returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[tokenId]);
    }

    function transferFrom(address from, address to, uint tokenId) public {
        require(from == _ownerOf[tokenId], "From != Owner");
        require(to != address(0), "To = zero address");
        require(
            _isApprovedForOwner(from, msg.sender, tokenId),
            "Not Authorized"
        );

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;
        delete _approvals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint tokenId) external {
        transferFrom(from, to, tokenId);
        require(
            to.code.length == 0 ||
                IERC721Reciever(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    ""
                ) ==
                IERC721Reciever.onERC721Received.selector,
            "Unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external {
        transferFrom(from, to, tokenId);
        require(
            to.code.length == 0 ||
                IERC721Reciever(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                ) ==
                IERC721Reciever.onERC721Received.selector,
            "Unsafe recipient"
        );
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "Address zero");
        require(_ownerOf[tokenId] == address(0), "Token already exists");

        _balanceOf[to]++;
        _ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal {
        address owner = _ownerOf[tokenId];

        require(owner != address(0), "Token does not exist");

        _balanceOf[owner]--;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
}

contract MyNFT is ERC721 {
    function mint(address to, uint tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint tokenId) external {
        require(msg.sender == _ownerOf[tokenId], "Not owner");
        _burn(tokenId);
    }
}
