/* STM32_3: polling SPI, Mode 0, 8 bits, MSB first. No MISO wire. */
#include "ece2_474.h"
#include "stm32_3_task.h"
volatile uint8_t spi_last_tx = 0, spi_last_rx = 0;
volatile uint32_t spi_tx_count = 0, spi_rx_count = 0;
volatile uint32_t spi_timeout_count = 0, spi_error_count = 0;
volatile HAL_StatusTypeDef spi_last_status = HAL_OK;
#if !STM32_3_RX
static uint32_t last_tx_ms;
#if SPI_CYCLE_PATTERNS
static const uint8_t patterns[4] = {0x55, 0xA5, 0x00, 0xFF};
static uint32_t pattern_index;
#endif
#endif
void ece2_474_init(void)
{
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port, SPI_CS_ece2_Pin, GPIO_PIN_SET);
#if STM32_3_RX
    /* Receiver only: external CS is PA4, not PB6. */
    if (HAL_SPI_DeInit(&hspi1) != HAL_OK) Error_Handler();
    hspi1.Init.Mode = SPI_MODE_SLAVE;
    hspi1.Init.NSS = SPI_NSS_HARD_INPUT;
    if (HAL_SPI_Init(&hspi1) != HAL_OK) Error_Handler();
    __HAL_RCC_GPIOA_CLK_ENABLE();
    GPIO_InitTypeDef gpio = {0};
    gpio.Pin = GPIO_PIN_4;
    gpio.Mode = GPIO_MODE_AF_PP;
    gpio.Pull = GPIO_PULLUP;
    gpio.Speed = GPIO_SPEED_FREQ_LOW;
    gpio.Alternate = GPIO_AF5_SPI1;
    HAL_GPIO_Init(GPIOA, &gpio);
#endif
    printf("\r\nSTM32_3 Task %d | SPI %s | Mode0, 8bit, MSB first\r\n",
           STM32_3_TASK, STM32_3_RX ? "SLAVE RX" : "MASTER TX");
    printf("SCK=PB3 MOSI=PA7 CS=%s; common GND; MISO unconnected\r\n",
           STM32_3_RX ? "PA4 (NSS input)" : "PB6 (output)");
#if !STM32_3_RX
    last_tx_ms = HAL_GetTick();
#endif
}
void polling_routine(void)
{
#if STM32_3_RX
    uint8_t rx = 0;
    HAL_StatusTypeDef result = HAL_SPI_Receive(&hspi1, &rx, 1U, 2000U);
    spi_last_status = result;
    if (result == HAL_OK) {
        spi_last_rx = rx;
        ++spi_rx_count;
        printf("RX=%02X\r\n", (unsigned int)rx);
    } else if (result == HAL_TIMEOUT) {
        ++spi_timeout_count;
        printf("RX timeout: check sender, SCK, MOSI, CS and GND\r\n");
    } else {
        ++spi_error_count;
        printf("RX error=%d\r\n", (int)result);
    }
#else
    uint32_t now_ms = HAL_GetTick();
    if ((uint32_t)(now_ms - last_tx_ms) < 1000U) return;
    last_tx_ms = now_ms;
#if SPI_CYCLE_PATTERNS
    uint8_t tx = patterns[pattern_index];
    pattern_index = (pattern_index + 1U) % 4U;
#else
    uint8_t tx = (uint8_t)SPI_TEST_BYTE;
#endif
    spi_last_tx = tx;
    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port, SPI_CS_ece2_Pin, GPIO_PIN_RESET);
    HAL_StatusTypeDef result = HAL_SPI_Transmit(&hspi1, &tx, 1U, 100U);
    /* Release CS on success AND on error/timeout. */
    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port, SPI_CS_ece2_Pin, GPIO_PIN_SET);
    spi_last_status = result;
    if (result == HAL_OK) ++spi_tx_count;
    else ++spi_error_count;
    printf("TX=%02X, result=%d\r\n", (unsigned int)tx, (int)result);
#endif
}

/* 1. 사용자 버튼 PC13을 눌렀을 때 호출됩니다. 우선순위: 7.
 * 버튼의 접점 때문에 한 번 눌러도 여러 번 호출될 수 있습니다.
 */
static void button_isr_p7(void)
{
    /* 실습 코드 작성: 버튼 이벤트를 기록하거나 LED 상태를 변경합니다. */
}

/* 2. TIM6를 인터럽트 방식으로 시작하면 100 ms마다 호출됩니다. 우선순위: 4.
 * 시작 호출: HAL_TIM_Base_Start_IT(&htim6);
 */
static void tim6_isr_p4(void)
{
    /* 실습 코드 작성: 횟수를 세거나 메인 루프에서 처리할 표시를 남깁니다. */
}

/* 3. PC 통신 UART2의 요청한 수신이 완료되면 호출됩니다. 우선순위: 6.
 * 먼저 수신 버퍼를 준비하고 HAL_UART_Receive_IT로 수신을 요청해야 합니다.
 * 다음 입력도 받으려면 처리 후 수신을 다시 요청합니다.
 * 현재 표준 입력은 기다리는 방식입니다. 같은 UART의 인터럽트 수신과 함께 쓰지 않습니다.
 */
static void uart2_isr_p6(void)
{
    /* 실습 코드 작성: PC 수신 버퍼를 처리하고 다음 수신을 요청합니다. */
}

/* 4. FPGA 통신 UART3의 요청한 수신이 완료되면 호출됩니다. 우선순위: 5.
 * 먼저 수신 버퍼를 준비하고 HAL_UART_Receive_IT로 수신을 요청해야 합니다.
 * 다음 입력도 받으려면 처리 후 수신을 다시 요청합니다.
 */
static void uart3_isr_p5(void)
{
    /* 실습 코드 작성: FPGA 수신 버퍼를 처리하고 다음 수신을 요청합니다. */
}

/* PA0: 풀업 입력의 HIGH -> LOW 변화. 우선순위: 8. */
static void gpio_in_pullup_isr_p8_ece2(void)
{
    /* 실습 코드 작성 */
}

/* PA1: 풀다운 입력의 LOW -> HIGH 변화. 우선순위: 9. */
static void gpio_in_pulldown_isr_p9_ece2(void)
{
    /* 실습 코드 작성 */
}

/* 아래는 HAL 콜백과 실습 함수를 연결하는 코드입니다. */

/* CubeMX의 EXTI 처리 코드에서 버튼 실습 함수로 연결합니다. */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    if (GPIO_Pin == BUTTON_ece2_Pin)
    {
        button_isr_p7();
    }
    else if (GPIO_Pin == GPIO_IN_PULLUP_ece2_Pin)
    {
        gpio_in_pullup_isr_p8_ece2();
    }
    else if (GPIO_Pin == GPIO_IN_PULLDOWN_ece2_Pin)
    {
        gpio_in_pulldown_isr_p9_ece2();
    }
}

/* CubeMX의 타이머 처리 코드에서 TIM6 실습 함수로 연결합니다. */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == TIM6)
    {
        tim6_isr_p4();
    }
}

/* UART 수신 완료 시 PC 통신과 FPGA 통신을 구분합니다. */
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
    if (huart->Instance == USART2)
    {
        uart2_isr_p6();
    }
    else if (huart->Instance == USART3)
    {
        uart3_isr_p5();
    }
}
