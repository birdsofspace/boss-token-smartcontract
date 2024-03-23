// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IERC20.sol';

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
    function _transfer(address _from, address _to, uint256 _value) internal virtual {
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
    function transfer(address _to, uint256 _value) public virtual returns (bool success) {
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
