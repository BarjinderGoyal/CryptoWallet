//SPDX-License-Identifier:MIT

pragma solidity ^0.8;
import "./Factory.sol";
import "./CoreWallet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract wallet {
    address factoryAddress;
    address Factory;
    address[] public tokens;
    mapping(address => bool) public tokenIsExist;

    constructor(address _factoryAddress) {
        factoryAddress = _factoryAddress;
        Factory = factory(factoryAddress).factoryOwner();
        tokens.push(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //chainlink
        tokens.push(0x5010abCF8A1fbE56c096DCE9Bb2D29d63e141361); //aave
        tokens.push(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95); //bg
        tokens.push(0x9ecEA68DE55F316B702f27eE389D10C2EE0dde84); //rg
    }

    modifier OnlyOwner() {
        require(msg.sender == Factory, "You are not the onwer");
        _;
    }

    function addERC20TokenToWallet(address erc20) public OnlyOwner {
        require(tokenIsExist[erc20] == false, "Token is already exist");
        tokenIsExist[erc20] = true;
        tokens.push(erc20);
    }

    function CreateWallet() public {
        factory(factoryAddress).createWallet(msg.sender);
    }

    function depositEth() public payable {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        //   wallet(walletAddress).depositEth(msg.sender,msg.value);
        bytes4 func = bytes4(keccak256(bytes("depositEth(address,uint256)")));
        (bool sucess, ) = address(walletAddress).call{value: msg.value}(
            abi.encodeWithSelector(func, msg.sender, msg.value)
        );
        require(sucess, "Please try after sometime");
    }

    function depositErc20(address erc20, uint256 value) public {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        uint256 balance = IERC20(erc20).balanceOf(msg.sender);
        require(balance >= value, "Insufficient balance");
        require(
            IERC20(erc20).allowance(msg.sender, address(this)) >= value,
            "Amount is not Allowed To Add To Wallet"
        );
        IERC20(erc20).transferFrom(msg.sender, address(this), value);
        IERC20(erc20).approve(walletAddress, value);
        IERC20(erc20).transfer(walletAddress, value);
        CoreWallet(walletAddress).depositErc20(msg.sender, erc20, value);
    }

    function withdrawEth(uint256 value) public {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        CoreWallet(walletAddress).withdrawEth(msg.sender, value);
    }

    function transferEthTo(address to, uint256 value) public {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        CoreWallet(walletAddress).transferEthTo(msg.sender, to, value);
    }

    function withdrawErc20(address erc20, uint256 value) public {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        CoreWallet(walletAddress).withdrawErc20(msg.sender, erc20, value);
    }

    function transferErc20To(
        address erc20,
        address to,
        uint256 value
    ) public {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        CoreWallet(walletAddress).transferErc20To(msg.sender, erc20, to, value);
    }

    function getErc20Balance(address erc20)
        public
        view
        returns (uint256 balance)
    {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        balance = CoreWallet(walletAddress).getErc20Balance(msg.sender, erc20);
    }

    function getEthBalance() public view returns (uint256 balance) {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        balance = CoreWallet(walletAddress).getBalance(msg.sender);
    }

    function transferOwnerShip(address to) public {
        address walletAddress = factory(factoryAddress).userWalletAddress(
            msg.sender
        );
        require(walletAddress != address(0x00), "You don't have any wallet");
        CoreWallet(walletAddress).transferOwnerShip(msg.sender, to);
    }

    function getTokensName()
        public
        view
        returns (string[] memory, string[] memory)
    {
        address[] memory _tokens = tokens;
        string[] memory name = new string[](_tokens.length);
        string[] memory symbol = new string[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            name[i] = ERC20(_tokens[i]).name();
            symbol[i] = ERC20(_tokens[i]).symbol();
        }
        return (name, symbol);
    }

    function updateFactoryAddress(address _factoryAddress) public OnlyOwner {
        factoryAddress = _factoryAddress;
    }
}
