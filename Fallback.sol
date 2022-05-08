// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/**

Fallback executed when
- function does not exist
- directly send ETH

fallback() or recieve()? 

                    Ether is sent to contract
                                |
                        is msg.data empty?
                             /    \
                            yes    no
                           /        \
                receive() exists?    fallback()
                    /  \
                  yes   no
                  /       \
            receive()   fallback()

 */


contract Fallback {
    event Log(string func, address sender, uint value, bytes data);

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    
    // receive() external payable {
    //     emit Log("recieve", msg.sender, msg.value, "");
    // }
}   