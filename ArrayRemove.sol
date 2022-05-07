// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Remove array elements by shifting elements to the left

contract ArrayShift {
    uint[] public arr;

    function examples() public {
        arr = [1,2,3];
        delete arr[1];
        // 1, 0, 3
    }

    function remove(uint _index) public {
        require(_index >= 0 && _index < arr.length, "Given Index is out of bounds");
        for(uint i = _index + 1; i < arr.length; i++) { 
            arr[i - 1] = arr[i]; 
        }

        arr.pop();
    }

    function test() external {
        arr = [1,2,3,4,5];
        remove(2);
        // 1, 2, 4, 5
        assert(arr[0] == 1);
        assert(arr[1] == 2);
        assert(arr[2] == 4);
        assert(arr[3] == 5);
        assert(arr.length == 4);

        arr = [1];
        remove(0);

        // []

        assert(arr.length == 0);
    }
}

contract ArrayReplaceLast {
    uint[] public arr; 

    // [1, 2, 3, 4] -- remove(1) --> [1, 4, 3]
    // [1, 4, 3] -- remove(2) --> [1, 4]


    // O(1)
    function remove(uint _index) public {
        require(_index >= 0 && _index < arr.length, "Index out of bounds");
        arr[_index] = arr[arr.length - 1];
        arr.pop();
    }

    function test() external {
        arr = [1, 2, 3, 4];

        remove(1);
        // [1, 4, 3]

        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2);
        // [1, 4]

        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }
}