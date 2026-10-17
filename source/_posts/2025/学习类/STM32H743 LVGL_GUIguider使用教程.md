---
title: STM32H743 LVGL_GUIguider使用教程
date:  2025-03-13 19:10:36
tags: ["STM32","学习"]
category: ["我的生活"]
typora-root-url: ./STM32H743 LVGL_GUIguider使用教程
---

## 1. 前言
本文主要介绍如何使用GUIguider设计基于LVGL的图形界面，并移植到STM32H743上。
主要正点原子的视频很长，每次看视频都要从头开始，所以这里记录一下，方便以后查阅。
本文部分图片和内容取材自视频，详见[正点原子视频](https://www.bilibili.com/video/BV1CG4y157Px/?spm_id_from=333.788.player.switch&vd_source=dce7e2a199fb86a11795f90eb5f85296&p=1)

## 2. 下载GUIguider
GUIguider是NXP公司开发的一款图形化界面设计工具，可以用于设计基于LVGL的图形界面。  

[下载地址](https://www.nxp.com.cn/design/design-center/software/development-software/gui-guider:GUI-GUIDER)

## 3. 下载LVGL源码并改装
### 3.1. 下载源码
[下载地址](https://github.com/lvgl/lvgl/releases)

注意:需要下载和GUI-Guider一致的LVGL版本一致的源码,这里博主选择使用LVGL_8.3.10  

### 3.2. 修改并移植文件
1. 修改文件名称    
找到lv_conf_template.h文件，修改文件名为lv_conf.h。
打开lv_conf.h文件，修改以下内容：把#if 0 改为#if 1。

2. 裁剪初始文件  
裁剪过后只剩下如下文件：(注意:裁剪过程中二级文件夹内的文件不参与删改，只在lvgl-8.3.10这一级文件夹内进行裁剪)  
![剩余文件](cut.png)  

1. 创建文件夹结构：(在顶层工程文件夹下创建如下文件夹结构)  
![工程文件](structure.png)  
(这里有一点需要注意，如果你是使用cubemx生成工程的，在没有使用cubemx中的中间件模块时，顶层文件夹将缺失Middlewares文件夹，每次生成工程时都会自动将我们的Middlewares文件夹删除，所以需要手动添加，或者使用cubemx中的中间件模块，这样就不会出现这个问题了,笔者这里使用了DSP模块，因此有自动生成Middleware文件夹，文件夹内如下：)
![Middleware](Middlewares.png)

1. 将裁剪后的LVGL文件夹复制到Middlewares/LVGL/GUI/lvgl 路径下。

2. 打开工程，添加如下分组：
![分组](group.png)


1. 添加如下文件：
![文件](file.png)


1. 其他选项修改
![选项](option.png)  
(2026.3.18更新：由于现在全面接入AC6编译器而上述设置针对AC5编译器，因此这里对于**AC6编译器请无视屏蔽MDK警告**这一条，否则可能引起报错)  

## 4.  LVGL移植显示和触摸(基于正点原子屏幕，请自备对应屏幕显示工程)
### 4.1. 屏幕显示
1. 把lv_port_disp_template.c/h 的条件编译指令#if 0改为#if 1。  
2. 包含输出设备头文件  
![包含头文件](include.png)  

1. 在disp_init函数中添加屏幕初始化代码,设置为横屏  
![屏幕初始化](disp_init.png)

1. 配置图形数据缓冲模式
这里按照你的单片机性能来设置，性能较低的用1或2就行了，性能高的可以试试3模式  
(设置1024的原因是横屏之后，我的RGB屏幕一行像素点数为1024个，这个值根据你的屏幕分辨率横屏后的行像素点来设置)    
![图形数据缓冲模式](buffer.png)

1. 设置屏幕尺寸  
![屏幕尺寸](size.png)
&emsp;同样的道理，这里根据你的屏幕分辨率进行设置，横屏之后，我的屏幕分辨率为1024*600，所以这里设置为1024和600。  
1. 在disp_flush函数中添加屏幕刷新代码(打点输出)  
![屏幕刷新](disp_flush.png)
&emsp;**lcd_color_fill**函数是屏幕填充函数，这里使用的是正点原子的屏幕，所以使用的是正点原子的屏幕填充函数，这里需要根据你的屏幕进行修改。  
至此屏幕显示部分移植完成。  
### 4.2. 触摸移植
1. 把lv_port_touch_template.c/h 的条件编译指令#if 0改为#if 1。  
2. 包含触摸头文件
![触摸头文件](touch_driver_include.png)

1. 裁剪输入设备部分  
&emsp;由于这里使用的是触摸屏，因此只保留touchpad 部分，其他输入设备部分全部注释/删除，其他函数也注释/删除，只保留touchpad部分。  
![裁剪输入设备](touch_cut.png)

1. 包含输入设备驱动头文件
![输入设备驱动头文件](touch_driver_include.png)

1. 在touchpad_init函数中添加触摸初始化代码
![触摸初始化](touch_init.png)

1. 在touchpad_is_pressed函数中添加触摸检测代码
![触摸读取](touchpad_is_pressed.png)

1. 配置坐标获取函数
![坐标获取](touchpad_get_xy.png)

### 4.3. 提供时基
1. 首先配置一个定时器，这里使用的是TIM3，配置如下：(定时器溢出时间:1s,开启全局中断)  
![时基](tim3_config.png)

1. 在定时器中断回调函数中调用lv_tick_inc(x)函数，提供时基
![时基](tim3_callback.png)
&emsp;**注意**:初始化定时器时，需保证:进入中断的时间间隔=x毫秒    
至此触摸移植完成  
### 4.4 测试
1. 这边直接上图
![测试](test.png)
(cubemx生成的请记得开启定时器，并且以中断方式开启)  
如果显示正常，屏幕中应该出现了一个按钮，点击按钮如果出现响应，则移植成功。  
至此LVGL移植完成  

## LVGL GUIguider使用
1. 打开GUIguider软件，选择对应的LVGL版本
2. 选择对应的屏幕分辨率，这里自定义为1024*600
3. 之后经过一定设计之后，选择使用c语言生成，得到如下工程文件夹：
![工程文件夹](project.png)

1. 在Middlewares\LVGL\GUI_APP 路径下生成一个名为myGUI的文件夹，将生成的工程文件夹中的**custom**,**generated**两个文件夹拷贝到这个文件夹目录下。
2. 接下来将这个文件夹加入keil工程中，设置路径为 
```c 
....\Middlewares\LVGL\GUI_APP\myGUI\custom
....\Middlewares\LVGL\GUI_APP\myGUI\generated
```
1. 在main.c中添加如下代码
```c
#include “gui_guider.h” // Gui Guider 生成的界面和控件的声明
#include “events_init.h” // Gui Guider 生成的初始化事件、回调函数
lv_ui guider_ui; // 声明 界面对象
```
随后在初始化LVGL代码结束后后面加上：
```c
setup_ui(&guider_ui); // 初始化 UI
events_init(&guider_ui); // 初始化 事件
```
至此GUIguider使用介绍完成  
## 注意事项
在使用GUIguider生成代码时，请确保在keil工程中已经正确配置了LVGL，否则生成的代码将无法正常使用  
在使用GUIguider生成代码时，请确保在keil工程中已经正确配置了触摸屏，否则生成的代码将无法正常使用  
在使用GUIguider生成代码时，请确保在keil工程中已经正确配置了定时器，否则生成的代码将无法正常使用   
&emsp;2026.3.18更新：新版本GUIguider中，已经开始仅支持v8.3.10和v9.3.0两个版本，因此请确保使用这两个版本，否则可能会出现各种问题，包括但不限于生成代码无法使用等问题。