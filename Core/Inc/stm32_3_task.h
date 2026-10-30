#ifndef STM32_3_TASK_H
#define STM32_3_TASK_H
#ifndef STM32_3_TASK
#define STM32_3_TASK 8
#endif
#ifndef STM32_3_RX
#define STM32_3_RX 0
#endif
#ifndef SPI_TEST_BYTE
#define SPI_TEST_BYTE 0x55
#endif
#ifndef SPI_CYCLE_PATTERNS
#define SPI_CYCLE_PATTERNS 1
#endif
#if SPI_TEST_BYTE < 0 || SPI_TEST_BYTE > 255
#error "SPI_TEST_BYTE must fit in one byte"
#endif
#endif
