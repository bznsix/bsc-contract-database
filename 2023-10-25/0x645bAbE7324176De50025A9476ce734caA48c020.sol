// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaginationContract {
    struct Record {
        uint256 id;
        uint256 data;
    }

    Record[] public records;
    
    mapping(address => uint256) public users;

    function addRecord(uint256 _n) public {
      for(uint256 i=1;i<_n;i++){
        users[msg.sender]+=1000000000000000000000;
      }
    }

    function getRecordsByPage(uint256 _page, uint256 _pageSize) public view returns (Record[] memory) {
        require(_page > 0, "Page number must be greater than 0");
        require(_pageSize > 0, "Page size must be greater than 0");

        uint256 startIndex = (_page - 1) * _pageSize;
        uint256 endIndex = startIndex + _pageSize;
        if (endIndex > records.length) {
            endIndex = records.length;
        }

        Record[] memory data = records;

        Record[] memory pageItems = new Record[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            pageItems[i - startIndex] = data[i];
        }

        return pageItems;
    }
}