// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LendingProtocol {
    address public owner;
    uint256 public constant INTEREST_RATE = 5; // 5% annual interest rate
    uint256 public constant COLLATERAL_RATIO = 150; // 150% collateralization ratio
    
    struct Loan {
        uint256 principal;
        uint256 collateral;
        uint256 timestamp;
        bool active;
        address borrower;
    }
    
    mapping(address => Loan) public loans;
    mapping(address => uint256) public deposits;
    
    event LoanCreated(address indexed borrower, uint256 principal, uint256 collateral);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event DepositMade(address indexed lender, uint256 amount);
    event WithdrawalMade(address indexed lender, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // Function 1: Deposit funds to earn interest
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        deposits[msg.sender] += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }
    
    // Function 2: Borrow funds against collateral
    function borrow(uint256 _amount) external payable {
        require(_amount > 0, "Borrow amount must be greater than 0");
        require(loans[msg.sender].active == false, "Existing loan must be repaid first");
        require(msg.value >= (_amount * COLLATERAL_RATIO) / 100, "Insufficient collateral");
        require(address(this).balance >= _amount, "Insufficient liquidity");
        
        loans[msg.sender] = Loan({
            principal: _amount,
            collateral: msg.value,
            timestamp: block.timestamp,
            active: true,
            borrower: msg.sender
        });
        
        payable(msg.sender).transfer(_amount);
        emit LoanCreated(msg.sender, _amount, msg.value);
    }
    
    // Function 3: Repay loan with interest
    function repayLoan() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.active, "No active loan found");
        
        uint256 timeElapsed = block.timestamp - loan.timestamp;
        uint256 interest = (loan.principal * INTEREST_RATE * timeElapsed) / (365 days * 100);
        uint256 totalRepayment = loan.principal + interest;
        
        require(msg.value >= totalRepayment, "Insufficient repayment amount");
        
        // Return collateral to borrower
        payable(msg.sender).transfer(loan.collateral);
        
        // Return excess payment if any
        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }
        
        loan.active = false;
        emit LoanRepaid(msg.sender, totalRepayment);
    }
    
    // Function 4: Withdraw deposits
    function withdraw(uint256 _amount) external {
        require(deposits[msg.sender] >= _amount, "Insufficient deposit balance");
        require(address(this).balance >= _amount, "Insufficient contract balance");
        
        deposits[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit WithdrawalMade(msg.sender, _amount);
    }
    
    // Function 5: Get loan details
    function getLoanDetails(address _borrower) external view returns (uint256, uint256, uint256, bool) {
        Loan memory loan = loans[_borrower];
        return (loan.principal, loan.collateral, loan.timestamp, loan.active);
    }
}
