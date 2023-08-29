
int display_position = (80 * 6 + 0) * 2;
void low_print(char * str);

int kernel_main ()
{
    low_print("Hello Lettle OS!!!\n");
    while (1) {}
}