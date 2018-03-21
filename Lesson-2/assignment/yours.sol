pragma solidity ^0.4.14;


contract Payroll {
    
    struct EmployeeProfile {
        address addr;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 10 seconds;
    
    address admin;    // administrator
    EmployeeProfile[] employees;
    uint totalSalary = 0;
    
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
        /*uint totals = 0;
        for (uint i = 0; i < employees.length; i++) {
            totals += employees[i].salary;
        }
        return this.balance / totals;*/
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }
    
    /**
     * Add employee to array.
     */
    function add(address addr, uint sal) public requireAdmin {
        var (employee, index) = _findEmployee(addr);
        assert(employee.addr == 0x0);
        
        uint salary = sal * 1 ether;
        employees.push(EmployeeProfile(addr, salary, now));
        totalSalary += salary;
    }
    
    /**
     * Update employee profile.
     */
    function update(address addr, uint sal) public requireAdmin {
        var (employee, index) = _findEmployee(addr);
        assert(employee.addr != 0x0);
        
        uint salary = sal * 1 ether;
        employees[index].salary = salary;
        employees[index].lastPayday = now;
        totalSalary += salary - employee.salary;
        _partialPaid(employee);
    }
    
    function remove(address addr) public requireAdmin {
        var (employee, index) = _findEmployee(addr);
        assert(employee.addr != 0x0);
        
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        totalSalary -= employee.salary;
        _partialPaid(employee);
    }
    
    function getPaid() public {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.addr != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        
        employees[index].lastPayday = nextPayday;
        employee.addr.transfer(employee.salary);
    }

    function _partialPaid(EmployeeProfile employee) private {
        if (employee.addr == 0x0) return;
        assert(employee.lastPayday < now);

        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.lastPayday = now;
        employee.addr.transfer(payment);
    }

    /*
     * Find employee profile from employees array.
     */
    function _findEmployee(address employeeId) private returns (EmployeeProfile, uint) {
        if (employeeId != 0x0) {
            for (uint idx = 0; idx < employees.length; idx++) {
                if (employees[idx].addr == employeeId) {
                    return (employees[idx], idx);
                }
            }
        }
    }
    
    /*
     * Perform update employee profile
     */
    function _updateEmployee(address employeeId, uint sal) private {
        var (profile, index) = _findEmployee(employeeId);
        
        uint salary = sal * 1 ether;
        if (profile.addr != 0x0) {
            employees[index].salary = salary;
            employees[index].lastPayday = now;
            totalSalary += salary - profile.salary;
            _partialPaid(profile);
        } else {
            profile.addr = employeeId;
            profile.salary = salary;
            profile.lastPayday = now;
            employees.push(profile);
            totalSalary += salary;
        }
    }
}
