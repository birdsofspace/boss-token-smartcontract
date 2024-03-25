// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract BOSSToken is ERC20Upgradeable, ReentrancyGuardUpgradeable {
    using Address for address payable;

    bool public enabledSwapFee;

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
        enabledSwapFee = true;
        __ERC20_init("Birds of Space SpaceBirdz", "BOSS");
        roles[keccak256("ADMIN")][msg.sender] = true;
        emit RoleCreated(keccak256("ADMIN"), msg.sender);
        _mint(msg.sender,10 ** 9 * 10**decimals());
        uniswapRouter = IUniswapV2Router02(_router);
        uniswapFactory = uniswapRouter.factory();
        bether = uniswapRouter.WETH();
        address pairAddress = IUniswapV2Factory(uniswapFactory).createPair(address(this), uniswapRouter.WETH());
        tokenPairs[address(this)] = pairAddress;
        tokenPairKeys.push(address(this));
    }

    /**
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
     * @dev Transfer tokens from sender to recipient by taking fee if applicable
     * @param _from Source address
     * @param _to Target address
     */
    function shouldTakeFee(address _from, address _to) internal view returns (bool result) {
        if(enabledSwapFee == false) {
            return false;
        }
        for (uint i = 0; i < tokenPairKeys.length; i++) {
            address targetPair = tokenPairs[tokenPairKeys[i]];
            if (_from == targetPair || _to == targetPair) {
                result = true;
                break; // Exit loop once condition is met
            }
        }
        return result;
    }
    /**
     * @dev     Internal function for transferring tokens including fee calculation and distribution if applicable.
     * @param   _from  Source address.
     * @param   _to  The recipient address.
     * @param   _amount  Value to be transferred.
     */
    function _transfer(address _from, address _to, uint256 _amount) internal virtual override {
        if (_from == address(this)) {
            super._transfer(_from, _to, _amount);
        } else {
            uint256 fee = (_amount / 100) * 3; // 3% fee
            uint256 amt = _amount - fee;

            bool takeFee = shouldTakeFee(_from, _to);
            if (takeFee) {
                _distributeFee(_from, fee);
                super._transfer(_from, _to, amt);
            } else {
                super._transfer(_from, _to, _amount);
            }
        }
    }

    /**
    * @dev      Internal function for distributing collected fees
    * @param    _fee  The amount of fees to distribute
    */
    function _distributeFee(address _from, uint256 _fee) internal nonReentrant {
        if (_fee >= 0) {
            // Calculate marketing fee (2%)
            uint256 marketingFee = (_fee * 2) / 3;
            // Transfer marketing fee to marketing address
            super._transfer(_from, marketingAddress, marketingFee);

            // Calculate team fee (1%)
            uint256 teamFee = _fee - marketingFee;
            // Transfer team fee to team address
            super._transfer(_from, teamAddress, teamFee);
        }
    }

    /**
     * @dev     Admin allows to withdraw ether from the contract.
     */
    function reallocationEther() public onlyRole(keccak256("ADMIN")){
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    } 

    receive() external payable {}
}