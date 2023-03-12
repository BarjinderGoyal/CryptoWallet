//SPDX-License-Identifier:MIT

pragma solidity ^0.8;

import "./CoreWallet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract factory {
    address public factoryOwner;
    address public coreWalletAddress;
    mapping(address => address) public userWalletAddress;

    constructor(address _coreWalletAddress) {
        factoryOwner = msg.sender;
        coreWalletAddress = _coreWalletAddress;
    }

    modifier OnlyOwner() {
        require(msg.sender == factoryOwner, "You are not the Owner");
        _;
    }

    function setCoreWalletAddress(address _wallet) public OnlyOwner {
        coreWalletAddress = _wallet;
    }

    function getCoreWalletAddress() internal view returns (address) {
        return coreWalletAddress;
    }

    function createWallet(address user) external {
        bytes20 targetBytes = bytes20(getCoreWalletAddress());
        uint256 salt = uint256(
            bytes32(
                keccak256(
                    abi.encode(msg.sender, address(this), block.timestamp)
                )
            )
        );
        address result;
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create2(0, clone, 0x37, salt)
        }
        userWalletAddress[user] = result;
        CoreWallet(result).initialize(user);
    }
}
