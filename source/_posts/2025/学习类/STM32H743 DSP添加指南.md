---
title: STM32H743 DSP添加指南
tags:
  - STM32
  - 学习
category:
  - 我的生活
typora-root-url: ./STM32H743 DSP添加指南
abbrlink: 64911
date: 2025-04-03 19:10:36
---

## 前言
&emsp;由于之后电赛需要经常用到这个库，而市面上的教程基本上都是基于原装DSP下载导入的，这里写一篇基于STM32CubeMX的添加指南，方便之后使用。  
&emsp;重要：本博文主要用于DSP的直接配置，并没有运行示例，可以保证配置完成后可以使用

### 1. 打开STM32CubeMX 配置工程
&emsp;进入配置主界面之后，点击Software packs,出现如下内容。
![software packs](software_packs.png)


&emsp;我们要选择第一个select components，然后会出现如下页面。  
![components](components.png)


&emsp;点击红圈中内容，会出现一个搜索框，我们输入DSP，然后选择第一个DSP库。  
![DSP](DSP.png)


&emsp;点击OK,然后再到侧边栏，找到Middleware and Software Packs -> X-CUBE-ALGOBUILD,这里我们勾选上DSP Library.  
![DSP_Library](DSP_Library.png)


&emsp;然后点击右上角的GENERATE CODE,生成代码,cubemx端的DSP配置内容就算结束了,其余可以配置串口方便查看结果。

### 2. 修改宏定义
&emsp;生成代码之后，打开工程，找到上方魔法棒，点击后点击C/C++板块，如下图  
![C/C++](C_C++.png)


&emsp;在Define中添加如下内容：(每个宏定义之间用英文逗号隔开)  

```c
ARM_MATH_CM7,__CC_ARM,ARM_MATH_MATRIX_CHECK,ARM_MATH_ROUNDING
```
(2026.3.18更新：由于AC6编译器替代AC5编译器是大势所趋，因此如果使用AC6编译器，需要删掉其中一个宏定义避免编译器报错，最终为如下宏定义：)
```c
ARM_MATH_CM7,ARM_MATH_MATRIX_CHECK,ARM_MATH_ROUNDING
```

### 3.添加工程
&emsp;打开”三方块”,新增文件夹Drivers/DSP,然后在工程目录下找到：
```c
    工程名文件夹/Drivers/CMSIS/DSP/Lib/ARM/arm_cortexM7lfdp_math.lib
    工程名文件夹/Drivers/CMSIS/DSP/Include/arm_common_tables.h
    工程名文件夹/Drivers/CMSIS/DSP/Include/arm_const_structs.h
    工程名文件夹/Drivers/CMSIS/DSP/Include/arm_math.h
```

&emsp;将以上文件加入新增文件夹  
![Drivers](drivers.png)
### 4. 添加代码
&emsp;在main函数中添加如下代码(例程参考了正点原子的例程)：

```c
/* USER CODE BEGIN Includes */
#include "stdio.h"
#include "printf.h"
#include "arm_math.h"
/* USER CODE END Includes */


/* USER CODE BEGIN PV */
arm_cfft_radix4_instance_f32 scfft;//定义scfft结构体
#define FFT_LENGTH      1024

float fft_inputbuf[FFT_LENGTH * 2];             /* FFT输入数组 */
float fft_outputbuf[FFT_LENGTH];                /* FFT输出数组 */
/* USER CODE END PV */


/* USER CODE BEGIN 2 */
arm_cfft_radix4_init_f32(&scfft,1024,0,1);//初始化scfft结构体
/* USER CODE END 2 */

/* USER CODE BEGIN 3 */
while (1)
{
    /* USER CODE END WHILE */
    /* USER CODE BEGIN 3 */
    for (i = 0; i < FFT_LENGTH; i++)        /* 生成信号序列 */
    {
        fft_inputbuf[2 * i] = 100 +
                              10 * arm_sin_f32(2 * PI * i / FFT_LENGTH) +
                              30 * arm_sin_f32(2 * PI * i * 4 / FFT_LENGTH) +
                              50 * arm_cos_f32(2 * PI * i * 8 / FFT_LENGTH);    /* 生成输入信号实部 */
        fft_inputbuf[2 * i + 1] = 0;        /* 虚部全部为0 */
    }
    arm_cfft_radix4_f32(&scfft, fft_inputbuf);                  /* FFT计算（基4） */
    printf("FFT变换结果：\r\n");
    for(int i=0;i<1024;i++)
    {
        printf("%f\r\n",fft_outputbuf[i]);
    }
    HAL_Delay(1000);
    /* USER CODE END 3 */
}
```
打开串口，如果得到如下结果则可以证明移植成功  
![result](result.png)
