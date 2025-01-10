// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenLottery {
    address public owner;
    uint256 public entryFee; // Fee to enter the lottery (in tokens)
    uint256 public lotteryEndTime; // Time when the lottery ends

    address[] public participants;
    address[] public whitelistedAddresses; // List of addresses that can participate

    mapping(address => bool) public hasParticipated; // Track if an address has entered

    IERC20 public token; // The token used for the lottery

    event LotteryEntered(address indexed participant);
    event LotteryWinner(address indexed winner, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyWhitelisted() {
        bool isWhitelisted = false;
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (msg.sender == whitelistedAddresses[i]) {
                isWhitelisted = true;
                break;
            }
        }
        require(isWhitelisted, "Not whitelisted");
        _;
    }

    modifier lotteryActive() {
        require(block.timestamp < lotteryEndTime, "Lottery has ended");
        _;
    }

    modifier lotteryEnded() {
        require(block.timestamp >= lotteryEndTime, "Lottery is still ongoing");
        _;
    }

    constructor(
        address _tokenAddress,
        uint256 _entryFee,
        uint256 _duration,
        address[] memory _whitelistedAddresses
    ) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
        entryFee = _entryFee;
        lotteryEndTime = block.timestamp + _duration; // Set the lottery duration
        whitelistedAddresses = _whitelistedAddresses;
    }

    // Allow owner to add whitelisted addresses
    function addWhitelistedAddress(address _address) external onlyOwner {
        whitelistedAddresses.push(_address);
    }

    // Function to enter the lottery
    function enterLottery() external lotteryActive onlyWhitelisted {
        require(!hasParticipated[msg.sender], "You have already participated");
        require(
            token.transferFrom(msg.sender, address(this), entryFee),
            "Token transfer failed"
        );

        participants.push(msg.sender);
        hasParticipated[msg.sender] = true;

        emit LotteryEntered(msg.sender);
    }

    // Function to pick a winner when the lottery ends
    function pickWinner() external lotteryEnded onlyOwner {
        require(participants.length > 0, "No participants in the lottery");

        // Random selection (simple, for illustration; in production use a more secure randomness approach)
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    participants
                )
            )
        ) % participants.length;
        address winner = participants[randomIndex];

        // Reward calculation (for example, 90% of the total collected funds as reward)
        uint256 reward = (token.balanceOf(address(this)) * 90) / 100;

        // Transfer reward to the winner
        require(token.transfer(winner, reward), "Reward transfer failed");

        emit LotteryWinner(winner, reward);

        // Reset the lottery
        resetLottery();
    }

    // Reset the lottery for the next round
    function resetLottery() internal {
        participants = new address[](0);
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            hasParticipated[whitelistedAddresses[i]] = false; // Reset participation status
        }
        lotteryEndTime = block.timestamp + 7 days; // Set a new lottery duration (e.g., 7 days)
    }

    // Get the list of whitelisted addresses
    function getWhitelistedAddresses()
        external
        view
        returns (address[] memory)
    {
        return whitelistedAddresses;
    }

    // Get the current participants
    function getParticipants() external view returns (address[] memory) {
        return participants;
    }
}
