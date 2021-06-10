//SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;
contract Campaign{

    string  public name;
    address public manager;
    uint256 public maximumTarget;
    uint256 public minimumTarget;
    uint24  public duration;
    bytes   public hash;

    uint256 public startTime;
    uint8   public isActive;
    uint8   public isClosed;
    uint256 public totalCollected;
    uint256 public totalWithdrawn;
    uint8   public isMinimumReached;
    uint8   public isMaximumReached;

    mapping( address => uint256 ) public contributors;

    modifier onlyManager() {
        require(manager == msg.sender, "Campaign: onlyManager function");
        _;
    }

    constructor (
        string memory _name,
        address _manager,
        uint24 _duration,
        uint256 _maximumTarget,
        uint256 _minimTarget,
        bytes memory _hash
    ) {
        name = _name;
        manager = _manager;
        maximumTarget = _maximumTarget;
        minimumTarget = _minimTarget;
        duration = _duration;
        hash = _hash;
    }

    function contribute() public payable {
        require(
            isActive == 1,
            "Campaign: not yet started"
        );
        require( 
            totalCollected + msg.value <= maximumTarget, 
            "Campaign: contribution exceeds maximum target" 
            );
        totalCollected += msg.value;
        contributors[msg.sender] += msg.value;
        if(totalCollected >= minimumTarget){
            isMinimumReached = 1;
        }
        if(totalCollected == maximumTarget){
            isMaximumReached = 1;
            // end campaign and transfer funds to manager
        }
    }

    function retrieveContribution() public {
        require(
            isMinimumReached == 0 || block.timestamp < startTime + duration,
            "Campaign: The campaign have been finalised"
        );
        uint256 contribution = contributors[msg.sender];
        contributors[msg.sender] = 0;
        totalCollected -= contribution;
        payable(msg.sender).transfer(contribution);
    }

    function startCampaign() public onlyManager {
        require(isActive == 0, "Campaign: alrerady active");
        isActive = 1;
        startTime = block.timestamp;
    }

    function closeCampaign() public onlyManager {
        require(
            isMinimumReached == 0 || block.timestamp < startTime + duration,
            "Campaign: The campaign have been finalised"
        );
        isClosed = 1;
    }

    function withdraw(uint256 _amount) public onlyManager {
        require(
            isMinimumReached == 1 || block.timestamp >= startTime + duration,
            "Campaign: The campaign have been finalised"
        );
        require(
            totalCollected >= totalWithdrawn+_amount,
            "Capmaign: Cannot withdraw more than collected"
        );
        totalWithdrawn += _amount;
        payable(manager).transfer(_amount);
    }

}