
contract userStorage{
    address public owner;
    address public operator;
    mapping(address => address[]) public users;
    constructor(){owner=msg.sender;}

    function setOperator(address _operator) external{
        require(msg.sender == owner, "owner ONLY");
        operator = _operator;
    }

    function addUsers(address _key, address[] memory _users, bool _deleteAll) external{
        require(msg.sender == operator || msg.sender == owner, "access denied(addUsers)");
        if( _deleteAll == true ) delete users[_key];
        for(uint256 i=0; i<_users.length; i++) users[_key].push(_users[i]);
    }

    function deleteUsers(address _key, uint256[] memory _indexes) external{
        require( msg.sender == _key || msg.sender == operator || msg.sender == owner, "access denided(deleteUsers)");
        require(_indexes.length > 0, "length is zero");
        
        uint256 length = _indexes.length;
        uint256 prev = type(uint256).max;
        for(uint256 i=0; i<length; i++){
            uint256 index = _indexes[i];
            require( prev > index, 'indexes are not sorted');
            _deleteUser(_key, index);
            prev = index;
        }
    }

    function deleteUser(address _key, uint256 _index) external{
        require( msg.sender == operator || msg.sender == owner, "access denied(deleteUser)");
        _deleteUser(_key, _index);
    }

    function getUsers(address _key) external view returns(address[] memory){
        return users[_key];
    }

    function usersLength(address _key) external view returns(uint256){
        return users[_key].length;
    }

    function getIndex(address _key, address _user) external view returns(uint256){
        for(uint256 i=0; i<users[_key].length; i++){
            if(users[_key][i] == _user) return i;
        }

        return type(uint256).max;
    }

    function getUsersByTime(address _key, uint256 maxUsers) external view returns(address[] memory resultUsers){
        if( users[_key].length == 0) return resultUsers;
        resultUsers = new address[](maxUsers);

        bool ranEndOfArray;
        uint256 resultIndex;
        for(uint256 i=block.timestamp % users[_key].length; resultIndex<maxUsers; i++){
            if( i == users[_key].length ){
                i = 0;
                ranEndOfArray = true;
            }
            if( ranEndOfArray == true && i == block.timestamp % users[_key].length ) break;
            resultUsers[resultIndex++] = users[_key][i];
        }
    }

    function _deleteUser(address _key, uint256 _index) internal{
        uint256 last = users[_key].length-1;
        if( last > 0 && _index != last) (users[_key][_index], users[_key][last]) = (users[_key][last], users[_key][_index]);
        users[_key].pop();

    }
}