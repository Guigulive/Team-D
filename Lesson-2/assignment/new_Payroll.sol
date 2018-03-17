
添加新员工后调用calculateRunway函数所消耗的gas会随着员工数量增加而增加，优化前每增加一名新员工，调用calculateRunway函数时所消耗的gas大约会增加 788 gas，具体消耗情况如下：
代码优化前
一名员工：22971gas;
两名员工：23759gas;
三名员工：24547gas;
四名员工：25335gas;
五名员工：26123gas;
六名员工：26911gas;
七名员工：27699gas;
八名员工：28487gas;
九名员工：29275gas;
十名员工：30063gas;

优化后
添加新员工后调用calculateRunway函数所消耗的gas保持不变，不再随着员工数量增加而增加，每次都是22144 gas。

优化方案
将totalSalary作为全局变量记录工资总额，并在工资变化点重新计算工资总额（包括新增、删除、更新员工三处），同时删除calculateRunway中通过遍历员工数组获取工资总额的方法，改为直接读取totalSalary。

/* 优化后代码 */
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

	      // 计算工资总金额
        totalSalary += salary;
    }

    function removeEmployee(address employeeId) isOwner {
        var(employee, index) = _partialFindEmployee(employeeId);
        assert(employee.id != 0x0);

	      // 结算工资变化前尚未支付的工资
        _partialPaid(employee);
        uint len = employees.length;
        delete employees[index];
        employees[index] = employees[len - 1];
        len--;

	      // 计算工资总金额
        totalSalary -= employee.salary;
    }

    function updateSalary(address employeeId, uint salary) isOwner {
        var(employee, index) = _partialFindEmployee(employeeId);
        assert(employee.id != 0x0);

        uint newSalary = salary * 1 ether;
        assert(newSalary != employee.salary);

	      // 结算工资变化前尚未支付的工资
        _partialPaid(employee);
        employees[index].salary     = newSalary;
        employees[index].lastPayDay = now;

	     // 计算工资总金额
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
