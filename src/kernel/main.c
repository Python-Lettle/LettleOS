/* Copyright (C) 2007 Free Software Foundation, Inc. 
 * See the copyright notice in the file /usr/LICENSE.
 * Created by flyan on 2023/9/9.
 *
 * 该文件包含LettleOS的主程序。
 *
 * 该文件的入口点是：
 *  - lettleos_main:      LettleOS的主程序
 */

int display_position = (80 * 6 + 0) * 2;     // 从第 6 行第 0 列开始显示
void low_print(char* str);

void lettleos_main(void)
{
    low_print("Hello OS!!!\n");
    while (1){}
}