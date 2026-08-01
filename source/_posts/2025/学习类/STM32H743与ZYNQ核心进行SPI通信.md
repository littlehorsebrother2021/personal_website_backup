---
title: STM32H743与ZYNQ核心进行SPI通信
tags:
  - STM32
  - 学习
category:
  - 我的生活
typora-root-url: ./STM32H743与ZYNQ核心进行SPI通信
abbrlink: 40148
date: 2025-04-10 19:10:36
---


## 前言
&emsp;这个东西是我和做FPGA的队友搞了很久才成功的一个技术，技术复杂，变量非常多，通信失败的概率很大，所以记录一下，方便以后查阅。
&emsp;*** 注意 ***：这里只有STM32的部分，ZYNQ/FPGA的代码和配置请参考别的博客。整体是16bit通信

### 第一部分 通信原理与速率设置
&emsp;STM32H743与ZYNQ核心进行SPI通信，首先需要了解SPI通信的原理，SPI是一种高速全双工通信协议，它使用4根线进行通信，分别是SCK、MOSI、MISO和NSS。其中，SCK是时钟线，MOSI是主设备输出从设备输入线，MISO是从设备输出主设备输入线，NSS是片选线，用于选择从设备。SPI通信的速率由SCK的频率决定，SCK的频率越高，通信速率越快。  
&emsp;STM32H743与ZYNQ核心进行SPI通信，需要设置SPI的速率，这里需要参考ZYNQ那边采样的频率设置，然后根据STM32H743的时钟频率进行设置，一般来说，通信速率控制在4M以下是比较稳定的，如果通信速率过高，可能会导致通信失败，或者通信内容丢失，具体表现为当STM32H743向ZYNQ核心发送数据时，ZYNQ核心接收到的数据不完整，ZYNQ核心设置输入等于输出(等价MOSI和MISO短接)时，如果使用串口打印查看接收数据，会发现数据有明显的出错。因此，在设置SPI通信速率时，需要根据实际情况进行调整，以保证通信的稳定性和可靠性。

### 第二部分 SPI接线的线材选择
&emsp;STM32 和 ZYNQ 进行通信时，如果你的32板子上存在那种SPI软排线接口，我非常建议你使用这种接口，因为经过我们的实测，这种接口的通信速率比普通的SPI接口要高，而且稳定性也更好。如果32板子上没有这种接口，那么你可以使用普通的SPI接口，或者如果你会EDA，你可以做一块转接板用软排线。如果你没有办法只能使用杜邦线点对点链接，那么你一定需要注意线材的选择，尽量选择质量好的线材，以保证通信的稳定性和可靠性。最致命和最令人头疼的地方就在这里，当时我们最开始使用了质量不是很好的杜邦线，导致通信速率不稳定，数据丢失，在代码里面找了很久的BUG，结果最终发现是线材的问题。  

### 第三部分 STM32H743的SPI配置
&emsp;STM32H743的SPI配置,这里采用DMA，配置如下：  

#### CUBEMX配置
&emsp;禁用STM32H743 Cortex-M7中的内容，这里不使用内存保护，因为后面SPI使用DMA1通道，如果使用常规的内存保护，会导致DMA1通道无法使用。  
![CORTEX_M7](CORTEX_M7.png)  

#### SPI设置
![SPI](SPI.png)  
&emsp;另外注意，如果你的通信速率非常高，请在引脚界面将引脚速度提到非常高,CUBEMX不会自动把它提高
![SPI引脚](SPI_PIN.png)

#### DMA设置
![DMA](DMA.png)


&emsp;这里正常的配置就结束了，如果你需要查看接收数据，可以开一个USART串口用于查看，这里就不赘述了。 
### 第四部分 代码部分
```c
//定义变量
volatile int spi_flag = 0;//SPI传输完成标志
uint16_t j = 0;//循环变量
uint16_t spi_txbuff[1];//发送变量数组
uint16_t spi_rxbuff[1];//接收变量数组

//SPI中断回调函数
void HAL_SPI_TxRxCpltCallback(SPI_HandleTypeDef *hspi)//SPI接收完成回调函数
{
    if (hspi == &hspi2)
    {
        spi_flag = 1;
    }
}

//在主函数这个部分添加
/* USER CODE BEGIN 2 */
	if (HAL_SPI_TransmitReceive_DMA(&hspi2, (uint8_t *)&spi_txbuff, (uint8_t *)&spi_rxbuff, 1) != HAL_OK) {
        HAL_GPIO_WritePin(SPI2_NSS_GPIO_Port, SPI2_NSS_Pin, GPIO_PIN_SET);
        //printf("error\n");
	}
/* USER CODE END 2 */

//主函数while (1)中添加：
if (spi_flag)
    {
        spi_flag = 0;
        spi_txbuff[0] = j;
        HAL_SPI_TransmitReceive_DMA(&hspi2, (uint8_t *)spi_txbuff, (uint8_t *)spi_rxbuff,1);
        j++;
        if (j > 0xFFFF)
        {
            j = 0;
        }
    }
```
&emsp;最终效果应该是，STM32H743向ZYNQ核心发送数据，ZYNQ核心接收数据，然后ZYNQ核心将接收到数据，如果ZYNQ端查看到数据的话将是类似锯齿波的波形(0-65535)  