pragma solidity ^0.4.14;


import "./SafeMath.sol";


contract Payroll {

    using SafeMath for uint;
    
    struct EmployeeProfile {
        address addr;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;

    address admin;  // administrator
    uint totalSalary;
    mapping(address => EmployeeProfile) public employees;
    
    function Payroll() public {
        admin = msg.sender;
    }

    modifier require_admin {
        require(msg.sender == admin);
        _;
    }
    
    modifier has_employee(address addr) {
        require(employees[addr].addr != 0x0);
        _;
    }
    
    modifier no_employee(address addr) {
        require(employees[addr].addr == 0x0);
        _;
    }
    
    function addFund() public payable returns (uint balance) {
        return address(this).balance;
    }
    
    function calculateRunway() public view returns (uint runway) {
        return address(this).balance.div(totalSalary);
    }
    
    function hasEnoughFund() public view returns (bool hasEnough) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public {
        EmployeeProfile storage employee = employees[msg.sender];
        assert(employee.addr != 0x0);

        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        
        employee.lastPayday = nextPayday;
        employee.addr.transfer(employee.salary);
    }

    /**
     * Add employee mapping.
     * 
     * @param addr address of the employee to add
     * @param sal  employee's salary
     */
    function add(address addr, uint sal) public require_admin no_employee(addr) {
        uint salary = sal.mul(1 ether);
        employees[addr] = EmployeeProfile(addr, salary, now);
        totalSalary = totalSalary.add(salary);
    }
    
    /**
     * Update employee profile.
     * 
     * @param addr address of the employee to update
     * @param sal  employee's salary
     */
    function update(address addr, uint sal) public require_admin has_employee(addr) {
        EmployeeProfile memory employee = employees[addr];
        uint salary = sal.mul(1 ether);
        employees[addr].salary = salary;
        employees[addr].lastPayday = now;
        totalSalary = totalSalary.add(salary).sub(employee.salary);
        _partialPaid(employee);
    }
    
    /**
     * Remove pay the employee with id specified.
     * 
     * @param addr address of the employee to remove
     */
    function remove(address addr) public require_admin has_employee(addr) {
        EmployeeProfile memory employee = employees[addr];
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[addr];
        _partialPaid(employee);
    }
    
    /**
     * Update or add employee profile.
     * 
     * @param employeeId address of the employee to update
     * @param sal        employee's salary
     */
    function updateEmployee(address employeeId, uint sal) public require_admin {
        EmployeeProfile memory profile = employees[employeeId];

        uint salary = sal.mul(1 ether);
        if (profile.addr != 0x0) {
            // update
            employees[employeeId].salary = salary;
            employees[employeeId].lastPayday = now;
            totalSalary = totalSalary.add(salary).sub(profile.salary);
            _partialPaid(profile);
        } else {
            // add new employee
            profile.addr = employeeId;
            profile.salary = salary;
            profile.lastPayday = now;
            employees[employeeId] = profile;
            totalSalary = totalSalary.add(salary);
        }
    }
    
    /**
     * Change employee's address.
     * 
     * @param employeeAddr address of the employee to change
     * @param newAddress   employee's new address
     */
    function changePaymentAddress(address employeeAddr, address newAddress) public require_admin has_employee(employeeAddr) no_employee(newAddress) {
        require(newAddress != employeeAddr && newAddress != 0x0);

        EmployeeProfile memory employee = employees[employeeAddr];
        employee.addr = newAddress;
        delete employees[employeeAddr];
    }

    function _partialPaid(EmployeeProfile employee) private {
        if (employee.addr == 0x0) return;
        assert(employee.lastPayday < now);

        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.lastPayday = now;
        employee.addr.transfer(payment);
    }
}
