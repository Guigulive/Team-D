/*作业请提交在这个目录下*/
pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


pragma solidity ^0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 10 seconds;

    uint totalSalary;
    mapping(address => Employee) public employees;

    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }

    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayDay)).div(payDuration);
        employee.id.transfer(payment);
    }

//1
    function addEmployee(address employeeId, uint _salary) onlyOwner employeeNotExist(employeeId) {
        var employee = employees[employeeId];
        uint salary  = _salary.mul(1 ether);
        employees[employeeId] = Employee({id: employeeId, salary: salary, lastPayDay: now});
        totalSalary           = totalSalary.add(salary);
    }
//2
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
       var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[employeeId];
    }

    function updateSalary(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        var employee   = employees[employeeId];
        uint newSalary = salary.mul(1 ether);
        assert(newSalary != employee.salary);

        _partialPaid(employee);
        totalSalary         = totalSalary.sub(employee.salary).add(newSalary);
        employee.salary     = newSalary;
        employee.lastPayDay = now;
    }

    function changePaymentAddress(address employeeNewId) employeeExist(msg.sender) employeeNotExist(employeeNewId) {
        var employee = employees[msg.sender];
        employees[employeeNewId] = Employee({id: employeeNewId, salary: employee.salary, lastPayDay: employee.lastPayDay});
        delete employees[msg.sender];
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() employeeExist(msg.sender) {
        var employee    = employees[msg.sender];
        uint nextPayDay = employee.lastPayDay.add(payDuration);
        assert(nextPayDay < now);

        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
