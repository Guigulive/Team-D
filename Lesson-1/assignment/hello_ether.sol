pragma solidity ^0.4.14;

contract Payroll {
    
    struct EmployeeProfile {
        address addr;
        uint salary;
        uint lastPayday;
    }
    
    address admin;  // administrator
    mapping(address => EmployeeProfile) employees;
    uint constant payDuration = 10 seconds;

    address employee;
    uint salary;
    uint lastPayday;
    
    function Payroll() {
        admin = msg.sender;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() public returns (uint) {
        _loadPayroll(msg.sender);
        return this.balance / salary;
    }
    
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public {
        require(msg.sender == employee);
        
        _loadPayroll(msg.sender);
        
        uint nextPayday = nextPayday + payDuration;
        assert(nextPayday < now);
        
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
    /**
     * Update employee profile
     * <br/>
     * Require administrator
     */
    function update(address addr, uint sal) public {
        require(msg.sender == admin);
        
        employee = addr;
        salary = sal;
        _updateEmployee(addr, sal);
    }
    
    /*
     * Perform update employee profile
     */
    function _updateEmployee(address employeeId, uint sal) private {
        EmployeeProfile profile = employees[employeeId];
        bool hasProfileCached = profile.addr != 0x0;
        
        if (hasProfileCached) {
            uint payment = profile.salary * (now - profile.lastPayday) / payDuration;
            profile.addr.transfer(payment);
        }

        profile.addr = employeeId;
        profile.salary = sal * 1 ether;
        profile.lastPayday = now;
        
        if (!hasProfileCached) {
            employees[employeeId] = profile;
        }
    }
    
    /*
     * Load employee profile with employeeId
     */
    function _loadPayroll(address addr) private {
        EmployeeProfile profile = employees[addr];
        if (profile.addr != 0x0) {
            salary = profile.salary;
            lastPayday = profile.lastPayday;
        } else {
            salary = 1 ether;
            lastPayday = now;
        }
        employee = addr;
    }
}
