pragma solidity ^0.4.14;

contract Payroll {
    
    struct EmployeeProfile {
        address addr;
        uint salary;
        uint lastPayday;
    }
    
    mapping(address => EmployeeProfile) employees;
    address admin = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;

    uint constant payDuration = 10 seconds;

    address employee = 0x0;
    uint salary = 1 wei;
    uint lastPayday = now;
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        loadPayroll(msg.sender);
        return this.balance / salary;
    }
    
    function hasEnoughFund() view returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        if (msg.sender != employee) {
            revert();
        }
        loadPayroll(msg.sender);
        
        uint nextPayday = nextPayday + payDuration;
        if (nextPayday > now) {
            revert();
        }
        
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
    function update(address addr, uint sal) {
        employee = addr;
        salary = sal;
        updateEmployee(addr, sal);
    }
    
    function updateEmployee(address employee, uint sal) private {
        EmployeeProfile profile = employees[employee];
        bool hasProfileCached = profile.addr != 0x0;

        profile.addr = employee;
        profile.salary = sal;
        profile.lastPayday = now;
        
        if (!hasProfileCached) {
            employees[employee] = profile;
        }
    }
    
    function loadPayroll(address addr) private {
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
    
    function test(address addr, uint sal) public {
        if (msg.sender != admin) {
            revert();
        }
        if (sal <= 0) {
            revert();
        }
        update(addr, sal);
    }
}
