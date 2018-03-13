pragma solidity ^0.4.14;            // 声明合约版本号
contract Payroll{
    uint salary = 0;                // 员工工资
    address staffAddress = 0x0;    // 员工地址
    uint payDuraton = 0;           // 发薪水周期
    uint lastPayday = 0;           // 上一次发薪水的时间戳    
    
    // 返回合约的余额
    function addFund() payable returns(uint){
        return this.balance;
    }
    
    // 计算合约的资金还能发几次工资
    function calulateRunway() returns(uint){
        return this.balance / salary;
    }
    
    // 判断是否够发一次工资
    function hasEnoughFund() returns(bool){
        return calulateRunway() > 0;
    }
    
    // 重置薪水
    function setSalary(uint newSalary){
        salary = newSalary;
    }
    
    // 重置发薪水周期
    function setPayDuraton(uint newDuraton){
        payDuraton = newDuraton;
    }
    
    // // 重置员工地址
    function setStaffAddress(address newAddress){
        if(newAddress != 0x0){
            staffAddress = newAddress;
            lastPayday = now;
        }
    }
    
    // 给员工发工资
    function getPaid(){
        if(msg.sender != staffAddress){
            revert();
        }
        
        uint nextPayday = lastPayday + payDuraton;
        if(nextPayday > now){
            revert();

        }
        
        lastPayday = nextPayday;
        staffAddress.transfer(salary);
    }
}
