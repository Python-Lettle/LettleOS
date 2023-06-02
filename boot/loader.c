/* ****************************************************
 * LettleOS 启动流程
 * 1. CPU启动后加载BIOS到内存并执行
 * 2. BIOS初始化设备, 设置中断，
 *    读取启动介质第一个扇区到内存中并跳转到这里运行
 * 3. boot loader储存在第一个扇区，由它接管控制权
 * 4. boot.asm首先执行，设置进入32位保护模式然后跳入C语言部分
 */
#include <defs.h>

#define SECTSIZE 512
#define ELFHDR   ()

static void waitdisk(void)
{
    
}

void kernel_main(void)
{
    
}