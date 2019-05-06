/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  ** This notice applies to any and all portions of this file
  * that are not between comment pairs USER CODE BEGIN and
  * USER CODE END. Other portions of this file, whether 
  * inserted by the user or by software development tools
  * are owned by their respective copyright owners.
  *
  * COPYRIGHT(c) 2019 STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *   1. Redistributions of source code must retain the above copyright notice,
  *      this list of conditions and the following disclaimer.
  *   2. Redistributions in binary form must reproduce the above copyright notice,
  *      this list of conditions and the following disclaimer in the documentation
  *      and/or other materials provided with the distribution.
  *   3. Neither the name of STMicroelectronics nor the names of its contributors
  *      may be used to endorse or promote products derived from this software
  *      without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdlib.h>
#include <string.h>
#include "stm32f4xx_hal.h"
#include "ws2812b.h"
#include "ws2812b_fx.h"


/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
SPI_HandleTypeDef hspi1;
DMA_HandleTypeDef hdma_spi1_tx;

TIM_HandleTypeDef htim2;

UART_HandleTypeDef huart6;
DMA_HandleTypeDef hdma_usart6_rx;

/* USER CODE BEGIN PV */
uint8_t rx_buffer[13];
ws2812b_color co1;
int msec_counter = 0, sec_counter = 0, min_counter = 0, min_alarm = 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_USART6_UART_Init(void);
static void MX_SPI1_Init(void);
static void MX_TIM2_Init(void);
/* USER CODE BEGIN PFP */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim){
	WS2812BFX_SysTickCallback();	// FX effects software timers
	if(min_alarm > 0){
		msec_counter++;
		if(msec_counter == 1000){
			msec_counter = 0;
			sec_counter++;
		}
		if(sec_counter == 60){
			sec_counter = 0;
			min_counter++;
		}
		if(min_counter == min_alarm){
			WS2812BFX_SetSpeed(0, 12);
			WS2812BFX_SetColorRGB(0, 255, 0, 0);
			WS2812BFX_SetColorRGB(1, 0, 0, 255);
			co1.red = 0;
			co1.green = 0;
			co1.blue = 0;
			WS2812BFX_SetMode(0, FX_MODE_FADE_DUAL);	// Set mode segment 0
			min_alarm = 0;
		}
	}
}
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
	  int tem = 0, tmp2 = 0;
	  char c1[4], c2[4], c3[4], alarm[6];
	  c1[4] = '\0';
	  c2[4] = '\0';
	  c3[4] = '\0';
	  alarm[6] = '\0';

	  if(rx_buffer[0] == '0'){
		WS2812BFX_SetSpeed(0, 1);
		WS2812BFX_SetColorRGB(0, co1.red, co1.green, co1.blue);	// Set color 1
		WS2812BFX_SetColorRGB(1, 0,0,0);	// Set color 1
		co1.red = 0;
		co1.green = 0;
		co1.blue = 0;
		WS2812BFX_SetMode(0, FX_MODE_FADE);
	  }

	  if(rx_buffer[0] == '1'){
		WS2812BFX_SetSpeed(0, 1);
		WS2812BFX_SetColorRGB(0, co1.red, co1.green, co1.blue);	// Set color 1
		WS2812BFX_SetColorRGB(1, 255,255,255);	// Set color 1
		co1.red = 255;
		co1.green = 255;
		co1.blue = 255;
		WS2812BFX_SetMode(0, FX_MODE_FADE);
	  }

	  if(rx_buffer[0] == '2'){
		  for(uint8_t j = 2; j < 13; j++){
			  if(rx_buffer[j] == '-'){
				  tem++;
				  tmp2 = 0;
				  continue;
			  }
			  if(tem==0){
				  c1[tmp2] = rx_buffer[j];
				  tmp2++;
			  }
			  if(tem==1){
				  c2[tmp2] = rx_buffer[j];
				  tmp2++;
			  }
			  if(tem==2){
				  c3[tmp2] = rx_buffer[j];
				  tmp2++;
				  if(tmp2 == 3) break;
			  }
		  }
		  int col1 = strtol( c1,NULL, 10);
		  int col2 = atoi(c2);
		  int col3 = atoi(c3);

		  WS2812BFX_SetSpeed(0, 1);
		  WS2812BFX_SetColorRGB(0, co1.red, co1.green, co1.blue);
		  WS2812BFX_SetColorRGB(1, col1, col2, col3);
		  co1.red = col1;
		  co1.green = col2;
		  co1.blue = col3;
		  WS2812BFX_SetMode(0, FX_MODE_FADE);	// Set mode segment 0
	  }
	  if(rx_buffer[0] == '3'){
		  // NATURE
		  if(rx_buffer[1] == '-' && rx_buffer[2] == '0'){
			  WS2812BFX_SetSpeed(0, 80);
			  WS2812BFX_SetColorRGB(0, 0, 64, 0);
			  WS2812BFX_SetColorRGB(1, 128, 255, 0);
			  co1.red = 0;
			  co1.green = 0;
		  	  co1.blue = 0;
		  	  WS2812BFX_SetMode(0, FX_MODE_FADE_DUAL);	// Set mode segment 0
		  }
		  // CANDLE
		  if(rx_buffer[1] == '-' && rx_buffer[2] == '1'){
			  WS2812BFX_SetSpeed(0, 20);
			  WS2812BFX_SetColorRGB(0, 255, 60, 0);
			  WS2812BFX_SetColorRGB(1, 224, 20, 0);
			  co1.red = 0;
			  co1.green = 0;
			  co1.blue = 0;
			  WS2812BFX_SetMode(0, FX_MODE_FADE_DUAL);	// Set mode segment 0
		  }
		  // FIRE
		  if(rx_buffer[1] == '-' && rx_buffer[2] == '2'){
			  WS2812BFX_SetSpeed(0, 80);
 			  WS2812BFX_SetColorRGB(0, 128, 0, 0);
			  co1.red = 0;
		  	  co1.green = 0;
		  	  co1.blue = 0;
		  	  WS2812BFX_SetMode(0, FX_MODE_RUNNING_LIGHTS);	// Set mode segment 0
		  }
		  // RAINBOW
		  if(rx_buffer[1] == '-' && rx_buffer[2] == '3'){
			  WS2812BFX_SetSpeed(0, 50);
			  co1.red = 0;
			  co1.green = 0;
			  co1.blue = 0;
		  	  WS2812BFX_SetMode(0, FX_MODE_RAINBOW);	// Set mode segment 0
		  }
		  // ROYAL
		  if(rx_buffer[1] == '-' && rx_buffer[2] == '4'){
			  WS2812BFX_SetSpeed(0, 30);
 			  WS2812BFX_SetColorRGB(0, 180,0,0);
 			  WS2812BFX_SetColorRGB(1, 139,0,70);
			  co1.red = 0;
			  co1.green = 0;
			  co1.blue = 0;
			  WS2812BFX_SetMode(0, FX_MODE_FADE_DUAL);	// Set mode segment 0
		  }
		  // OCEAN
		  if(rx_buffer[1] == '-' && rx_buffer[2] == '5'){
			  WS2812BFX_SetSpeed(0, 100);
			  WS2812BFX_SetColorRGB(0, 0, 106, 255);
			  WS2812BFX_SetColorRGB(1, 0 ,4,214);
			  co1.red = 0;
			  co1.green = 0;
			  co1.blue = 0;
			  WS2812BFX_SetMode(0, FX_MODE_FADE_DUAL);	// Set mode segment 0
		  }
	  }
	  if(rx_buffer[0] == '5'){
		  for(uint8_t j = 2; j < 7; j++){
			  alarm[tem] = rx_buffer[j];
			  tem++;
		  }
		  msec_counter = 0;
		  sec_counter = 0;
		  min_counter = 0;
		  min_alarm = atoi(alarm);
	  }
	  HAL_UART_Receive_DMA(&huart6, rx_buffer, 15);
}
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_USART6_UART_Init();
  MX_SPI1_Init();
  MX_TIM2_Init();
  /* USER CODE BEGIN 2 */
  HAL_TIM_Base_Start_IT(&htim2);

  WS2812B_Init(&hspi1);
  WS2812BFX_Init(1);
  co1.red = 0;
  co1.green = 0;
  co1.blue = 0;
  WS2812BFX_Start(0);
  WS2812BFX_SetSpeed(0, 2);
  WS2812BFX_SetColorRGB(0,0,0,0);
  WS2812BFX_SetColorRGB(1, 0,0,0);	// Set color 1
  WS2812BFX_SetMode(0, FX_MODE_FADE);

  HAL_UART_Receive_DMA(&huart6, rx_buffer, 15);
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {

	  WS2812BFX_Callback();	// FX effects calllback

    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /**Configure the main internal regulator output voltage 
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);
  /**Initializes the CPU, AHB and APB busses clocks 
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 96;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }
  /**Initializes the CPU, AHB and APB busses clocks 
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV2;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_1) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief SPI1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_SPI1_Init(void)
{

  /* USER CODE BEGIN SPI1_Init 0 */

  /* USER CODE END SPI1_Init 0 */

  /* USER CODE BEGIN SPI1_Init 1 */

  /* USER CODE END SPI1_Init 1 */
  /* SPI1 parameter configuration*/
  hspi1.Instance = SPI1;
  hspi1.Init.Mode = SPI_MODE_MASTER;
  hspi1.Init.Direction = SPI_DIRECTION_2LINES;
  hspi1.Init.DataSize = SPI_DATASIZE_8BIT;
  hspi1.Init.CLKPolarity = SPI_POLARITY_LOW;
  hspi1.Init.CLKPhase = SPI_PHASE_1EDGE;
  hspi1.Init.NSS = SPI_NSS_SOFT;
  hspi1.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_8;
  hspi1.Init.FirstBit = SPI_FIRSTBIT_MSB;
  hspi1.Init.TIMode = SPI_TIMODE_DISABLE;
  hspi1.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
  hspi1.Init.CRCPolynomial = 10;
  if (HAL_SPI_Init(&hspi1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SPI1_Init 2 */

  /* USER CODE END SPI1_Init 2 */

}

/**
  * @brief TIM2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM2_Init(void)
{

  /* USER CODE BEGIN TIM2_Init 0 */

  /* USER CODE END TIM2_Init 0 */

  TIM_ClockConfigTypeDef sClockSourceConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};

  /* USER CODE BEGIN TIM2_Init 1 */

  /* USER CODE END TIM2_Init 1 */
  htim2.Instance = TIM2;
  htim2.Init.Prescaler = 4799;
  htim2.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim2.Init.Period = 9;
  htim2.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  if (HAL_TIM_Base_Init(&htim2) != HAL_OK)
  {
    Error_Handler();
  }
  sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
  if (HAL_TIM_ConfigClockSource(&htim2, &sClockSourceConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim2, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM2_Init 2 */

  /* USER CODE END TIM2_Init 2 */

}

/**
  * @brief USART6 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART6_UART_Init(void)
{

  /* USER CODE BEGIN USART6_Init 0 */

  /* USER CODE END USART6_Init 0 */

  /* USER CODE BEGIN USART6_Init 1 */

  /* USER CODE END USART6_Init 1 */
  huart6.Instance = USART6;
  huart6.Init.BaudRate = 9600;
  huart6.Init.WordLength = UART_WORDLENGTH_8B;
  huart6.Init.StopBits = UART_STOPBITS_1;
  huart6.Init.Parity = UART_PARITY_NONE;
  huart6.Init.Mode = UART_MODE_TX_RX;
  huart6.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart6.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart6) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART6_Init 2 */

  /* USER CODE END USART6_Init 2 */

}

/** 
  * Enable DMA controller clock
  */
static void MX_DMA_Init(void) 
{
  /* DMA controller clock enable */
  __HAL_RCC_DMA2_CLK_ENABLE();

  /* DMA interrupt init */
  /* DMA2_Stream1_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA2_Stream1_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA2_Stream1_IRQn);
  /* DMA2_Stream3_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA2_Stream3_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA2_Stream3_IRQn);

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOC_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12|GPIO_PIN_13|GPIO_PIN_14|GPIO_PIN_15, GPIO_PIN_RESET);

  /*Configure GPIO pins : PD12 PD13 PD14 PD15 */
  GPIO_InitStruct.Pin = GPIO_PIN_12|GPIO_PIN_13|GPIO_PIN_14|GPIO_PIN_15;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */

  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{ 
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
