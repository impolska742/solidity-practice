// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ToDoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    modifier checkOutOfBounds(uint _index) {
        require(_index >= 0 && _index < todos.length, "Index out of bounds");
        _;
    }

    // Create - To insert a new Todo list item
    function create(string calldata _todo) external {
        todos.push(Todo({
            text: _todo,
            completed: false
        }));
    }

    // UpdateText - To update the text of the Todo
    function updateText(uint _index, string calldata _text) external checkOutOfBounds(_index) {
        // Method - 1
        
        // This method is fairly straight-forward althought for multiple
        // iterations, it will use more gas as the computation is more complex
        // than Method - 2 as we are doing 2 things,
        // 1. Accessing the Array
        // 2. Updating the field, "text" with "_text"
        todos[_index].text = _text;

        // Method - 2
        
        // It not so straight-forward way to express the same thing.
        // But for multiple iterations, this method will save gas 
        // as we are accessing array only once, and now we can change the 
        // fields as many times we like without accessing the array again and again.
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    // Get - Get the data stored inside the Todo
    function get(uint _index) 
        external view 
        checkOutOfBounds(_index) 
        returns (string memory, bool) 
    {
        // storage - 29386
        // memory - 29480

        Todo memory todo = todos[_index];
        return (todo.text, todo.completed);
    }

    function toggleCompleted(uint _index) 
        external checkOutOfBounds(_index)
    {
        todos[_index].completed = !todos[_index].completed;
    }
}
