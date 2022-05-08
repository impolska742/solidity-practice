// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Data locations - storage, memory, calldata()

// storage - the variable is a state variable
// memory - the data is loaded onto memory
// calldata - is like memory, except it can only be used for function inputs
         // - it has a potential to save gas.

contract DataLocations {
    struct MyStruct {
        uint foo;
        string text;
    }

    mapping(address => MyStruct) public myStructs;

    function examples(uint[] calldata y, string calldata s) 
        external returns (uint[] memory) 
    {
        myStructs[msg.sender] = MyStruct({
            foo: 123,
            text: "bar"
        });

        MyStruct storage myStruct = myStructs[msg.sender];
        // If you want to modify the struct "myStruct" at myStructs[msg.sender]
        // we have to declare it as "storage"

        myStruct.text = "foo";

        MyStruct memory readOnly = myStructs[msg.sender];
        // If we want to use the struct at myStructs[msg.sender], 
        // and just want to read the value inside it, we can use it as "memory"

        // It does not mean that we cannot modify the variables defined as "memory"
        // If we make some changes to the variable "readOnly"
        // The changes will be reverted back after the function is done executing

        readOnly.foo = 456;

        _internal(y);

        uint[] memory memArr = new uint[](3);
        memArr[0] = 234; 

        return memArr;
    }

    function _internal(uint[] calldata y) private pure {
        uint x = y[0];
    }
}
