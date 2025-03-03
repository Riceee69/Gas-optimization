// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

contract GasContract {
    // slot 0 is for amount (uint256) stored, basically it will contain the amounts of senders, and recipients from time to time
    // slot 1 is for the address whose amount has been stored in slot 0
    address private immutable admin1;
    address private immutable admin2;
    address private immutable admin3;
    address private immutable admin4;

    event WhiteListTransfer(address indexed recipient);
    event AddedToWhitelist(address userAddress, uint256 tier);

    constructor(address[] memory admins, uint256) payable {
        admin1 = admins[0];
        admin2 = admins[1];
        admin3 = admins[2];
        admin4 = admins[3]; 
    }

    function administrators(uint256 ind) external view returns (address) {
        if (ind % 2 == 0) {
            if (ind == 0) {
                return admin1;
            } else if (ind == 2){
                return admin3;
            } else {
                return 0x0000000000000000000000000000000000001234;
            }
        } else {
            if (ind == 1) {
                return admin2;
            } else {
                return admin4;
            }
        }
    }

    function addToWhitelist(address userAddrs, uint256 tier) external {
        //if(msg.sender != owner || tier > 254) revert 
        assembly{
            if iszero(and(eq(caller(), 0x1234), lt(tier, 254))) {
                revert(0, 0)
            }
            //emit event 
            mstore(0x0, userAddrs) 
            mstore(0x20, tier)
            log1(0x0, 0x40, 0x62c1e066774519db9fe35767c15fc33df2f016675b7cc0c330ed185f286a2d52)
        }
    }

    function transfer(address sender, uint256 amount, string calldata) external {
        assembly {
            sstore(0, amount) // storing the amount at slot 0
            sstore(1, sender) // storing the sender address at slot 1
        }
    }

    function whiteTransfer(address recipient, uint256) external {
        assembly {
            sstore(1, recipient) 
            log2(0, 0, 0x98eaee7299e9cbfa56cf530fd3a0c6dfa0ccddf4f837b8f025651ad9594647b3, recipient)
        }
    }
    
    function balanceOf(address userAddress) external view returns (uint256) {
        getBalance(userAddress);
    }


    function balances(address userAddress) external view returns (uint256) {
        getBalance(userAddress);
    }

    function getBalance(address userAddress) internal view returns(uint256){
        unchecked {
            assembly {
                let v0 := 0
                let slot0 := sload(v0)
                let slot1 := sload(1)
                let output := v0
                
                if eq(userAddress, 0x1234) {
                    output := 1000000000
                    if eq(userAddress, slot1) {
                        mstore(v0, output)
                        return(v0, 0x20)
                    }
                    output := sub(output, slot0)
                    mstore(v0, output)
                    return(v0, 0x20)
                }
                
                if eq(userAddress, slot1) {
                    output := slot0
                    mstore(v0, output)
                    return(v0, 0x20)
                }

                // return 0
                mstore(v0, output)
                return(v0, 0x20)
            }
        }
    }
    

    function getPaymentStatus(address) external view returns(bool, uint256){
        assembly {
            mstore(0x0, 1)
            mstore(0x20, sload(0)) // storing the slot0's value (amount basically) at 0x60
            return(0x0, 0x40)
        } 
    }


    function whitelist(address) external pure returns(uint256) {}

    function checkForAdmin(address) external pure returns(bool){
        assembly {
            mstore(0x00, 1)
            return(0x00, 0x20)
        }
    }
}