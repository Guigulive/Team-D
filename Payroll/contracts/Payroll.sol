pragma solidity ^0.4.14;


import "./Ownable.sol";
import "./SafeMath.sol";


contract Payroll is Ownable {

    using SafeMath for uint;
    
    struct EmployeeProfile {
        address addr;
        uint salary;
        uint lastPayday;
        uint index;
    }
    
    uint constant payDuration = 10 seconds;

    address[] employeeAddrs;
    uint totalSalary;
    uint totalEmployee;
    mapping(address => EmployeeProfile) public employees;
    
    function Payroll() public {
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
    function add(address addr, uint sal) public onlyOwner no_employee(addr) {
        uint salary = sal.mul(1 ether);
        employees[addr] = EmployeeProfile(addr, salary, now, totalEmployee);
        employeeAddrs.push(addr);
        totalSalary = totalSalary.add(salary);
        totalEmployee = totalEmployee.add(1);
    }
    
    /**
     * Update employee profile.
     * 
     * @param addr address of the employee to update
     * @param sal  employee's salary
     */
    function update(address addr, uint sal) public onlyOwner has_employee(addr) {
        EmployeeProfile memory employee = employees[addr];
        uint salary = sal.mul(1 ether);
        employees[addr].salary = salary;
        employees[addr].lastPayday = now;
        employeeAddrs[employee.index] = addr;
        totalSalary = totalSalary.add(salary).sub(employee.salary);
        _partialPaid(employee);
    }
    
    /**
     * Remove pay the employee with id specified.
     * 
     * @param addr address of the employee to remove
     */
    function remove(address addr) public onlyOwner has_employee(addr) {
        EmployeeProfile memory employee = employees[addr];
        delete employees[addr];
        totalSalary = totalSalary.sub(employee.salary);
        totalEmployee = totalEmployee.sub(1);

        uint indexRm = employee.index;
        delete employeeAddrs[indexRm];
        uint indexTail = employeeAddrs.length.sub(1);
        if (indexTail > indexRm) {
            address employeeLast = employeeAddrs[indexTail];
            employees[employeeLast].index = indexRm;
            employeeAddrs[indexRm] = employeeLast;
        }
        _partialPaid(employee);
    }
    
    /**
     * Update or add employee profile.
     * 
     * @param employeeId address of the employee to update
     * @param sal        employee's salary
     */
    function updateEmployee(address employeeId, uint sal) public onlyOwner {
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
    function changePaymentAddress(address employeeAddr, address newAddress) public onlyOwner has_employee(employeeAddr) no_employee(newAddress) {
        require(newAddress != employeeAddr && newAddress != 0x0);

        EmployeeProfile memory employee = employees[employeeAddr];
        employee.addr = newAddress;
        delete employees[employeeAddr];
    }

    /**
     * Checkout employee profile.
     */
    function checkEmployee(uint index) public view returns (address employeeId, uint salary, uint lastPayday) {
        employeeId = employeeAddrs[index];
        EmployeeProfile memory employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }

    /**
     * Checkout payroll information.
     */
    function checkInfo() public view returns (uint balance, uint runway, uint employeeCount) {
        balance = address(this).balance;
        employeeCount = totalEmployee;
 
        if (totalSalary > 0) {
            runway = calculateRunway();
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
