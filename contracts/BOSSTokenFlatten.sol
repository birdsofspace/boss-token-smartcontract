// Sources flattened with hardhat v2.22.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol@v1.1.0-beta.0

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol@v1.1.0-beta.0

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}


// File @uniswap/v2-core/contracts/interfaces/IERC20.sol@v1.0.1

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


// File @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol@v1.0.1

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// File contracts/BOSSToken.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.17;
/**
 * @author  Birds of Space
 * @title   BOSS Token contract
 * @dev     This contract is the main token contract of the project.
 */

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract BOSSToken is Initializable {

    bool private isDevelopmentUsingProxy;

    bool public autoSale;
    uint256 public priceTokenAutoSale;

    // Public variables for the token
    // Uniswap router and factory addresses
    IUniswapV2Router02 public uniswapRouter;
    address public uniswapFactory;

    // Marketing and team wallet addresses
    address public marketingAddress;
    address public teamAddress;

    // Token properties
    string public name = "Birds of Space SpaceBirdz";
    string public symbol = "BOSS";
    uint256 public decimals = 18;
    uint256 public totalSupply;

    // Arrays to store token pairs and keys
    address[] public tokenPairKeys;
    mapping(address => address) public tokenPairs;

    // Mapping to store balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Role management mapping
    mapping(bytes32 => mapping(address => bool)) private roles;

    // Event declarations for role creation, role removal, token transfers and burns
    event RoleCreated(bytes32 role, address indexed account);
    event RoleRemoved(bytes32 role, address indexed account);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    /**
     * @dev     Modifier to restrict access to specific roles, ensuring only authorized accounts can execute the function.
     * @param   role  Role to be checked
     */
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "Unauthorized");
        _;
    }

    /**
     * @dev     The constructor function is executed only when the contract is not using a proxy.
     * @param   _router  UniswapV2 router address.
     * @param   _factory  UniswapV2 factory address.
     * @param   _isDevelopmentUsingProxy  Whether the contract is using a proxy or not.
     */
    constructor(address _router, address _factory, bool _isDevelopmentUsingProxy) {
        if (_isDevelopmentUsingProxy == false) {
            roles[keccak256("ADMIN")][msg.sender] = true;
            emit RoleCreated(keccak256("ADMIN"), msg.sender);
            isDevelopmentUsingProxy = false;
            autoSale = false;
            priceTokenAutoSale = 0;
            totalSupply = 10 ** 9 * 10**decimals;
            balanceOf[msg.sender] = totalSupply; // Give the creator all initial tokens
            uniswapRouter = IUniswapV2Router02(_router);
            uniswapFactory = _factory;
        } else {
            _disableInitializers();
        }
    }

    /**
     * @dev     Initializes the contract.
     * @param   _router  Router address.
     * @param   _factory  Factory address.
     */
    function initialize(address _router, address _factory) initializer public {
        if (isDevelopmentUsingProxy == true) {
            roles[keccak256("ADMIN")][msg.sender] = true;
            emit RoleCreated(keccak256("ADMIN"), msg.sender);
            autoSale = false;
            priceTokenAutoSale = 0;
            totalSupply = 10 ** 9 * 10**decimals;
            balanceOf[msg.sender] = totalSupply;
            uniswapRouter = IUniswapV2Router02(_router);
            uniswapFactory = _factory;
        }
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
     * @dev     Toggle the auto sale feature. When enabled, the contract automatically sells tokens to buyers according to predefined rules.
     * @param   _enabled  Whether the auto sale is enabled or not.
     */
    function toggleAutoSale(bool _enabled) public onlyRole(keccak256("ADMIN")) {
        autoSale = _enabled;
    }

    /**
     * @dev     Set the price for the auto sale feature, defining the rate at which tokens are sold during automated transactions.
     * @param   _priceInEther  In ether format of the price.
     */
    function setPriceTokenAutoSale(uint256 _priceInEther) public onlyRole(keccak256("ADMIN")) {
        require(autoSale, "Auto sale is not enabled");
        priceTokenAutoSale = _priceInEther * 1 ether;
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
     * @dev     Processing when receiving Ether.
     */
    receive() external payable {
        if (autoSale) {
            require(priceTokenAutoSale > 0, "Price must be greater than zero");
            require(msg.value > 0, "Value must be greater than zero");
            // Calculate the amount of tokens equivalent to the received Ether
            uint256 amountToken = priceTokenAutoSale * msg.value;

            // Approve router to spend tokens
            IERC20 token = IERC20(address(this));
            token.approve(address(uniswapRouter), amountToken);

            // Add liquidity using the received Ether and calculated token amount
            (uint newToken, uint newETH, uint newLiquidity) = uniswapRouter.addLiquidityETH{value: msg.value}(
                address(token),
                amountToken,
                priceTokenAutoSale,
                msg.value,
                address(this),
                block.timestamp + 3600
            );
            require(newETH == msg.value, "Incorrect amount of Ether received");
            
            // Check if liquidity was successfully added
            require(newLiquidity > 0, "Adding liquidity failed");
            // Transfer tokens back to the sender
            _transfer(address(this), msg.sender, newToken);
        }
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
     * @dev     Internal function for transferring tokens, including fee calculation and distribution, crucial for token transfers within the contract.
     * @param   _from  Source address.
     * @param   _to  The recipient address.
     * @param   _value  Value to be transferred.
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0));
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];

        bool takeFee = false;
        for (uint i = 0; i < tokenPairKeys.length; i++) {
            if (_from == tokenPairKeys[i] || _to == tokenPairKeys[i]) {
                takeFee = true;
                break; // Exit loop if pair is found
            }
        }

        // Calculate total fee
        uint256 totalFee = 0;
        if (takeFee) {
            totalFee = (_value * 3) / 100; // Total fee is 3% of the transfer amount
        }

        // Subtract total fee from transfer amount
        uint256 amountAfterFee = _value - totalFee;

        // Transfer tokens with fee deducted
        balanceOf[_from] -= _value;
        balanceOf[_to] += amountAfterFee;

       // If fee needs to be taken, transfer fee to marketing and team wallets
        if (takeFee) {
            // Calculate marketing fee (2%)
            uint256 marketingFee = (totalFee * 2) / 3;
            // Transfer marketing fee to marketing address
            balanceOf[marketingAddress] += marketingFee;
            emit Transfer(_from, marketingAddress, marketingFee);

            // Calculate team fee (1%)
            uint256 teamFee = totalFee - marketingFee;
            // Transfer team fee to team address
            balanceOf[teamAddress] += teamFee;
            emit Transfer(_from, teamAddress, teamFee);
        }

        // Emit Transfer event for the actual transfer
        emit Transfer(_from, _to, amountAfterFee);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * @dev     Transfer tokens from msg.sender to another address.
     * @param   _to  Recipient address.
     * @param   _value  Amount of tokens to be transferred.
     * @return  success  If the transfer was successful.
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev     Send `_value` tokens to `_to` in behalf of `_from`.
     * @param   _from  The address of the sender.
     * @param   _to  The address of the recipient.
     * @param   _value  Amount of tokens to be transferred
     * @return  success  If the transfer was successful
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev     The approve function is used to allow another contract to spend some tokens on your behalf.
     * @param   _spender  The address authorized to spend
     * @param   _value  Amount of tokens that can be approved
     * @return  success  If the approval was successful
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * @notice  Allow another contract to spend tokens on your behalf, notifying the recipient contract about the approval and the transferred amount.
     * @dev     Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     * @param   _spender  The address authorized to spend
     * @param   _value  the max amount they can spend
     * @param   _extraData  some extra information to send to the approved contract
     * @return  success  If the approval was successful
     */
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * @notice  Destroy tokens
     * @dev     Remove `_value` tokens from the system irreversibly
     * @param   _value  The amount of tokens to burn
     * @return  success  If burn was successful
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value); // Check if the sender has enough
        balanceOf[msg.sender] -= _value; // Subtract from the sender
        totalSupply -= _value; // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }


    /**
     * @dev     Destroy tokens dan Remove tokens from the system irreversibly on behalf of _from
     * @param   _from  Address of the sender
     * @param   _value  Value in wei to burn
     * @return  success  If burn was successful
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value); // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]); // Check allowance
        balanceOf[_from] -= _value; // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value; // Subtract from the sender's allowance
        totalSupply -= _value; // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

    /**
     * @dev     Admin allows to withdraw ether from the contract.
     */
    function reallocationEther() public onlyRole(keccak256("ADMIN")){
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    }
}
