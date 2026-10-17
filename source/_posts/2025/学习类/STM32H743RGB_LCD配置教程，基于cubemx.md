---
title: STM32H743RGB_LCD配置教程，基于cubemx
tags:
  - STM32
  - 学习
category:
  - 我的生活
password: d184a50632d4d43acc85a45ab0b37da13b75f9840b52d83b32ae24e960ccd98e
typora-root-url: ./STM32H743RGB_LCD配置教程，基于cubemx
abbrlink: 37108
date: 2025-03-07 21:10:36
---


## 本文用于记录STM32H743RGB_LCD的配置过程,基于cubemx
1. 准备工作  
    1.1. 准备好STM32H743开发板，RGBLCD屏幕，博主的屏幕为兼容正点原子排线的7寸屏  
    1.2. 准备好STM32CubeMX软件  
    1.3. 准备好Keil5软件  
    1.4. 准备好正点原子显示和触摸相关例程，官方链接：正点原子  
2. 配置步骤
    2.1. 打开STM32CubeMX软件，选择STM32H743芯片
    2.2. 配置时钟树，使能HSE和PLL
    时钟树如下：
        ![时钟树](clock.png)  
        注意：STM32H743IIT6有两个芯片版本，其中一个芯片版本只能达到400MHz，另外一个可以达到480MHz，博主使用的是480MHz版本，所以时钟树配置为480MHz  
    2.3. 配置mpu  
        ![MPU](mpu.png)  
    2.4. 配置GPIO   
        ![GPIO](gpio.png)  
    2.5. 配置定时器  
        选择TIM1为定时器，配置如下：  
        ![定时器](tim.png)  
    2.6. 配置FMC  
        这里使用的是W9825G6KH 这颗SDRAM，配置如下：  
        ![SDRAM1](sdram1.png)
        ![SDRAM2](sdram2.png)  
        这里需要注意，这里博主似乎没有配置对，但是能够根据正点官方初始化达到目的.  
        **(2025.7.24更新，，原始图像存在错误，SDRAM1图片中Data下方的Byte Enable 未被使能，导致两个GPIO未被使能，进而导致数据流紊乱绿屏，并且请将后面的SDRAM2图片中的GPIO Setting中的所有引脚全部改为上拉输出，保证正常运行)**  
    2.7. 配置UART
        ![USART](usart.png)
        这里需要注意，STM32H7不同于F1,F4，USART的引脚有多组替换方案，注意默认方案是否跟你所接的串口引脚匹配。  
    2.8. 配置DMA2D  
        ![DMA2D](dma2d.png)  
    2.9. 配置LTDC
        ![LTDC1](ltdc1.png)  
        ![LTDC2](ltdc2.png)  
        注意，cubemx自己分配的默认LTDC引脚与正点原子例程不匹配，需要手动修改引脚，修改如下：  
        ![LTDC3](ltdc3.png)
        ![LTDC4](ltdc4.png)
    2.10. 配置堆栈  
        由于后期需要UI库，建议先把堆栈调大，这里配置为0x2000    
        至此所有配置完成，点击生成代码  
    2.11. 修改代码  
        ![转移文件](folder.png)  
        请将如上代码移入工程中。  
        请自行修改相关宏定义配置错误，这里不再赘述。    
        进入fmc.c文件，将SDRAM的初始化代码注释掉，这里使用正点原子代码初始化SDRAM，否则会发生绿屏现象。
        **(2025.7.24更新，如果在上方已经将Byte Enable 使能，则这里需要将正点原子代码中的初始化SERAM的代码注释掉，否则会出现函数重复定义，两者函数在当前配置下等价)**  
        ![注释代码](comment.png)  
        迁移正点例程中的测试代码，主函数修改代码如下:(user code begin2 end2 之间)
        ![main](main.png)
    2.12. 编译下载  
    此时应该得到与正点原子例程相同的效果，显示正点原子LOGO，并且能够通过串口打印信息。  