// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialMediaRewards {
    struct Task {
        string description;
        uint256 reward;
        bool isCompleted;
    }

    struct User {
        uint256 tokensEarned;
        uint256 tasksCompleted;
    }

    mapping(address => User) public users;
    Task[] public tasks;
    uint256 public nextBadgeId;

    string public tokenName = "SocialMediaToken";
    string public tokenSymbol = "SMT";
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    mapping(uint256 => string) public badgeURIs;
    mapping(uint256 => address) public badgeOwners;

    address public owner;

    constructor() {
        owner = msg.sender;
        totalSupply = 1000000 * (10 ** 18); // Initial token supply
        balances[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Add a new task (Only admin)
    function addTask(string memory description, uint256 reward) public onlyOwner {
        tasks.push(Task({
            description: description,
            reward: reward,
            isCompleted: false
        }));
    }

    // Complete a task and earn tokens
    function completeTask(uint256 taskId) public {
        require(taskId < tasks.length, "Invalid task ID");
        Task storage task = tasks[taskId];
        require(!task.isCompleted, "Task already completed");

        task.isCompleted = true;
        users[msg.sender].tokensEarned += task.reward;
        users[msg.sender].tasksCompleted += 1;
        balances[msg.sender] += task.reward;
        totalSupply -= task.reward;
    }

    // Award NFT badges for major milestones (Only admin)
    function awardBadge(address user, string memory badgeURI) public onlyOwner {
        badgeURIs[nextBadgeId] = badgeURI;
        badgeOwners[nextBadgeId] = user;
        nextBadgeId++;
    }

    // View all tasks
    function getTasks() public view returns (Task[] memory) {
        return tasks;
    }

    // Check user stats
    function getUserStats(address user) public view returns (uint256 tokensEarned, uint256 tasksCompleted) {
        User memory u = users[user];
        return (u.tokensEarned, u.tasksCompleted);
    }

    // Transfer tokens
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    // Get badge URI
    function getBadgeURI(uint256 badgeId) public view returns (string memory) {
        require(badgeOwners[badgeId] != address(0), "Badge does not exist");
        return badgeURIs[badgeId];
    }
}
