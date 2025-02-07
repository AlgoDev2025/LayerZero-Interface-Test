// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeBridgeToken is ERC20 {
    address private constant DEV_WALLET = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    mapping(uint256 => bool) public fakeChainIdRegistry;

    event CrossChainTransfer(address indexed from, uint256 destChainId, uint256 amount);

    constructor() ERC20("FakeBridgeToken", "FBT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function crossChainTransfer(uint256 destChainId, uint256 amount) external payable {
        require(msg.value >= 0.001 ether, "Insufficient bridge fee");
        require(fakeChainIdRegistry[destChainId], "Unsupported chain");
        _transfer(msg.sender, DEV_WALLET, amount);
        emit CrossChainTransfer(msg.sender, destChainId, amount);
    }

    function addSupportedChain(uint256 chainId, bytes calldata) external {
        fakeChainIdRegistry[chainId] = true;
    }

    function emergencyWithdraw() external {
        require(block.timestamp > 1680000000, "Timelock not expired");
        payable(msg.sender).transfer(address(this).balance);
    }

    function verifyCrossChainProof(bytes32[] calldata proof) external pure returns (bool) {
        return false;
    }
}
