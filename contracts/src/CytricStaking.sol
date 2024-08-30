// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
- **Dynamic Reward Adjustment**:
    - Implement a mechanism where the reward rate can be adjusted dynamically based on the total amount staked. 
    For example, if the total staked amount is low, the reward rate increases, and if the total staked amount is high, 
    the reward rate decreases.

    - Ensure the contract handles edge cases, such as multiple users staking and withdrawing at different times.

- **Reward Calculation**:
    - Rewards should be distributed based on the time tokens are staked. 
    Users earn a portion of the rewards proportional to their stake and staking duration.

NOTE to Cytric: this type of reward adjustment can definitely be gamed in the mempool.  
     MEV bot can frontrun to stake a large amount to reduce the reward rate

*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CytricStaking is Ownable, Pausable {
    /* ----------------------------------------- */
    /*  Type Declarations                                                           
    /* ----------------------------------------- */

    using SafeERC20 for ERC20;

    /* ----------------------------------------- */
    /*  Mutable Storage                                                           
    /* ----------------------------------------- */

    /// @notice base reward rate used to calculate dynamic rate
    uint256 public baseRate;

    /// @notice total staked amount
    uint256 public totalStaked;

    struct UserData {
        uint256 totalStaked;
        uint256 unclaimedRewards;
        uint256 lastStakedTime;
    }

    /// @notice User stakes and rewards data
    mapping(address user => UserData) public userData;

    /* ----------------------------------------- */
    /*  Immutable Storage                                                           
    /* ----------------------------------------- */

    /// @notice Address of Cytric Token
    ERC20 public immutable cytricToken;

    /// @notice Start time of the staking contract.
    uint256 public immutable startTime;

    /* ----------------------------------------- */
    /*  Events                                                           
    /* ----------------------------------------- */

    /// @dev Emitted when user stakes
    event Staked(address indexed user, uint256 indexed amount);

    /// @dev Emitted when user unstakes
    event Withdrawn(address indexed user, uint256 indexed amount);

    /// @dev Emitted when user claims rewards
    event ClaimedRewards(address indexed user, uint256 indexed amount);

    /// @dev Emitted when rewards are deposited
    event RewardsDeposited(uint256 indexed amount);

    /* ----------------------------------------- */
    /*  Errors                                                           
    /* ----------------------------------------- */

    /// @dev Error thrown when given amount is not in a valid range
    error InvalidAmount();

    /// @dev Error thrown when given address is zero
    error InvalidZeroAddress();

    /// @dev Error thrown when there aren't enough reward tokens in the reward pool
    error InsufficientRewardPool();

    /* ----------------------------------------- */
    /*  Constructor                                                           
    /* ----------------------------------------- */

    /// @notice Initialize contract with starting variables
    /// @param _cytricToken staking token
    /// @param _baseRate base reward rate
    constructor(address _cytricToken, uint256 _baseRate) Ownable(msg.sender) {
        if (_cytricToken == address(0)) revert InvalidZeroAddress();

        cytricToken = ERC20(_cytricToken);
        baseRate = _baseRate;
        startTime = block.timestamp;
    }

    /* ----------------------------------------- */
    /*  EXTERNAL/PUBLIC                                                           
    /* ----------------------------------------- */

    /// @notice users can lock their tokens
    /// @param _amount Amount of tokens to lock
    function stake(uint256 _amount) external whenNotPaused {
        // CHECKS
        if (_amount == 0) revert InvalidAmount();

        // EFFECTS
        _updateUserData(msg.sender, _amount, true);
        totalStaked += _amount;

        // INTERACTIONS
        cytricToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    /// @notice Allow users to withdraw some amount of staked tokens and all accumulated rewards thus far
    /// @param _amount amount of tokens user wants to unstake
    function withdraw(uint256 _amount) external {
        // CHECKS
        if (_amount == 0) revert InvalidAmount();

        UserData storage user = userData[msg.sender];
        if (_amount > user.totalStaked) revert InvalidAmount();

        // EFFECTS
        _updateUserData(msg.sender, _amount, false);
        uint256 rewardTokens = user.unclaimedRewards;
        user.unclaimedRewards = 0;

        totalStaked -= _amount;

        // INTERACTIONS

        // Transfer the user's tokens back
        cytricToken.safeTransfer(msg.sender, _amount);

        // Transfer reward tokens to user
        if (cytricToken.balanceOf(address(this)) < rewardTokens) {
            revert InsufficientRewardPool();
        }
        cytricToken.safeTransfer(msg.sender, rewardTokens);

        emit Withdrawn(msg.sender, _amount);
        emit ClaimedRewards(msg.sender, rewardTokens);
    }

    /// @notice Allow users to claim their accumulated rewards
    /// @dev Rewards should be distributed based on the time tokens are staked.
    ///      Users earn a portion of the rewards proportional to their stake and staking duration.
    function claimRewards() external {
        // CHECKS
        UserData storage user = userData[msg.sender];
        if (user.totalStaked == 0) revert InvalidAmount();

        // EFFECTS
        uint256 rewardTokens = _calculateRewards(user.totalStaked, user.lastStakedTime);
        rewardTokens += user.unclaimedRewards;

        user.unclaimedRewards = 0;
        user.lastStakedTime = block.timestamp;

        // INTERACTIONS
        if (cytricToken.balanceOf(address(this)) < rewardTokens) {
            revert InsufficientRewardPool();
        }
        cytricToken.safeTransfer(msg.sender, rewardTokens);

        emit ClaimedRewards(msg.sender, rewardTokens);
    }

    /// @notice Reward pool should be refilled by the contract owner
    /// @dev owner can choose to mint new tokens or transfer from owner's account
    /// @param _amount The amount of tokens to deposit into the reward pool
    function depositRewards(uint256 _amount) external onlyOwner {
        if (_amount == 0) revert InvalidAmount();

        cytricToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit RewardsDeposited(_amount);
    }

    /// @notice base reward rate can be adjusted by the contract owner
    function setBaseRate(uint256 _baseRate) external onlyOwner {
        baseRate = _baseRate;
    }

    /* ----------------------------------------- */
    /*  INTERNAL/PRIVATE                                                         
    /* ----------------------------------------- */

    /// @notice Accumulate unclaimed rewards for the user from last unclaimed timestamp
    /// @dev This function should run before every tx user does, so state is correctly maintained everytime //! TODO: check if this is true
    /// @param user Address of the user
    /// @param amount amount of tokens
    function _updateUserData(address user, uint256 amount, bool isStaking) private {
        UserData storage ud = userData[user];

        // Update amount user can claim
        if (ud.totalStaked > 0) {
            ud.unclaimedRewards += _calculateRewards(ud.totalStaked, ud.lastStakedTime);
        }

        ud.lastStakedTime = block.timestamp;

        if (isStaking) {
            ud.totalStaked += amount;
        } else {
            ud.totalStaked -= amount;
        }
    }

    /// @notice Calculate reward for a given amount from last stake time to current tim
    /// @param amountStaked The amount of tokens user has staked
    /// @param lastStakedTime Time last staked by the user
    /// @return rewardAmount The reward amount that has been distributed.
    function _calculateRewards(uint256 amountStaked, uint256 lastStakedTime)
        private
        view
        returns (uint256 rewardAmount)
    {
        uint256 duration = block.timestamp - lastStakedTime;

        uint256 dynamicRate = _calculateDynamicRate();

        // Users earn a portion of the rewards proportional to their stake and staking duration
        // Proportion is calculated based on totalStaked
        rewardAmount = (amountStaked * duration * dynamicRate) / totalStaked;
    }

    /// @notice Calculates the dynamic reward rate.
    /// @dev This function should run every time the totalStaked variable changes
    /// @return dynamicRate returns the varying reward rate based on total staked amount by all users
    function _calculateDynamicRate() private view returns (uint256 dynamicRate) {
        // TODO: normalized rate of change curve, maybe square root totalStaked or square the baseRate
        dynamicRate = baseRate * 10 ** cytricToken.decimals() / (totalStaked + 1); // add 1 to always avoid dividing by zero
    }
}
