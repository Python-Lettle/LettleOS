//
// Created by Lettle on 2021/7/12.
//

// 显示位置: 第 6 行 第 0 列
int display_position = (80 * 6 + 0) * 2;

void printf(char* str);
void lettle_os(void)
{
    printf("Hello, Lettle OS!!!\n");
    printf("This is the second line!!\n");
    while(1){}
}