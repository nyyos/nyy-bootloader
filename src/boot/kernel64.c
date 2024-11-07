#include <stdint.h>

void _start(void) {
    // Initialize kernel and print a simple message
    const char *msg = "Loaded kernel64!";
    char *video_memory = (char *)0xB8000;
    int i = 0;
    while (msg[i] != '\0') {
        video_memory[i * 2] = msg[i];
        video_memory[i * 2 + 1] = 0x07; // White text on black background
        i++;
    }

    // Hang the system after printing the message
    while (1) {
        asm("hlt");
    }
}
