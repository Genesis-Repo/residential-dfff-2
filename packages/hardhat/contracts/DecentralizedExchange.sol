// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DecentralizedExchange is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping(address => mapping(address => uint256)) public tokens; // token address => user address => token balance

    event TokensSwapped(address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    function swapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut) external nonReentrant {
        require(tokens[tokenIn][msg.sender] >= amountIn, "Insufficient balance");

        tokens[tokenIn][msg.sender] = tokens[tokenIn][msg.sender].sub(amountIn);
        tokens[tokenOut][msg.sender] = tokens[tokenOut][msg.sender].add(amountOut);

        emit TokensSwapped(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    function deposit(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);
    }

    function withdraw(address token, uint256 amount) external {
        require(tokens[token][msg.sender] >= amount, "Insufficient balance");

        tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function getTokenBalance(address token, address user) external view returns (uint256) {
        return tokens[token][user];
    }
}