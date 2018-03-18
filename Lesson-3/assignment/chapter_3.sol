pragma solidity ^0.4.14;

contract Payroll {
    
    struct EmployeeProfile {
        address addr;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    address admin;  // administrator
    mapping(address => EmployeeProfile) employees;
    
    function Payroll() {
        admin = msg.sender;
    }

    modifier requireAdmin {
        require(msg.sender == admin);
        _;
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
        var employee = employees[msg.sender];
        assert(employee.addr != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        
        employee.lastPayday = nextPayday;
        employee.addr.transfer(employee.salary);
    }

    /**
     * Add employee mapping.
     */
    function add(address addr, uint sal) public requireAdmin {
        var employee = employees[addr];
        assert(employee.addr == 0x0);
        
        uint salary = sal * 1 ether;
        employees[addr] = EmployeeProfile(addr, salary, now);
        totalSalary += salary;
    }
    
    /**
     * Update employee profile.
     */
    function update(address addr, uint sal) public requireAdmin {
        var employee = employees[addr];
        assert(employee.addr != 0x0);
        
        uint salary = sal * 1 ether;
        employee.salary = salary;
        employee.lastPayday = now;
        totalSalary += salary - employee.salary;
        _partialPaid(employee);
    }
    
    /**
     * Remove pay the employee with id specified.
     */
    function remove(address addr) public requireAdmin {
        var employee = employees[addr];
        assert(employee.addr != 0x0);
        
        totalSalary -= employee.salary;
        _partialPaid(employee);
        delete employee;
    }
    
    /*
     * Update or add employee profile.
     */
    function updateEmployee(address employeeId, uint sal) public requireAdmin {
        var profile = employees[employeeId];
        
        uint salary = sal * 1 ether;
        if (profile.addr != 0x0) {
            totalSalary += salary - profile.salary;
            _partialPaid(profile);
            profile.salary = salary;
            profile.lastPayday = now;
        } else {
            profile.addr = employeeId;
            profile.salary = salary;
            profile.lastPayday = now;
            employee[employeeId] = profile;
            totalSalary += salary;
        }
    }

    function _partialPaid(EmployeeProfile employee) private {
        if (employee.addr == 0x0) return;
        assert(employee.lastPayday < now);

        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.lastPayday = now;
        employee.addr.transfer(payment);
    }
}
