var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
    var payroll;
    var admin = accounts[0];
    var employee = accounts[1];
    var salary = 1;

    it("Test addEmployee by admin.", function () {
        return Payroll.deployed().then(contract => {
            payroll = contract;
            return payroll.add(employee, salary, {
                from: admin
            });
        }).then(() => {
            return payroll.employees(employee);
        }).then(profile => {
            assert.notEqual(profile[0], 0, "Fail to add new employee.");
        });
    });

    it("Test addEmployee & removeEmployee.", function () {
        return Payroll.deployed().then(contract => {
            payroll = contract;
            return payroll.addFund({
                value: web3.toWei(1000, 'ether'),
                from: admin
            });
        }).then(() => {
            return payroll.add(employee, salary, {
                from: admin
            });
        }).then(() => {
            return payroll.employees(employee);
        }).then(profile => {
            assert.notEqual(profile[0], 0, "Fail to add new employee.");
            return payroll.remove(employee, {
                from: admin
            });
        }).then(() => {
            assert.equal
            return payroll.employees(employee);
        }).then(profile => {
            assert.equal(profile[0], 0, "Fail to remove employee.");
        }).catch(error => {
            console.log(error);
        });
    });

    var payDration = 11;
    var lastRunway;
    it("Test getPaid.", function () {
        return Payroll.deployed().then(contract => {
            payroll = contract;
            return payroll.add(employee, salary, {
                from: admin
            });
        }).then(() => {
            return web3.currentProvider.send({
                jsonrpc: "2.0",
                method: "evm_increaseTime",
                params: [payDration],
                id: 0
            });
        }).then(() => {
            return payroll.addFund({
                value: web3.toWei(1000, 'ether'),
                from: admin
            });
        }).then(() => {
            return payroll.calculateRunway();
        }).then(runway => {
            assert.notEqual(runway > 0, "Fail to try addFund, no enough fund for paid.");
            lastRunway = runway;
            return payroll.getPaid({
                from: employee
            });
        }).then(() => {
            return payroll.calculateRunway();
        }).then(runway => {
            assert.notEqual(runway, lastRunway, "Fail to call getPaid.");
        }).catch(error => {
            console.log(error);
        });
    });
});