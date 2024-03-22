// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "hardhat/console.sol";

contract Deposit {

    struct User {
        mapping(address => uint) fundAllocation;
        uint prefUnit;
    }

    User user;

    function receiveFunds() payable external {
        user.fundAllocation[msg.sender] = user.fundAllocation[msg.sender] + msg.value;
        if (user.prefUnit <= 1) {
            console.log("Contract has received %s wei from your address; your current balance is %s wei.", msg.value, user.fundAllocation[msg.sender]);
        } else if (user.prefUnit == 3) {
            console.log("Contract has received %s kwei from your address, or %s wei; your current balance is %s kwei.", msg.value / 1000,  user.fundAllocation[msg.sender] / 1000);
        } else if (user.prefUnit == 6) {
            console.log("Contract has received %s mwei from your address, or %s wei; your current balance is %s mwei.", msg.value / 1000000, user.fundAllocation[msg.sender] / 1000000);
        } else if (user.prefUnit == 9) {
            console.log("Contract has received %s gwei from your address, or %s wei; your current balance is %s gwei.", msg.value / 1000000000, user.fundAllocation[msg.sender] / 10000000000);
        } else if (user.prefUnit == 12) {
            console.log("Contract has received %s szabo, or microether, from your address, or %s wei; your current balance is %s szabo.", msg.value / 1000000000000, user.fundAllocation[msg.sender] / 10000000000000);
        } else if (user.prefUnit == 15) {
            console.log("Contract has received %s finney, or milliether, from your address, or %s ; your current balance is %s finney.", msg.value / 1000000000000000, user.fundAllocation[msg.sender] / 10000000000000000);
        } else if (user.prefUnit == 18) {
            console.log("Contract has received %s ether from your address, or %s wei; your current balance is %s ether.", msg.value / 1000000000000000000, user.fundAllocation[msg.sender] / 10000000000000000000);
        }
    }

    function setPreferredUnitDisplay(string memory _unit) public returns (uint) {
        user.prefUnit = getUnitExponent(bytes(_unit));
        return user.prefUnit;
    }

    function withdrawFundsToSender(uint funds, string memory unit) payable external {
        uint weiFunds = convertUnits(funds, removeSpacesLowerCase(bytes(unit)));
        uint unitExp = getUnitExponent(bytes(unit));
        if (checkFundsSender(weiFunds, unitExp) && weiFunds != 0) {
            payable(msg.sender).transfer(weiFunds);
            user.fundAllocation[msg.sender] = user.fundAllocation[msg.sender] - weiFunds;
            getBalanceSender(unitExp);
        }
    }

    function withdrawFundsToExtAddress(address payable _addr, uint funds, string memory unit) payable external {
        uint weiFunds = convertUnits(funds, removeSpacesLowerCase(bytes(unit)));
        uint unitExp = getUnitExponent(bytes(unit));
        if (checkFundsSenderExt(weiFunds, unitExp, _addr) && weiFunds != 0) {
            payable(_addr).transfer(weiFunds);
            user.fundAllocation[msg.sender] = user.fundAllocation[msg.sender] - weiFunds;
            getBalanceSender(unitExp);
        }
    }

    function getBalanceSender() view public returns (uint) {
        if (user.prefUnit <= 1) {
            console.log("You, or %s, have a balance of %s wei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender]));
        } else if (user.prefUnit == 3) {
            console.log("You, or %s, have a balance of %s wei, or %s kwei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000));
        } else if (user.prefUnit == 6) {
            console.log("You, or %s, have a balance of %s wei, or %s mwei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000));
        } else if (user.prefUnit == 9) {
            console.log("You, or %s, have a balance of %s wei, or %s gwei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000));
        } else if (user.prefUnit == 12) {
            console.log("You, or %s, have a balance of %s wei, or %s szabo, or microether.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000000));
        } else if (user.prefUnit == 15) {
            console.log("You, or %s, have a balance of %s wei, or %s finney, or milliether.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000000000));
        } else if (user.prefUnit == 18) {
            console.log("You, or %s, have a balance of %s wei, or %s ether.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000000000000));
        }
        return user.fundAllocation[msg.sender];
    }

    function getBalanceSender(uint unit) view internal returns (uint) {
        if (unit <= 1) {
            console.log("You, or %s, have a balance of %s wei.", msg.sender, user.fundAllocation[msg.sender]);
        } else if (unit == 3) {
            console.log("You, or %s, have a balance of %s wei, or %s kwei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000));
        } else if (unit == 6) {
            console.log("You, or %s, have a balance of %s wei, or %s mwei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000));
        } else if (unit == 9) {
            console.log("You, or %s, have a balance of %s wei, or %s gwei.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000));
        } else if (unit == 12) {
            console.log("You, or %s, have a balance of %s wei, or %s szabo, or microether.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000000));
        } else if (unit == 15) {
            console.log("You, or %s, have a balance of %s wei, or %s finney, or milliether.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000000000));
        } else if (unit == 18) {
            console.log("You, or %s, have a balance of %s wei, or %s ether.", msg.sender, user.fundAllocation[msg.sender], (user.fundAllocation[msg.sender] / 1000000000000000000));
        }
        return user.fundAllocation[msg.sender];
    }

    function checkFundsSender(uint funds, uint unitExp) view internal returns (bool) {
        if (funds <= user.fundAllocation[msg.sender]) {
            if (unitExp <= 1) {
                console.log("The address %s is requesting %s wei, and its request will be granted.", msg.sender, funds);
            } else if (unitExp == 3) {
                console.log("The address %s is requesting %s kwei, and its request will be granted.", msg.sender, (funds / 1000));
            } else if (unitExp == 6) {
                console.log("The address %s is requesting %s mwei, and its request will be granted.", msg.sender, (funds / 1000000));
            } else if (unitExp == 9) {
                console.log("The address %s is requesting %s gwei, and its request will be granted.", msg.sender, (funds / 1000000000));
            } else if (unitExp == 12) {
                console.log("The address %s is requesting %s szabo, or microether, and its request will be granted.", msg.sender, (funds / 1000000000000));
            } else if (unitExp == 15) {
                console.log("The address %s is requesting %s finney, or milliether, and its request will be granted.", msg.sender, (funds / 1000000000000000));
            } else if (unitExp == 18) {
                console.log("The address %s is requesting %s ether, and its request will be granted.", msg.sender, (funds / 1000000000000000000));
            }
            return true; 
        } else {
            if (unitExp <= 1) {
                console.log("The address %s is requesting %s wei, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, funds, user.fundAllocation[msg.sender]);
            } else if (unitExp == 3) {
                console.log("The address %s is requesting %s kwei, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, (funds / 1000), user.fundAllocation[msg.sender]);
            } else if (unitExp == 6) {
                console.log("The address %s is requesting %s mwei, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, (funds / 1000000), user.fundAllocation[msg.sender]);
            } else if (unitExp == 9) {
                console.log("The address %s is requesting %s gwei, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, (funds / 1000000000), user.fundAllocation[msg.sender]);
            } else if (unitExp == 12) {
                console.log("The address %s is requesting %s szabo, or microether, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, (funds / 1000000000000), user.fundAllocation[msg.sender]);
            } else if (unitExp == 15) {
                console.log("The address %s is requesting %s finney, or microether, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, (funds / 1000000000000000), user.fundAllocation[msg.sender]);
            } else if (unitExp == 18) {
                console.log("The address %s is requesting %s ether, and its request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", msg.sender, (funds / 1000000000000000000), user.fundAllocation[msg.sender]);
            }
            return false;
        }
    }

    function checkFundsSenderExt(uint funds, uint unitExp, address _addr) view internal returns (bool) {
        if (funds <= user.fundAllocation[msg.sender]) {
            if (unitExp <= 1) {
                console.log("You are requesting %s wei to be be sent to %s, and your request will be granted.", funds, _addr);
            } else if (unitExp == 3) {
                console.log("You are requesting %s kwei to be be sent to %s, and your request will be granted.", (funds / 1000), _addr);
            } else if (unitExp == 6) {
                console.log("You are requesting %s mwei to be be sent to %s, and your request will be granted.", (funds / 1000000), _addr);
            } else if (unitExp == 9) {
                console.log("You are requesting %s gwei to be be sent to %s, and your request will be granted.", (funds / 1000000000), _addr);
            } else if (unitExp == 12) {
                console.log("You are requesting %s szabo to be be sent to %s, or microether, and your request will be granted.", (funds / 1000000000000), _addr);
            } else if (unitExp == 15) {
                console.log("You are requesting %s finney to be be sent to %s, or milliether, and your request will be granted.", (funds / 1000000000000000), _addr);
            } else if (unitExp == 18) {
                console.log("You are requesting %s ether, and your request will be granted.", (funds / 1000000000000000000), _addr);
            }
            return true; 
        } else {
            if (unitExp <= 1) {
                console.log("You are requesting %s wei to be sent to %s, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", funds, _addr, user.fundAllocation[msg.sender]);
            } else if (unitExp == 3) {
                console.log("You are requesting %s kwei to be sent to %s, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", (funds / 1000), _addr, user.fundAllocation[msg.sender]);
            } else if (unitExp == 6) {
                console.log("You are requesting %s mwei to be sent to %s, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", (funds / 1000000), _addr, user.fundAllocation[msg.sender]);
            } else if (unitExp == 9) {
                console.log("You are requesting %s gwei to be sent to %s, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", (funds / 1000000000), _addr, user.fundAllocation[msg.sender]);
            } else if (unitExp == 12) {
                console.log("You are requesting %s szabo to be sent to %s, or microether, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", (funds / 1000000000000), _addr, user.fundAllocation[msg.sender]);
            } else if (unitExp == 15) {
                console.log("You are is requesting %s finney, or microether, to be sent to %s, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", (funds / 1000000000000000), _addr, user.fundAllocation[msg.sender]);
            } else if (unitExp == 18) {
                console.log("You are is requesting %s ether to be sent to %s, and your request will be rejected, as the amount is greater than the amount the contract can allocate for you, %s wei.", (funds / 1000000000000000000),_addr, user.fundAllocation[msg.sender]);
            }
            return false;
        }
    }

    function getUnitExponent(bytes memory unit) pure internal returns (uint) {
        bytes10 unitFormatted = bytes10(removeSpacesLowerCase(unit));
        if (unitFormatted == "wei") {
            return 0;
        } else if (unitFormatted == "kwei" || unitFormatted == "babbage") {
            return 3;
        } else if (unitFormatted == "mwei" || unitFormatted == "lovelace" || unitFormatted == "ada" || unitFormatted == "femto" || unitFormatted == "femtoeth" || unitFormatted == "femtoether") {
            return 6;
        } else if (unitFormatted == "gwei" || unitFormatted == "shannon" || unitFormatted == "pico" || unitFormatted == "picoeth" || unitFormatted == "picoether") {
            return 9;
        } else if (unitFormatted == "micro" || unitFormatted == "szabo" || unitFormatted == "microeth" || unitFormatted == "microether" || unitFormatted == "nano" || unitFormatted == "nanoeth" || unitFormatted == "nanoether") {
            return 12;    
        } else if (unitFormatted == "milli" || unitFormatted == "finney" || unitFormatted == "millieth" || unitFormatted == "millether") {
            return 15;       
        } else if (unitFormatted == "ether" || unitFormatted == "eth" || unitFormatted == "ethereum") {
            return 18;      
        } else {
            return 1;
        }
    }
    
    function convertUnits(uint funds, bytes memory unit) pure internal returns (uint) {
        uint unitExp = getUnitExponent(unit);
        if (unitExp != 1) {
            return funds * (10 ** unitExp);
        } else {
            return 0;
        }
    }

    function toLowerCase(bytes memory _str) pure internal returns (bytes memory) {
        bytes memory str = _str;
        for (uint i = 0; i < str.length; ++i) {
            if (uint8(str[i]) >= 65 && uint8(str[i]) <= 90) {
                str[i] = bytes1(uint8(str[i]) + 32);  
            }
        }
        return str;
    }

    function removeSpacesLowerCase(bytes memory _str) pure internal returns (bytes memory) {
        uint spaceCounter = 0;
        for (uint i = 0; i < _str.length; ++i) {
            if (uint8(_str[i]) <= 65 || uint8(_str[i]) >= 122) {
                if (uint8(_str[i]) == 0x20 || uint8(_str[i]) == 0x09 || uint8(_str[i]) == 0x0a || uint8(_str[i]) == 0x0D || uint8(_str[i]) == 0x0B || uint8(_str[i]) == 0x00) {
                    ++spaceCounter;
                }
            }
        }

        bytes memory output = new bytes(_str.length - spaceCounter);
        spaceCounter = 0;
        for (uint i = 0; i < _str.length; ++i) {
            if (uint8(_str[i]) <= 65 || uint8(_str[i]) >= 122) {
                if (uint8(_str[i]) == 0x20 || uint8(_str[i]) == 0x09 || uint8(_str[i]) == 0x0a || uint8(_str[i]) == 0x0D || uint8(_str[i]) == 0x0B || uint8(_str[i]) == 0x00) {
                    // do nothing
                } else {
                    output[spaceCounter] = _str[i];
                    spaceCounter++;
                }
            } else {
                output[spaceCounter] = _str[i];
                spaceCounter++;
            }
        }
        
        return toLowerCase(output);
    }
  
}

// public: all contracts may access
// external: only external contracts may access
// internal: only this contract and sub-contracts may access
// private only this contracct may access
// pure: no state nor local data will be read nor changed
// view: no state nor local data will be changed
// address: an ethereum "account" to which funds may be stored
// mapping: a ethereum-ized version of a hashmap with keccak256 hashes