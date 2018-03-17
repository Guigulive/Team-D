
添加新员工后调用calculateRunway函数所消耗的gas会随着员工数量增加而增加，优化前每增加一名新员工，调用calculateRunway函数时所消耗的gas大约会增加 788 gas，具体消耗情况如下：
代码优化前
一名员工：8102gas;
两名员工：8215gas;
三名员工：8328gas;
四名员工：8441gas;
五名员工：8554gas;
六名员工：8667gas;
七名员工：8780gas;
八名员工：8893gas;
九名员工：9006gas;
十名员工：9119gas;

优化后
添加新员工后调用calculateRunway函数所消耗的gas恒定不变。

----优化后代码如下----

pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 10 seconds;

    address owner;
    uint totalSalary;
    Employee []employees;

    function Payroll() {
        owner = msg.sender;
    }

    modifier isOwner() {
       require(msg.sender == owner);
       _;
    }

    function _partialFindEmployee(address employeeId) private returns (Employee, uint) {
        uint len = employees.length;
        for (uint i = 0; i < len; i++) {
            if (employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) isOwner {
        var(employee, _) = _partialFindEmployee(employeeId);
        assert(employee.id == 0x0);

        employees.push(Employee(employeeId, salary * 1 ether, now));

	// 同步工资总金额
        totalSalary += salary;
    }

    function removeEmployee(address employeeId) isOwner {
        var(employee, index) = _partialFindEmployee(employeeId);
        assert(employee.id != 0x0);

        _partialPaid(employee);
        uint length = employees.length;
        delete employees[index];
        employees[index] = employees[len - 1];
        length--;

        totalSalary -= employee.salary;
    }

    function updateSalary(address employeeId, uint salary) isOwner {
        var(employee, index) = _partialFindEmployee(employeeId);
        assert(employee.id != 0x0);

        uint newSalary = salary * 1 ether;
        assert(newSalary != employee.salary);

        _partialPaid(employee);
        employees[index].salary     = newSalary;
        employees[index].lastPayDay = now;

        totalSalary = totalSalary - employee.salary + salary;
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        var (employee, index) = _partialFindEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);

        employees[index].lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
