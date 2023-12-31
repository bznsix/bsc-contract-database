// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import {ICube} from "./ICube.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Cube is ICube, Ownable {
    bytes32 public immutable treeRoot;

    uint256 constant _BASE_AMOUNT = 150000000000000000000;
    uint8 constant _MAX_CHILDREN_COUNT = 6;
    ERC20 _token;
    uint16 private _nodesCount = 0;
    uint8[6] private _depthToGift;
    uint8[5] private _depthToAdminReward;
    address[5] private _adminAddresses;

    mapping(bytes32 => Node) private _nodes;
    mapping(bytes32 => uint256) private _balances;
    mapping(bytes32 => uint256) private _totalDeposited;
    mapping(bytes32 => uint256) private _currentDepositBalance;
    mapping(address => bytes32) private _nodeIdByWallet;
    mapping(bytes32 => Transfer[]) private _referralsUntransferedDeposits;
    mapping(bytes32 => mapping(uint8 => uint16)) private _referralsCountByDepth;
    mapping(bytes32 => uint256) private _accountLockTime;
    mapping(bytes32 => Transfer[]) private _referralsTransfers;

    modifier checkNodeExistence(bytes32 nodeId) {
        require(isNode(nodeId), "Error: node with current id does not exist.");
        _;
    }

    modifier checkNodeExistenceByWallet(address wallet) {
        require(
            getNodeIdByWallet(wallet) == 0,
            "Error: node with current address already exist."
        );
        _;
    }

    //constructor(address,address,uint8[6],address[5],uint8[5])
    constructor(
        address wallet,
        address _tokenAddress,
        uint8[6] memory depthToGift,
        address[5] memory adminAddresses,
        uint8[5] memory depthToAdminReward
    ) {
        _depthToGift = depthToGift;
        _adminAddresses = adminAddresses;
        _depthToAdminReward = depthToAdminReward;
        treeRoot = newNode(0, wallet);
        _token = ERC20(_tokenAddress);
    }

    function _getTreeDepth(bytes32 _nodeId) private view returns (uint8 depth) {
        Node memory node = _nodes[_nodeId];
        depth = 0;
        while (node.parentId != 0) {
            node = _nodes[node.parentId];
            depth++;
        }

        return depth;
    }

    function _registerChild(
        bytes32 _parentId,
        bytes32 _newNodeId
    ) private returns (uint8 parentIndex) {
        _nodes[_parentId].children.push(_newNodeId);
        _accountLockTime[_parentId] = block.timestamp + 60 days;
        return uint8(getNodeChildrenCount(_parentId) - 1);
    }

    function _updateReferralsCountByDepth(
        bytes32 _nodeId
    ) private returns (bool success) {
        Node memory node = _nodes[_nodeId];
        uint8 depth = 0;
        while (node.parentId != 0) {
            _referralsCountByDepth[node.parentId][depth]++;
            node = _nodes[node.parentId];
            depth++;
        }
        return true;
    }

    function _newNode(
        bytes32 _parentId,
        bytes32 _newNodeId,
        address _wallet
    ) private returns (bool success) {
        Node memory node;
        node.isNode = true;
        node.id = _newNodeId;
        node.parentId = _parentId;
        if (_parentId > 0) {
            node.parentIndex = _registerChild(_parentId, _newNodeId);
        }

        node.wallet = _wallet;
        node.canSell = false;
        _nodes[_newNodeId] = node;
        _balances[_newNodeId] = 0;
        _nodeIdByWallet[_wallet] = _newNodeId;
        _nodesCount++;
        return true;
    }

    function _transferToAdmins(
        bytes32 _fromNode,
        uint256 _totalWithdraw
    ) private returns (bool success) {
        for (uint i = 0; i < _adminAddresses.length; ++i) {
            address adminAddress = _adminAddresses[i];
            uint amount = (_totalWithdraw * _depthToAdminReward[i]) / 1000;
            if (amount > 0) {
                _token.transfer(adminAddress, amount);
            } else {
                break;
            }
        }

        return _decreaseCurrentDeposit(_fromNode, _totalWithdraw);
    }

    function _decreaseCurrentDeposit(
        bytes32 nodeId,
        uint256 transfered
    ) private returns (bool success) {
        require(
            _currentDepositBalance[nodeId] >= transfered,
            "Error: cannot decrease zero deposit balance."
        );
        _currentDepositBalance[nodeId] -= transfered;

        emit CurrentDepositDecreased(nodeId, transfered);
        return true;
    }

    function _appendToArray(
        bytes32 nodeId,
        bytes32 referralId,
        address spender,
        uint256 amount,
        uint8 depth,
        uint256 timestamp
    ) public {
        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[nodeId].length;
            i++
        ) {
            if (_referralsUntransferedDeposits[nodeId][i].amount == 0) {
                _referralsUntransferedDeposits[nodeId][i]
                    .referralId = referralId;
                _referralsUntransferedDeposits[nodeId][i].spender = spender;

                _referralsUntransferedDeposits[nodeId][i].amount = amount;

                _referralsUntransferedDeposits[nodeId][i].depth = depth;
                _referralsUntransferedDeposits[nodeId][i].timestamp = timestamp;
                return;
            }
        }
        Transfer memory referralsTransfer = Transfer(
            referralId,
            spender,
            amount,
            depth,
            timestamp
        );
        _referralsUntransferedDeposits[nodeId].push(referralsTransfer);
    }

    function existPayment(
        bytes32 nodeId,
        bytes32 referralId,
        address spender,
        uint256 amount,
        uint8 depth,
        uint256 timestamp
    ) public returns (bool) {
        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[nodeId].length;
            i++
        ) {
            if (
                _referralsUntransferedDeposits[nodeId][i].referralId ==
                referralId &&
                _referralsUntransferedDeposits[nodeId][i].spender == spender &&
                _referralsUntransferedDeposits[nodeId][i].amount == amount &&
                _referralsUntransferedDeposits[nodeId][i].depth == depth &&
                _referralsUntransferedDeposits[nodeId][i].timestamp == timestamp
            ) {
                return true;
            }
        }

        return false;
    }

    function _transferNodeReferralsMoney(
        bytes32 nodeId
    ) private returns (bool) {
        Node memory node = _nodes[nodeId];
        bytes32 parentId = _nodes[nodeId].parentId;
        uint8 depth = 1;
        uint totalAmount = 0;
        uint amount;

        while (parentId != 0) {
            if (depth < 7) {
                amount = (_BASE_AMOUNT * _depthToGift[depth - 1]) / 100;
                if (amount > 0) {
                    if (
                        parentId == treeRoot ||
                        (getNodeActiveChildrenCount(parentId) >= depth &&
                            isActive(parentId))
                    ) {
                        Transfer memory referralsTransfer = Transfer(
                            node.id,
                            node.wallet,
                            amount,
                            depth,
                            block.timestamp
                        );
                        _token.transfer(_nodes[parentId].wallet, amount);
                        updateNodeBalance(parentId, amount);
                        _referralsTransfers[parentId].push(referralsTransfer);
                    } else {
                        if (
                            !existPayment(
                                parentId,
                                node.id,
                                node.wallet,
                                amount,
                                depth,
                                block.timestamp
                            )
                        ) {
                            _appendToArray(
                                parentId,
                                node.id,
                                node.wallet,
                                amount,
                                depth,
                                block.timestamp
                            );
                        }
                    }
                    _decreaseCurrentDeposit(node.id, amount);
                    totalAmount += amount;
                    parentId = _nodes[parentId].parentId;
                    depth++;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        if (
            _referralsUntransferedDeposits[_nodes[nodeId].parentId].length >
            0 &&
            isActive(_nodes[nodeId].parentId)
        ) {
            transferUntransferedDepositsByDepth(
                _nodes[nodeId].parentId,
                getNodeActiveChildrenCount(_nodes[nodeId].parentId)
            );
        }
        if (_BASE_AMOUNT - totalAmount > 0) {
            return _transferToAdmins(nodeId, _BASE_AMOUNT - totalAmount);
        }
        return true;
    }

    function _deleteFromArray(
        bytes32 nodeId,
        bytes32 referralId,
        address spender,
        uint256 amount,
        uint8 depth,
        uint256 timestamp
    ) private {
        // uint index;
        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[nodeId].length;
            i++
        ) {
            if (
                _referralsUntransferedDeposits[nodeId][i].referralId ==
                referralId &&
                _referralsUntransferedDeposits[nodeId][i].spender == spender &&
                _referralsUntransferedDeposits[nodeId][i].amount == amount &&
                _referralsUntransferedDeposits[nodeId][i].depth == depth &&
                _referralsUntransferedDeposits[nodeId][i].timestamp == timestamp
            ) {
                delete _referralsUntransferedDeposits[nodeId][i];
                break;
            }
        }
    }

    function newNode(
        bytes32 parentId,
        address wallet
    )
        public
        virtual
        override
        onlyOwner
        checkNodeExistenceByWallet(wallet)
        returns (bytes32)
    {
        if (!isNode(parentId) && parentId > 0) revert();
        require(
            getNodeChildrenCount(parentId) < _MAX_CHILDREN_COUNT,
            "Error: this user already has max count of children."
        );
        bytes32 newNodeId = keccak256(
            abi.encode(parentId, wallet, block.number)
        );
        _newNode(parentId, newNodeId, wallet);
        _updateReferralsCountByDepth(newNodeId);
        _accountLockTime[newNodeId] = block.timestamp + 3 days;

        emit NewNodeCreated(newNodeId, wallet, parentId);
        return newNodeId;
    }

    function updateNodeWallet(
        bytes32 nodeId,
        address wallet
    )
        public
        virtual
        override
        onlyOwner
        checkNodeExistence(nodeId)
        checkNodeExistenceByWallet(wallet)
        returns (bool)
    {
        require(
            _nodes[nodeId].canSell == true ||
                block.timestamp > _accountLockTime[nodeId],
            "User not agree to sell account or not time yet"
        );

        Node storage node = _nodes[nodeId];
        {
            _nodeIdByWallet[node.wallet] = 0;
            node.wallet = wallet;
            _nodeIdByWallet[wallet] = nodeId;
        }

        emit NodeWalletChanged(nodeId, wallet);
        return true;
    }

    function getNode(address wallet) public view returns (Node memory) {
        bytes32 idx = getNodeIdByWallet(wallet);
        return _nodes[idx];
    }

    function getNodeById(bytes32 nodeId) public view returns (Node memory) {
        return _nodes[nodeId];
    }

    function updateNodeDeposit(
        bytes32 nodeId,
        uint256 deposit
    )
        public
        virtual
        override
        onlyOwner
        checkNodeExistence(nodeId)
        returns (bool)
    {
        require(
            _token.balanceOf(address(this)) >=
                (_BASE_AMOUNT + 5000000000000000000),
            "Error: contract balance must be greater or equal than _BASE_AMOUNT"
        );
        _token.transfer(msg.sender, 5000000000000000000);
        _totalDeposited[nodeId] += deposit;
        _currentDepositBalance[nodeId] += deposit;
        _accountLockTime[nodeId] = block.timestamp + 60 days;

        emit NodeDeposited(nodeId, deposit);
        return _transferNodeReferralsMoney(nodeId);
    }

    function updateNodeDepositSingleState(
        bytes32 nodeId,
        uint256 deposit
    ) public onlyOwner checkNodeExistence(nodeId) {
        _token.transfer(msg.sender, 5000000000000000000);
        _totalDeposited[nodeId] += deposit;
        _currentDepositBalance[nodeId] += deposit;
        _accountLockTime[nodeId] = block.timestamp + 60 days;
        emit NodeDeposited(nodeId, deposit);
    }

    function updateNodeDepositSingleTransferReferals(
        bytes32 nodeId
    ) public onlyOwner checkNodeExistence(nodeId) returns (bool) {
        Node memory node = _nodes[nodeId];
        bytes32 parentId = _nodes[nodeId].parentId;
        uint8 depth = 1;
        uint totalAmount = 0;
        uint amount;

        while (parentId != 0) {
            if (depth < 7) {
                amount = (_BASE_AMOUNT * _depthToGift[depth - 1]) / 100;
                if (amount > 0) {
                    if (
                        parentId == treeRoot ||
                        (getNodeActiveChildrenCount(parentId) >= depth &&
                            isActive(parentId))
                    ) {
                        Transfer memory referralsTransfer = Transfer(
                            node.id,
                            node.wallet,
                            amount,
                            depth,
                            block.timestamp
                        );
                        _token.transfer(_nodes[parentId].wallet, amount);
                        updateNodeBalance(parentId, amount);
                        _referralsTransfers[parentId].push(referralsTransfer);
                    } else {
                        if (
                            !existPayment(
                                parentId,
                                node.id,
                                node.wallet,
                                amount,
                                depth,
                                block.timestamp
                            )
                        ) {
                            _appendToArray(
                                parentId,
                                node.id,
                                node.wallet,
                                amount,
                                depth,
                                block.timestamp
                            );
                        }
                    }
                    _decreaseCurrentDeposit(node.id, amount);
                    totalAmount += amount;
                    parentId = _nodes[parentId].parentId;
                    depth++;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        if (_BASE_AMOUNT - totalAmount > 0) {
            return _transferToAdmins(nodeId, _BASE_AMOUNT - totalAmount);
        }
        return true;
    }

    function updateNodeDepositSingleTransferUntransferedDepositsByDepth(
        bytes32 nodeId,
        bytes32 referralId,
        address spender,
        uint256 amount,
        uint8 depthTransfer,
        uint256 timestamp
    ) public virtual onlyOwner checkNodeExistence(nodeId) {
        Node memory node = _nodes[nodeId];

        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[node.id].length;
            i++
        ) {
            if (
                _referralsUntransferedDeposits[nodeId][i].referralId ==
                referralId &&
                _referralsUntransferedDeposits[nodeId][i].spender == spender &&
                _referralsUntransferedDeposits[nodeId][i].amount == amount &&
                _referralsUntransferedDeposits[nodeId][i].depth ==
                depthTransfer &&
                _referralsUntransferedDeposits[nodeId][i].timestamp == timestamp
            ) {
                _token.transfer(
                    node.wallet,
                    _referralsUntransferedDeposits[node.id][i].amount
                );
                updateNodeBalance(
                    node.id,
                    _referralsUntransferedDeposits[node.id][i].amount
                );
                _referralsTransfers[node.id].push(
                    _referralsUntransferedDeposits[node.id][i]
                );
                delete _referralsUntransferedDeposits[nodeId][i];
                break;
            }
        }
    }

    function updateNodeBalance(
        bytes32 nodeId,
        uint256 transferedAmount
    )
        public
        virtual
        override
        onlyOwner
        checkNodeExistence(nodeId)
        returns (bool)
    {
        _balances[nodeId] += transferedAmount;

        emit NodeBalanceChanged(nodeId, transferedAmount);
        return true;
    }

    function transferUntransferedDeposits(
        bytes32 nodeId
    )
        public
        virtual
        override
        onlyOwner
        checkNodeExistence(nodeId)
        returns (bool)
    {
        Node memory node = _nodes[nodeId];

        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[node.id].length;
            i++
        ) {
            if (
                _referralsUntransferedDeposits[node.id][i].amount > 0 &&
                getNodeChildrenCount(node.id) == 6
            ) {
                _token.transfer(
                    node.wallet,
                    _referralsUntransferedDeposits[node.id][i].amount
                );
                updateNodeBalance(
                    node.id,
                    _referralsUntransferedDeposits[node.id][i].amount
                );
            }
        }
        delete _referralsUntransferedDeposits[node.id];
        return true;
    }

    function transferUntransferedDepositsByDepth(
        bytes32 nodeId,
        uint8 depth
    ) public virtual onlyOwner checkNodeExistence(nodeId) returns (bool) {
        Node memory node = _nodes[nodeId];
        // uint k = 0;
        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[node.id].length;
            i++
        ) {
            if (
                _referralsUntransferedDeposits[node.id][i].amount > 0 &&
                _referralsUntransferedDeposits[node.id][i].depth <= depth
            ) {
                _token.transfer(
                    node.wallet,
                    _referralsUntransferedDeposits[node.id][i].amount
                );
                updateNodeBalance(
                    node.id,
                    _referralsUntransferedDeposits[node.id][i].amount
                );
                _referralsTransfers[node.id].push(
                    _referralsUntransferedDeposits[node.id][i]
                );

                _deleteFromArray(
                    node.id,
                    _referralsUntransferedDeposits[node.id][i].referralId,
                    _referralsUntransferedDeposits[node.id][i].spender,
                    _referralsUntransferedDeposits[node.id][i].amount,
                    _referralsUntransferedDeposits[node.id][i].depth,
                    _referralsUntransferedDeposits[node.id][i].timestamp
                );
                // k++;
            }
        }

        return true;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override onlyOwner returns (bool) {
        return _token.transfer(to, amount);
    }

    function changeAdmin(
        address from,
        address to
    ) public virtual override onlyOwner returns (bool) {
        for (uint i = 0; i < _adminAddresses.length; i++) {
            if (_adminAddresses[i] == from) {
                _adminAddresses[i] = to;
                return true;
            }
        }
        return false;
    }

    function allowChangeWallet() public {
        bytes32 nodeId = getNodeIdByWallet(msg.sender);
        Node memory node = _nodes[nodeId];
        require(node.wallet == msg.sender, "Please sign with node wallet");
        _nodes[nodeId].canSell = true;
    }

    function disallowChangeWallet() public {
        bytes32 nodeId = getNodeIdByWallet(msg.sender);
        Node memory node = _nodes[nodeId];
        require(node.wallet == msg.sender, "Please sign with node wallet");
        _nodes[nodeId].canSell = true;
    }

    function isNode(
        bytes32 nodeId
    ) public view virtual override returns (bool) {
        return _nodes[nodeId].isNode;
    }

    function isActive(
        bytes32 nodeId
    ) public view virtual override returns (bool) {
        return block.timestamp <= _accountLockTime[nodeId];
    }

    function getNodeTimestamp(
        bytes32 nodeId
    ) public view virtual override returns (uint256) {
        return _accountLockTime[nodeId];
    }

    function getNodesCount() public view virtual override returns (uint16) {
        return _nodesCount;
    }

    function getReferralsTransfers(
        bytes32 nodeId
    ) public view virtual override returns (Transfer[] memory) {
        return _referralsTransfers[nodeId];
    }

    function getReferralsTransfersByDepth(
        bytes32 nodeId,
        uint8 depth
    ) public view virtual override returns (Transfer[] memory) {
        Transfer[] memory transfers;
        uint item = 0;

        for (uint i = 0; i < _referralsTransfers[nodeId].length; i++) {
            Transfer memory referralsTransfer = _referralsTransfers[nodeId][i];
            if (referralsTransfer.depth == depth) {
                transfers[item] = referralsTransfer;
                item++;
            }
        }

        return transfers;
    }

    function getReferralsUntransferedDeposits(
        bytes32 nodeId
    ) public view virtual override returns (Transfer[] memory) {
        return _referralsUntransferedDeposits[nodeId];
    }

    function getReferralsUntransferedDepositsByDepth(
        bytes32 nodeId,
        uint8 depth
    ) public view virtual override returns (Transfer[] memory) {
        Transfer[] memory untransferedDeposits;
        uint item = 0;

        for (
            uint i = 0;
            i < _referralsUntransferedDeposits[nodeId].length;
            i++
        ) {
            Transfer
                memory referralsUntransferedDeposit = _referralsUntransferedDeposits[
                    nodeId
                ][i];
            if (referralsUntransferedDeposit.depth == depth) {
                untransferedDeposits[item] = referralsUntransferedDeposit;
                item++;
            }
        }

        return untransferedDeposits;
    }

    function getReferralsCountByDepth(
        bytes32 nodeId,
        uint8 depth
    ) public view virtual override returns (uint16) {
        return _referralsCountByDepth[nodeId][depth - 1];
    }

    function getNodeParentId(
        bytes32 nodeId
    ) public view virtual override returns (bytes32) {
        return _nodes[nodeId].parentId;
    }

    function getNodeParentIndex(
        bytes32 nodeId
    ) public view virtual override returns (uint8) {
        return _nodes[nodeId].parentIndex;
    }

    function getNodeChildren(
        bytes32 nodeId
    ) public view virtual override returns (bytes32[] memory children) {
        return _nodes[nodeId].children;
    }

    function getNodeChildrenCount(
        bytes32 nodeId
    ) public view virtual override returns (uint8) {
        return uint8(_nodes[nodeId].children.length);
    }

    function getNodeActiveChildrenCount(
        bytes32 nodeId
    ) public view virtual override returns (uint8) {
        uint8 count = 0;
        for (uint i = 0; i < _nodes[nodeId].children.length; i++) {
            if (_totalDeposited[_nodes[nodeId].children[i]] >= _BASE_AMOUNT) {
                count++;
            }
        }
        return count;
    }

    function getNodeWallet(
        bytes32 nodeId
    ) public view virtual override returns (address) {
        return _nodes[nodeId].wallet;
    }

    function getNodeChildAtIndex(
        bytes32 nodeId,
        uint8 index
    ) public view virtual override returns (bytes32) {
        return _nodes[nodeId].children[index];
    }

    function getNodeIdByWallet(
        address wallet
    ) public view virtual override returns (bytes32) {
        return _nodeIdByWallet[wallet];
    }

    function getBalanceByNodeId(
        bytes32 nodeId
    ) public view virtual override returns (uint256) {
        return _balances[nodeId];
    }

    function getChildrenBalances(
        bytes32 nodeId
    ) public view virtual override returns (uint256[6] memory balances) {
        Node memory parentNode = _nodes[nodeId];
        for (uint i = 0; i < parentNode.children.length; ++i) {
            balances[i] = _balances[parentNode.children[i]];
        }
        return balances;
    }

    function getChildrenTotalBalances(
        bytes32 nodeId
    ) public view virtual override returns (uint256 total) {
        Node memory parentNode = _nodes[nodeId];
        for (uint i = 0; i < parentNode.children.length; ++i) {
            total += _balances[parentNode.children[i]];
        }
        return total;
    }

    function getNodeCurrentDeposit(
        bytes32 nodeId
    ) public view virtual override returns (uint256) {
        return _currentDepositBalance[nodeId];
    }

    function getNodeTotalDeposit(
        bytes32 nodeId
    ) public view virtual override returns (uint256) {
        return _totalDeposited[nodeId];
    }

    function getChildrenCurrentDeposits(
        bytes32 nodeId
    )
        public
        view
        virtual
        override
        returns (uint256[] memory childrenCurrentDeposits)
    {
        Node memory node = _nodes[nodeId];
        for (uint i = 0; i < node.children.length; ++i) {
            Node memory child = _nodes[node.children[i]];
            childrenCurrentDeposits[i] = _currentDepositBalance[child.id];
        }
        return childrenCurrentDeposits;
    }
}
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.18;

interface ICube {
    struct Node {
        bool isNode;
        bytes32 id;
        bytes32 parentId;
        uint8 parentIndex;
        address wallet;
        bytes32[] children;
        bool canSell;
    }

    struct Transfer {
        bytes32 referralId;
        address spender;
        uint256 amount;
        uint8 depth;
        uint256 timestamp;
    }

    event NewNodeCreated(
        bytes32 indexed nodeId,
        address indexed wallet,
        bytes32 parentId
    );
    event NodePayed(bytes32 indexed nodeId, bool payed, uint256 balance);
    event NodeDeposited(bytes32 indexed nodeId, uint256 deposit);
    event CurrentDepositDecreased(bytes32 indexed nodeId, uint256 transfered);
    event NodeWalletChanged(bytes32 indexed nodeId, address wallet);
    event NodeBalanceChanged(bytes32 indexed nodeId, uint256 transfered);
    event ReferralReplaced(
        bytes32 indexed previousParentId,
        bytes32 indexed newParentId,
        uint8 parentIndex
    );

    function newNode(
        bytes32 parentId,
        address wallet
    ) external returns (bytes32);

    function updateNodeWallet(
        bytes32 nodeId,
        address wallet
    ) external returns (bool);

    function updateNodeDeposit(
        bytes32 nodeId,
        uint256 deposit
    ) external returns (bool);

    function updateNodeBalance(
        bytes32 nodeId,
        uint256 transfered
    ) external returns (bool);

    function transferUntransferedDeposits(
        bytes32 nodeId
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function changeAdmin(
        address from,
        address to
    ) external returns (bool success);

    function isNode(bytes32 nodeId) external view returns (bool);

    function isActive(bytes32 nodeId) external view returns (bool);

    function getNodeTimestamp(bytes32 nodeId) external view returns (uint256);

    function getNodesCount() external view returns (uint16);

    function getReferralsTransfers(
        bytes32 nodeId
    ) external view returns (Transfer[] memory);

    function getReferralsTransfersByDepth(
        bytes32 nodeId,
        uint8 depth
    ) external view returns (Transfer[] memory);

    function getReferralsUntransferedDeposits(
        bytes32 nodeId
    ) external view returns (Transfer[] memory);

    function getReferralsUntransferedDepositsByDepth(
        bytes32 nodeId,
        uint8 depth
    ) external view returns (Transfer[] memory);

    function getReferralsCountByDepth(
        bytes32 nodeId,
        uint8 depth
    ) external view returns (uint16);

    function getNodeParentId(bytes32 nodeId) external view returns (bytes32);

    function getNodeParentIndex(bytes32 nodeId) external view returns (uint8);

    function getNodeChildren(
        bytes32 nodeId
    ) external view returns (bytes32[] memory children);

    function getNodeChildrenCount(bytes32 nodeId) external view returns (uint8);
    function getNodeActiveChildrenCount(bytes32 nodeId) external view returns (uint8);


    function getNodeWallet(bytes32 nodeId) external view returns (address);

    function getNodeChildAtIndex(
        bytes32 nodeId,
        uint8 index
    ) external view returns (bytes32);

    function getNodeIdByWallet(address wallet) external view returns (bytes32);

    function getBalanceByNodeId(bytes32 nodeId) external view returns (uint256);

    function getChildrenBalances(
        bytes32 nodeId
    ) external view returns (uint[6] memory balances);
    /// TODO: was uint256[] memory balances -> uint256[6] memory balances


    function getChildrenTotalBalances(
        bytes32 nodeId
    ) external view returns (uint256 total);

    function getNodeCurrentDeposit(
        bytes32 nodeId
    ) external view returns (uint256);

    function getNodeTotalDeposit(
        bytes32 nodeId
    ) external view returns (uint256);

    function getChildrenCurrentDeposits(
        bytes32 nodeId
    ) external view returns (uint256[] memory childrenCurrentDeposits);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
