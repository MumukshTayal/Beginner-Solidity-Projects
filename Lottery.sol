// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract Lottery{

    address public manager;
    address payable[] participants;

    constructor() {
        manager = msg.sender;
    }

    receive() payable external{
        require(msg.value == 1 ether);
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(msg.sender==manager);
        return(address(this).balance);
    }

    function random() public view returns(uint){
        return(uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp, participants.length))));
    }

    function selectwinner() public {
        require(participants.length>=3);
        uint r = random()%participants.length;
        participants[r].transfer(getBalance());
        participants = new address payable[](0);
    }

}