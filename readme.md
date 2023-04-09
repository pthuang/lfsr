# LSFR ON FPGA

+   封面

![封面](https://raw.githubusercontent.com/pthuang/mdimage/main/202304091610317.svg)

[TOC]
[开源地址](https://github.com/pthuang/lsfr)

[图片加载不出来？点这里查看pdf](https://github.com/pthuang/lsfr/blob/master/doc/readme.pdf)

------

## 1.迭代日志

项目开发中，待完善......

+   2021/09/02 modify log:

    1.   完成galois型lsfr开发：

         +   文件名：galois_lsfr.v；

         +   具体内容：

             完成V1.0版本模块开发与仿真，只支持3~16bit，代码不规范，通用性不强，仿真用例简单。

+   2023/03/19 modify log:

    1.   完成fibonacci型lsfr开发：

         +   文件名：fibonacci_lsfr.v；

         +   具体内容：

             完成代码开发与仿真，支持3-->128bit；

    2.   galois型lsfr更新到V2.0版本：

         +   文件名：galois_lsfr.v；

         +   模块名：galois_lsfr；

         +   具体内容：

             支持bit数更新为3-->20,32,64,128bit；

+   2023/04/08 modify log:
    1.   完成matlab代码（用于生成抽头矩阵verilog代码）；
    2.   完成所有模块代码更新；
    3.   修改仿真do脚本文件，优化文件管理结构；

+   2023/04/08 modify log:
    1.   完成部分markdown文档编写；



------

## 2.项目简介

+   本项目是一个用于FPGA平台的LSFR模块代码；
+   使用Verilog HDL语言进行开发；
+   主要目的是为了方便FPGA工程师做接口的数据校验工作，如SERDES、DDR、JESD、SRIO等高速接口，还有以太网、UART、SPI、IIC等接口的通信链路(读写/收发)测试；
+   用winsows批处理加do文件脚本在Modelsim上进行仿真验证（独立仿真）；
+   参考了Xilinx的xapp052.pdf文件中提供的高达168bit的本原多项式抽头；
+   包含Galois和Fibonacci两种类型LSFR的实现；



------

## 3.原理介绍

+   什么是LSFR？

    >   [维基百科LSFR](https://en.wikipedia.org/wiki/Linear-feedback_shift_register)



LSFR即Linear-feedback shift register，线性反馈移位寄存器，就是一种带反馈的移位寄存器，通过抽头系数进行反馈，使得移位寄存器的输出符合某种规律；

根据反馈抽头方法的不同，包括以下两种构型：

**Galois型（one-to-many）**：

<img 				       src="https://raw.githubusercontent.com/pthuang/mdimage/main/202304092113455.png" alt="20200225172052494" style="zoom:80%;" />



Galois型又叫one-to-many型，从图中可以看出，每一触发器的D端是前一触发器的Q端和抽头结果异或（同或）的结果，抽头系数g的取值只有0和1两种结果，即抽头或者不抽头，抽头的位置是同一个位置，即最高位（最低位）；从同一个位置（one）抽头，反馈到不同寄存器的D端（many），所以叫他ont-to-many。



**Fabonacci型(many-to-one)**：

<img src="https://raw.githubusercontent.com/pthuang/mdimage/main/202304092113458.png" alt="20200225172109639" style="zoom:80%;" />

Fabonacci型又叫many-to-one型，从图中可以看出，所有的抽头的异或（many）反馈到同一个触发器的D端，，所以叫他ont-to-many。



------

## 4.详细设计

+   文件管理结构说明

###### 





+   运行方法

    

    

    

+   注意事项

    















------

## 5.开发者有话说





























