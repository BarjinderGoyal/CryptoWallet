//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "./Controller/CompoundErc20.sol";
// import "./Controller/CompoundEth.sol";

contract CoreWallet {
    address payable owner;

    event WalletCreated(address user, uint256 timestamp);
    event WallerOwnerIsChanged(
        address oldUser,
        address newUser,
        uint256 timestamp
    );
    event DepositEth(address user, uint256 amount, uint256 timestamp);
    event WithdrawEth(address user, uint256 amount, uint256 timestamp);
    event DepositErc20Token(
        address user,
        address erc20Add,
        uint256 amount,
        uint256 timestamp
    );
    event WithdrawErc20Token(
        address user,
        address erc20Add,
        uint256 amount,
        uint256 timestamp
    );
    event TransferEthToOther(
        address user,
        address to,
        uint256 amount,
        uint256 timestamp
    );
    event TransferErc20ToOther(
        address user,
        address to,
        address erc20Add,
        uint256 amount,
        uint256 timestamp
    );

    modifier OnlyOwner(address user) {
        require(user == owner, "Invalid Owner");
        _;
    }

    modifier OnlyOnce() {
        require(owner == address(0x00), "This wallet is already initialize");
        _;
    }

    function initialize(address user) external OnlyOnce {
        owner = payable(user);
        emit WalletCreated(user, block.timestamp);
    }

    function getBalance(address user)
        external
        view
        OnlyOwner(user)
        returns (uint256)
    {
        return address(this).balance;
    }

    function depositEth(address user, uint256 amount)
        external
        payable
        OnlyOwner(user)
    {
        emit DepositEth(user, amount, block.timestamp);
    }

    function withdrawEth(address user, uint256 value) external OnlyOwner(user) {
        uint256 balance = address(this).balance;
        require(value <= balance, "Insufficient Amount");
        owner.transfer(value);
        emit WithdrawEth(user, value, block.timestamp);
    }

    function transferEthTo(
        address user,
        address receiver,
        uint256 value
    ) external OnlyOwner(user) {
        uint256 balance = address(this).balance;
        require(value <= balance, "Insufficient Amount");
        payable(receiver).transfer(value);

        emit TransferEthToOther(user, receiver, value, block.timestamp);
    }

    function getErc20Balance(address user, address erc20Add)
        external
        view
        OnlyOwner(user)
        returns (uint256)
    {
        uint256 balance = IERC20(erc20Add).balanceOf(user);
        return balance;
    }

    function withdrawErc20(
        address user,
        address erc20Add,
        uint256 value
    ) external OnlyOwner(user) {
        uint256 balance = IERC20(erc20Add).balanceOf(user);
        require(balance >= value, "Insufficient Balance");
        IERC20(erc20Add).transfer(user, value);

        emit WithdrawErc20Token(user, erc20Add, value, block.timestamp);
    }

    function transferErc20To(
        address user,
        address erc20Add,
        address receiver,
        uint256 value
    ) external OnlyOwner(user) {
        uint256 balance = IERC20(erc20Add).balanceOf(user);
        require(balance >= value, "Insufficient Balance");
        IERC20(erc20Add).transfer(receiver, value);

        emit TransferErc20ToOther(
            user,
            receiver,
            erc20Add,
            value,
            block.timestamp
        );
    }

    function depositErc20(
        address user,
        address erc20Add,
        uint256 value
    ) external OnlyOwner(user) {
        IERC20(erc20Add).approve(address(this), value);
        require(
            IERC20(erc20Add).allowance(msg.sender, address(this)) >= value,
            "Amount is not Allowed To Add To Wallet"
        );
        IERC20(erc20Add).transferFrom(user, address(this), value);

        emit DepositErc20Token(user, erc20Add, value, block.timestamp);
    }

    function transferOwnerShip(address user, address to)
        external
        OnlyOwner(user)
    {
        owner = payable(to);
        emit WallerOwnerIsChanged(user, to, block.timestamp);
    }
}
