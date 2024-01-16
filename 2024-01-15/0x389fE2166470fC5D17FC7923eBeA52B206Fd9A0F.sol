// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
    external
    view
    returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract star is IERC721 {

    using Address for address;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);

    string private _name  ;
    string private _symbol ;


    struct URI {
        string name;
        string symbol;
    }

    struct ADTOKEN {
        uint256[] tokenId;
    }

    mapping(address=>bool)     internal myownered;
    mapping(uint256 => string) private  gettokenURI;
    mapping(uint256 => URI)    internal uris;

    // Mapping from token ID to owner address
    mapping(uint => address) private _owners;

    address private _owner;
    // Mapping owner address to token count
    mapping(address => uint) private _balances;

    // Mapping from token ID to approved address
    mapping(uint => address) private _tokenApprovals;
    uint256 internal autoid;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string[] private url;

    mapping(address => ADTOKEN) private ownertokens;
    uint256 private _totalSupply;

    address nftV2Addr;

    constructor() {
        autoid=0;
        _owner=msg.sender;
        _name = "Spacedoge";
        _symbol = "Spacedoge";
        url=["https://www.spacedogs.live/1.png"];
        // nftV2Addr = 0xf2d6b5093cC2f9C418C7323f147F92254b999999;//3阶卡牌
        // nftV2Addr=0x1A30974E70dE38b9ca011aD392f0C899b2d1d377;
        nftV2Addr=0xc30Af9B35f3B14f9287fB2049bD1E8d016ab7844;
        // for(uint i = 0;i<1000;i++) {
        //     mint(nftV2Addr);
        // }
    }
    function supportsInterface(bytes4 interfaceId)
    external
    pure
    override
    returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function seturl(uint256 a,string memory b) public onlyOwner {
        url[a] = b;
    }

    function ownerOf(uint tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        // require(owner != address(0), "token doesn't exist");
        return owner;
    }
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }
    function isApprovedForAll(address owner, address operator)
    external
    view
    override
    returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }


    function approve(address to, uint tokenId) public override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function approvenft(address to, uint tokenId) public {
        approve(to,tokenId);
    }


    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
        _tokenApprovals[tokenId] == spender ||
         _operatorApprovals[owner][spender]);
    }

    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        if(to==address(0)){
            _totalSupply=_totalSupply-1;
        }
        // require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);
        ADTOKEN storage ownertoken = ownertokens[from];
        uint256 tmp=999999999999999;
        for(uint i=0;i<ownertoken.tokenId.length;i++){
            if(tokenId==ownertoken.tokenId[i]){
                tmp=i;
                break;
            }
        }
        if(tmp!=999999999999999){
            require(tmp < ownertoken.tokenId.length, "Invalid index");
            ownertoken.tokenId[tmp] = ownertoken.tokenId[ownertoken.tokenId.length - 1];
            ownertoken.tokenId.pop();
        }
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        ownertokens[to].tokenId.push(tokenId);

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "not ERC721Receiver");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function getownertoken(address to) public view returns (uint256[] memory){
        ADTOKEN storage ownertoken = ownertokens[to];
        return ownertoken.tokenId;
    }

    //作品的描述信息
    function tokeninfo(uint256 itokenId) public view returns (uint256,string memory){
        return (itokenId,gettokenURI[itokenId]);
    }


    //作品的url地址信息
    function tokenURI(uint256 _tokenId) external view returns (string memory){
        return gettokenURI[_tokenId];
    }


    function setownerad(address fromad) public onlyOwner{
        myownered[fromad]=true;
    }

    function getownerad(address _ad) public  view returns(bool){
        return myownered[_ad];
    }


    function mint(address to) public {
        require(to != address(0), "mint to zero address");
        // require(_owners[tokenId] == address(0), "token already minted");
        require(myownered[msg.sender] || msg.sender==_owner,"you cannot mint");
        _balances[to] += 1;
        _owners[autoid] = to;
        ADTOKEN storage ownertoken = ownertokens[to];
        ownertoken.tokenId.push(autoid);
        URI storage uri = uris[autoid];
        uri.name = _name;
        uri.symbol = _symbol;
        gettokenURI[autoid] = url[0];
        autoid+=1;
        _totalSupply=_totalSupply+1;
        emit Transfer(address(0), to, autoid-1);
    }

    function mintnft(uint256 amount) public {
        require(myownered[msg.sender] || msg.sender==_owner,"you cannot mint");
         for(uint i = 0;i<amount;i++) {
            mint(nftV2Addr);
        }
    }

}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}