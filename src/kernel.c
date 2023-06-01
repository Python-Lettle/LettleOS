
void io_hlt(void);

void kernel_main(void)
{
fin:
    io_hlt();
    goto fin;
}