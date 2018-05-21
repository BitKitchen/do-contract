pragma solidity ^0.4.23;


contract Logger {

    event LogString(uint time, string msg, string value);
    event LogAddress(uint time, string msg, address value);
    event LogUint(uint time, string msg, uint value);

    constructor() public {

    }

    function log(string message) public {
        emit LogString(now, message, "");
    }

    function logString(string message, string value) public {
        emit LogString(now, message, value);
    }

    function logAddress(string message, address value) public {
        emit LogAddress(now, message, value);
    }

    function logUint(string message, uint value) public {
        emit LogUint(now, message, value);
    }
}
