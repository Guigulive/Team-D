var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
    owner = accounts[0];

  it("...add emplyee successfully.", function() {
    return Payroll.deployed().then(function(instance) {
      PayrollInst = instance;
        return PayrollInst.addEmployee(accounts[1],2);
    }).then(function() {
        return PayrollInst.employees.call(accounts[1]);
    }).then(function(employee){
        employee1 = employee[0];
    }).then(function(){
        return PayrollInst.addEmployee(accounts[2],3);
    }).then(function() {
        return PayrollInst.employees.call(accounts[2]);
    }).then(function(employee){
        employee2 = employee[0];

    }).then(function() {

      assert.equal(employee1, accounts[1], "employ1 add sucess.");
      assert.equal(employees, accounts[2], "employ2 add sucess");

    });
  });

  it("...removeEmployee test.", function() {
    return Payroll.deployed().then(function(instance) {
      PayrollInst = instance;
        PayrollInst.addEmployee(accounts[1],2);
    }).then(function() {
        PayrollInst.addFund.call({value:100});
    }).then(function(){
        return PayrollInst.removeEmployee(accounts[1]);
    }).then(function() {
        return PayrollInst.employees.call(accounts[1]);
    }).then(function(employee){
 
      assert.equal(employee[0], 0x0, "removeemploy is not sucess.");
      assert.equal(employee[1], 0, "remove salary is not sucess");

    });
  });


});
