---
title: STM32LCD屏幕移植纸质教程
date: 2024-02-19 15:33:08
tags: "STM32"
---

## 声明
本教程诣在简化移植的流程，参考[视频](https://www.bilibili.com/video/BV1fN41147mA/?spm_id_from=333.788.recommend_more_video.-1)进行步骤和流程的精简化。如有侵权，请告知我，我将删除。

## 步骤1 新建cubemx文件
设置时钟以及你所需要的库。
注：LCD屏幕应该是你最后迁移的内容，返工重新部署可能会导致项目出错。
### 要点
需要在Project manager->code generate中将原先勾选仅保留需要的库文件改为勾选保留全部的库文件。

## 步骤2 迁移文件
1.将正点原子例程文件->LCD样例文件(hal库版本)打开，打开其中的BSP文件夹，复制LCD文件夹。  
2.在创建好的cubemx工程文件中新建一个BSP文件夹，将刚刚复制的LCD文件夹粘贴到其中

## 步骤3 设置新的文件夹和文件寻址
1.打开keil5工程，点击方块堆，在Groups中添加"/Drivers/BSP"，保存后退出。   
2.点击魔法棒，选中(C/C++)窗口，看到下方的"includes paths",点击后面的三个点，点击空白文本框新建新的文件路径，再次点击后面三个点，将文件目录选择到BSP文件夹后点（选择文件夹）保存后退出。    
3.点击左侧工程栏目中的BSP文件夹，右键添加文件，将lcd.c和lcd.ex.c添加进该文件夹。  

## 步骤4 修改代码
1.打开lcd.c,将所有文件寻址从"./BSP/LCD/..."改为"./LCD/...";接下来删去"stdlib.h""usart.h"两个库。
2.打开lcd.ex.c,将所有文件寻址从"./BSP/LCD/..."改为"./LCD/...";接下来删去"delay.h"库。
3.打开lcd.h,删去"sys.h"库,添加"main.h"。
4.在main.c中添加如下代码：  
```C
/**
  * @brief  延时函数
  * @param  ms 延时多少秒
  * @retval 无
  */
void delay_ms(uint32_t ms)
{
	uint32_t ms_uwTick=uwTick;
	while (uwTick-ms_uwTick<ms);
	
}
```
然后在main.h中加入函数声明以便lcd.ex.c使用。
5.编译lcd.ex.c,将所有的`delay_us()`函数替换为上述函数。再次编译查看问题。无误后将该文件从文件夹中去除。
6.打开main.h->stm32f103xx_hal.h->stm32f103_hal_conf.h,将被注释掉的SRAM取消注释。再次编译运行。
7.选中stm32f1xx_hal_driver文件夹，添加sram和fsmc的C文件，再次编译运行，此时应该只剩下一个错误(uart)
8.定位到错误的UART位置，将该行进行注释，再次编译可得0错误0警告。
## 写在最后
如果你的文件在上述步骤之后成功运行，但是你在之后再次使用cubemx重新部署工程，请直接跳转到步骤4->第六步