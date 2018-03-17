## 硅谷live以太坊智能合约 第二课作业
这里是同学提交作业的目录

### 第二课：课后作业
完成今天的智能合约添加100ETH到合约中
- 加入十个员工，每个员工的薪水都是1ETH
每次加入一个员工后调用calculateRunway这个函数，并且记录消耗的gas是多少？Gas变化么？如果有 为什么？
- 如何优化calculateRunway这个函数来减少gas的消耗？
提交：智能合约代码，gas变化的记录，calculateRunway函数的优化

优化前：一名员工：18441gas,两名员工：21022gas,三名员工：23455gas,四名员工：26584gas。。。十名员工：38445gas。

优化方案：
增加 totalSalary 状态变量记录工资总额，并在涉及工资变化的部分重新计算工资总额，赋值给 totalSalary（具体包括新增、删除、更新员工三处），同时删除calculateRunway中通过遍历员工数组获取工资总额的方法，直接读取totalSalary 。
优化后：
添加新员工后调用calculateRunway函数所消耗的gas保持不变，不再随着员工数量增加而增加，每次消耗恒定。
