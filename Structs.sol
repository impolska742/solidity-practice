// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Struct {
    struct Car {
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping(address => Car[]) public carsByOwner; 

    function examples() external {
        Car memory toyota = Car("Toyota", 1990, msg.sender);
        Car memory lambo = Car({ 
            model: "Lamborghini",
            year: 1980,
            owner: msg.sender
        });

        Car memory tesla;
        tesla.model = "Tesla";
        tesla.year = 2010;
        tesla.owner = msg.sender;

        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);

        cars.push(Car("Ferrari", 2020, msg.sender));

        Car storage _car = cars[0];
        _car.year = 1999;

        // Make the address 0;
        delete _car.owner;

        // Empty struct with default values
        delete cars[1];
    }
}