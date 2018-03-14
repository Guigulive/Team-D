
/*weiyingtao homework*/
pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 30 days;

    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;
    }
    
    function updateEmployeeAdress(address newAddress) {
        require(msg.sender == owner);
        
        
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        employee = newAddress;
        lastPayday = now;
    }
        
    function updateEmployeeSalary(uint newSalary) {
        require(msg.sender == owner);
        
        salary = newSalary;

    }
    
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        if(salry == 0){
            revert();
        }
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        require(msg.sender == employee);
        
        uint nextPayday = lastPayday + payDuration;
        if (nextPayday < now) {
            revert();
        }

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}
