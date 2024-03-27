// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract BOSSToken is ERC20Upgradeable, ReentrancyGuardUpgradeable {
    using Address for address payable;
    using SafeMathUpgradeable for uint256;

    // Place to store swap fees that were previously failed to distribute and will be automatically distributed next.
    uint256 public feePool;

    uint256 private TOTAL_SUPPLY;
    uint256 private LIQUIDITY_ALOCATION;
    uint256 private MAX_SWAP_AMOUNT;

    // Toggles for enabling and disabling swap fees
    bool public enabledSwapFee;
    uint256 private countSwapInteractions;

    // Arrays to store token pairs and keys
    address[] public tokenPairKeys;
    mapping(address => address) public tokenPairs;

    // Marketing and team wallet addresses
    address public marketingAddress;
    address public teamAddress;

    // Public variables for the token
    // Uniswap router, factory and weth addresses
    IUniswapV2Router02 public uniswapRouter;
    address public uniswapFactory;
    address private bether;

    // Role management mapping
    mapping(bytes32 => mapping(address => bool)) private roles;

    // Event declarations for role creation and role removal
    event RoleCreated(bytes32 role, address indexed account);
    event RoleRemoved(bytes32 role, address indexed account);

    // Event declarations for interaction with Uniswap
    event SwapFeeEnabled(address indexed account);
    event FeesDistributed(uint256 indexed distributedAmount);
    event WhaleSwapped(address indexed from, address indexed to, uint256 amount);

    /**
     * @dev     Modifier to restrict access to specific roles, ensuring only authorized accounts can execute the function.
     * @param   role  Role to be checked
     */
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "Unauthorized");
        _;
    }

    /**
     * @dev     Initializes the contract.
     * @param   _router  Router address.
     */
    function initialize(address _router) initializer public {
        TOTAL_SUPPLY = 10 ** 9 * 10**decimals();
        LIQUIDITY_ALOCATION  = TOTAL_SUPPLY.mul(25).div(100);
        MAX_SWAP_AMOUNT = LIQUIDITY_ALOCATION.div(2);
        countSwapInteractions = 0;
        enabledSwapFee = false;
        __ERC20_init("Birds of Space", "BOSS");
        roles[keccak256("ADMIN")][msg.sender] = true;
        emit RoleCreated(keccak256("ADMIN"), msg.sender);
        _mint(address(this), TOTAL_SUPPLY);
        uniswapRouter = IUniswapV2Router02(_router);
        uniswapFactory = uniswapRouter.factory();
        bether = uniswapRouter.WETH();
        address pairAddress = IUniswapV2Factory(uniswapFactory).createPair(address(this), uniswapRouter.WETH());
        tokenPairs[address(this)] = pairAddress;
        tokenPairKeys.push(address(this));
    }

    /**
     * @dev Checks if the account is a contract.
     * @param _account Address of the account to check.
     * @return True if the account is a contract, false otherwise.
     */
    function isContract(address _account) public view returns (bool) {
        bytes32 codehash;
        bytes32 zeroHash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        assembly {
            codehash := extcodehash(_account)
        }
        return codehash != zeroHash;
    }

    /**
     * @dev Mints the specified amount of tokens to the recipient address.
     * @param _to The address of the recipient.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) public onlyRole(keccak256("MINTER")) {
        super._transfer(address(this), _to, _amount);
    }

    /**
     * @notice  Enable when liquidity is sufficient.
     * @dev     Enables or disables the swap fee.
     * @param   _enabled  Boolean value to enable or disable the swap fee.
     */
    function toggleSwapFee(bool _enabled) external onlyRole(keccak256("ADMIN")) {
        enabledSwapFee = _enabled;
    }
    
    /**
     * @dev     Creates a new role.
     * @param   role  User role type to be created.
     * @param   account  Address of the account that will be given the role.
     */
    function createRole(bytes32 role, address account) external onlyRole(keccak256("ADMIN")) {
        require(account != address(0), "Invalid account address");
        require(!hasRole(role, account), "Role already exists");

        roles[role][account] = true;
        emit RoleCreated(role, account);
    }

    /**
     * @dev     Removes a role.
     * @param   role  User role type to be removed.
     * @param   account  Account address to be removed from the role.
     */
    function removeRole(bytes32 role, address account) external onlyRole(keccak256("ADMIN")) {
        require(hasRole(role, account), "Role does not exist");
        roles[role][account] = false;
        emit RoleRemoved(role, account);
    }

    /**
     * @dev     Checks if an account has a role.
     * @param   role  Role to be checked.
     * @param   account  Specific account address to be checked.
     * @return  bool  Whether the account has the role or not.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return roles[role][account];
    }

    /**
     * @dev     Create a new UniswapV2 pair for trading, requiring the address of the token pair to be provided.
     * @param   tokenPair  Token pair address.
     */
    function createPair(address tokenPair) external onlyRole(keccak256("ADMIN")) {
        IUniswapV2Factory factory = IUniswapV2Factory(uniswapFactory);
        address pairAddress = factory.createPair(address(this), tokenPair);
        tokenPairs[tokenPair] = pairAddress;
        tokenPairKeys.push(tokenPair);
    }

    /**
     * @dev     Sets the marketing wallet address.
     * @param   _marketingAddress  The new address for the marketing wallet.
     */
    function setMarketingAddress(address _marketingAddress) external onlyRole(keccak256("ADMIN")) {
        require(_marketingAddress != address(0), "Invalid address");
        marketingAddress = _marketingAddress;
    }

    /**
     * @dev     Only the admin can call this function.
     * @param   _teamAddress  The new address for the team wallet.
     */
    function setTeamAddress(address _teamAddress) external onlyRole(keccak256("ADMIN")) {
        require(_teamAddress != address(0), "Invalid address");
        teamAddress = _teamAddress;
    }

    /**
    * @dev Checks if the address belongs to a liquidity pool.
    * @param _from Address of the sender.
    * @param _to Address of the recipient.
    */
    function isLiquidityPool(address _from, address _to) internal view returns (bool) {
        bool isFromPool = false;
        bool isToPool = false;

        for (uint256 i = 0; i < tokenPairKeys.length; i++) {
            address targetPair = tokenPairs[tokenPairKeys[i]];

            if (_from == targetPair) {
                isFromPool = true; // Address is a liquidity pool
            }
            if (_to == targetPair) {
                isToPool = true; // Address is a liquidity pool
            }

            // Early exit if both from and to addresses are determined as liquidity pools
            if (isFromPool && isToPool) {
                break;
            }
        }

        // Return true if either from or to address is a liquidity pool
        return isFromPool || isToPool;
    }

    /**
     * @dev     Internal function for transferring tokens including fee calculation and distribution if applicable.
     * @param   _from  Source address.
     * @param   _to  The recipient address.
     * @param   _amount  Value to be transferred.
     */
    function _transfer(address _from, address _to, uint256 _amount) internal virtual override {
        if (_from == address(this) || !enabledSwapFee) {
            _transferNoFee(_from, _to, _amount);
            if (countSwapInteractions == 0) {
                enabledSwapFee = true;
                countSwapInteractions += 1;
            }
        } else {
            _transferWithFee(_from, _to, _amount);
            countSwapInteractions += 1;
        }
    }

    /**
     * @dev Internal function for transferring tokens without fee calculation and distribution if applicable.
     * @param _from Sender address.
     * @param _to Recipient address.
     * @param _amount Amount of tokens to be transferred.
     */
    function _transferNoFee(address _from, address _to, uint256 _amount) private {
        super._transfer(_from, _to, _amount);
    }

    /**
     * @dev Internal function for transferring tokens with fee calculation and distribution if applicable.
     * @param _from Sender address.
     * @param _to Recipient address.
     * @param _amount Amount of tokens to be transferred.
     */
    function _transferWithFee(address _from, address _to, uint256 _amount) private {
        require(_amount <= MAX_SWAP_AMOUNT, "Swap amount exceeds maximum");
        bool takeFee = isLiquidityPool(_from, _to);
        if (takeFee) {
            uint256 fee = (_amount * 3) / 100; // 3% fee
            uint256 amt = _amount - fee;
            if(_distributeFees(fee)) {
                if(_amount >= (TOTAL_SUPPLY * 1)/100) {
                    emit WhaleSwapped(_from, _to, _amount);
                }
                super._transfer(_from, address(this), fee);
                super._transfer(_from, _to, amt);
            } else {
                super._transfer(_from, _to, _amount);
            }
        } else {
            super._transfer(_from, _to, _amount);
        }
    }

    /**
     * @dev      Internal function for distributing collected fees
     * @param   _fee  Amount of fees to be distributed.
     */
    function _distributeFees(uint256 _fee) internal nonReentrant returns(bool result){
        if (_fee > 0 && _fee <= balanceOf(address(this))) {
            uint256 initialBalance = address(this).balance;
            uint256 currentBalance = _swapTokensForETH(address(this), _fee, address(uniswapRouter));
            if(currentBalance == initialBalance) {
                result = false;
            } else {
                uint256 newBalance = currentBalance - initialBalance;
                uint256 marketingFee = (newBalance * 2) / 3;
                uint256 teamFee = newBalance - marketingFee;
        
                payable(teamAddress).transfer(teamFee);
                payable(marketingAddress).transfer(marketingFee);
                result = true;
            }
            return result;
        }
    }
    

    /**
     * @dev Swap tokens for ETH.
     * @param tokenIn Address of the token to be swapped.
     * @param amountTokenIn Amount of tokens to be swapped.
     * @param router Address of the router.
     */
    function _swapTokensForETH(address tokenIn, uint256 amountTokenIn, address router) internal returns(uint256) {
        // Approve the router to spend the tokenIn and the accumulated feePool amount
        IERC20(tokenIn).approve(router, amountTokenIn.add(feePool));
        uint256 allowedAmount = IERC20(tokenIn).allowance(address(this), router);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = IUniswapV2Router02(router).WETH(); 

        try IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            allowedAmount,
            0,
            path,
            address(this),
            block.timestamp
        )
        {
            // Set the fee pool to 0 if the swap is successful
            feePool = 0;
            //get the ETHBalance of the contract
            uint256 ETHBalance = address(this).balance;
            emit FeesDistributed(ETHBalance);
            return ETHBalance;
        }
        catch {
            // Add the fee amount to the fee pool if the swap fails
            feePool.add(amountTokenIn);
            uint256 ETHBalance = address(this).balance;
            return ETHBalance;
        }
    }

    /**
     * @dev     Admin allows to withdraw ether from the contract.
     */
    function reallocationEther() public onlyRole(keccak256("ADMIN")){
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    } 

    fallback() external payable {}

    receive() external payable {}
}