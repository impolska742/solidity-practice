// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ForAndWhileLoops {
    function loops() external {
        for(uint i = 0; i < 10; i++) {
            // code
            if(i == 3) continue;
            // more code
            if(i == 5) break;
        }

        uint j = 0;
        while(j < 10) {
            // code
            j++;
        }
    }

    function sum_n(uint x) external pure returns (uint) {
        uint sum = 0;
        for(uint i = 1; i <= x; i++) {
            sum += i;
        }
        return sum;
    }
}