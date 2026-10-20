#include "zybo_audio.h"
#include <stdio.h>
#include <xil_io.h>
#include <sleep.h>
#include "xiicps.h"
#include <xil_printf.h>
#include <xparameters.h>

#include "xscrambler.h"
#include "xuartps.h"
#include "xscutimer.h"
#include "xscugic.h"

typedef short		Xint16;
typedef long		Xint32;
#define TIMER_FREQ_HZ (XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ / 2)

unsigned char IicConfig(unsigned int DeviceIdPS);
void AudioWriteToReg(unsigned char u8RegAddr, short u16Data);
void LineinLineoutConfig();

XIicPs Iic;
XScuTimer TimerInstance;

// Istanze HW degli Scrambler
XScrambler scrambler_tx;
XScrambler descrambler_rx;

// Interrupt Controller Instance
XScuGic ScuGic;

// Variabili globali usate dalle ISR per segnalare che il calcolo è pronto
int ResultAvailScrambler_tx, ResultAvailScrambler_rx;

// Inizializzazione degli IP HLS Scrambler
int hls_scrambler_init(XScrambler *scramblerPtr_tx, XScrambler *descramblerPtr_rx)
{
    XScrambler_Config *cfgPtr_tx, *cfgPtr_rx;
    int status;

    // Configura il TX (Scrambler 0 nello schema a blocchi)
    cfgPtr_tx = XScrambler_LookupConfig(XPAR_XSCRAMBLER_1_DEVICE_ID);
    if (!cfgPtr_tx) {
        print("ERROR: Lookup of TX Scrambler configuration failed.\n\r");
        return XST_FAILURE;
    }
    status = XScrambler_CfgInitialize(scramblerPtr_tx, cfgPtr_tx);
    if (status != XST_SUCCESS) {
        print("ERROR: Could not initialize TX Scrambler.\n\r");
        return XST_FAILURE;
    }

    // Configura l'RX (Scrambler 1 nello schema a blocchi)
    cfgPtr_rx = XScrambler_LookupConfig(XPAR_XSCRAMBLER_0_DEVICE_ID);
    if (!cfgPtr_rx) {
        print("ERROR: Lookup of RX Descrambler configuration failed.\n\r");
        return XST_FAILURE;
    }
    status = XScrambler_CfgInitialize(descramblerPtr_rx, cfgPtr_rx);
    if (status != XST_SUCCESS) {
        print("ERROR: Could not initialize RX Descrambler.\n\r");
        return XST_FAILURE;
    }

    return status;
}

int TimerInitialize(void)
{
	int Status;
	XScuTimer *TimerInstancePtr = &TimerInstance;
	XScuTimer_Config *ConfigTmrPtr;

	ConfigTmrPtr = XScuTimer_LookupConfig(XPAR_PS7_SCUTIMER_0_DEVICE_ID);
	Status = XScuTimer_CfgInitialize(TimerInstancePtr, ConfigTmrPtr, ConfigTmrPtr->BaseAddr);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	XScuTimer_SetPrescaler(TimerInstancePtr, 0);
	return Status;
}

void TimerDelay(u32 uSDelay)
{
	u32 timerCnt;
	timerCnt = (TIMER_FREQ_HZ / 1000000) * uSDelay;
	XScuTimer_Stop(&TimerInstance);
	XScuTimer_DisableAutoReload(&TimerInstance);
	XScuTimer_LoadTimer(&TimerInstance, timerCnt);
	XScuTimer_Start(&TimerInstance);
	while (XScuTimer_GetCounterValue(&TimerInstance)) {}
	return;
}

// ISR per il TX
void hls_scrambler_tx_isr(void *InstancePtr)
{
    XScrambler *pAccelerator = (XScrambler *)InstancePtr;
    XScrambler_InterruptClear(pAccelerator, 1);
    ResultAvailScrambler_tx = 1;
}

// ISR per l'RX
void hls_descrambler_rx_isr(void *InstancePtr)
{
    XScrambler *pAccelerator = (XScrambler *)InstancePtr;
    XScrambler_InterruptClear(pAccelerator, 1);
    ResultAvailScrambler_rx = 1;
}

int setup_interrupt()
{
    int result;
    XScuGic_Config *pCfg = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
    if (pCfg == NULL) return XST_FAILURE;

    result = XScuGic_CfgInitialize(&ScuGic, pCfg, pCfg->CpuBaseAddress);
    if(result != XST_SUCCESS) return result;

    result = XScuGic_SelfTest(&ScuGic);
    if(result != XST_SUCCESS) return result;

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &ScuGic);
    Xil_ExceptionEnable();

    // Connette ISR del TX (VEC_ID 1 mappato su SCRAMBLER_TX_INTERRUPT_INTR)
    result = XScuGic_Connect(&ScuGic, XPAR_FABRIC_SCRAMBLER_1_VEC_ID, (Xil_InterruptHandler)hls_scrambler_tx_isr, &scrambler_tx);
    if(result != XST_SUCCESS) return result;

    // Connette ISR dell'RX (VEC_ID 0 mappato su SCRAMBLER_RX_INTERRUPT_INTR)
    result = XScuGic_Connect(&ScuGic, XPAR_FABRIC_SCRAMBLER_0_VEC_ID, (Xil_InterruptHandler)hls_descrambler_rx_isr, &descrambler_rx);
    if(result != XST_SUCCESS) return result;

    XScuGic_Enable(&ScuGic, XPAR_FABRIC_SCRAMBLER_0_VEC_ID);
    XScuGic_Enable(&ScuGic, XPAR_FABRIC_SCRAMBLER_1_VEC_ID);
    return XST_SUCCESS;
}

void filter_or_bypass_input(void)
{
	unsigned long u32DataL, u32DataR;
	unsigned long u32Temp;
	int sw_check;
	int last_sw_check = -1; // Memoria per capire se è cambiata la configurazione degli switch

	while (1)
	{
		// --- 1. LETTURA UART NON BLOCCANTE (Gestione da Tastiera PC) ---
		if (XUartPs_IsReceiveData(XPAR_PS7_UART_1_BASEADDR)) {
			u8 tasto = XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET);

			if (tasto == 'd') { // Tasto 'd' = Desincronizza l'RX di proposito
				xil_printf("\n\r[ATTENZIONE] Desincronizzazione forzata!\n\r");
				XScrambler_Set_seed(&descrambler_rx, 0xFFFF);
				XScrambler_Set_load_seed(&descrambler_rx, 1);
				XScrambler_Start(&descrambler_rx);
				while(!XScrambler_IsDone(&descrambler_rx));
				XScrambler_Set_load_seed(&descrambler_rx, 0);
			}
			else if (tasto == 's') { // Tasto 's' = Sincronizza
				xil_printf("\n\r[OK] Sincronizzazione ripristinata!\n\r");
				// Forza un ricaricamento muovendo il last_sw_check
				last_sw_check = -1;
			}
		}

		// --- 2. LETTURA AUDIO E SWITCH ---
		do { u32Temp = Xil_In32(I2S_STATUS_REG); } while (u32Temp == 0);
		Xil_Out32(I2S_STATUS_REG, 0x00000001); // Clear data rdy bit

		u32DataL = Xil_In32(I2S_DATA_RX_L_REG);
		u32DataR = Xil_In32(I2S_DATA_RX_R_REG);

		sw_check = Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + 8);

		// --- 3. AUTO-SINCRONIZZAZIONE AL CAMBIO SWITCH ---
		if (sw_check != last_sw_check) {
			xil_printf("Cambio modalita' rilevato. Riallineo le chiavi...\n\r");
			// Ricarica il TX
			XScrambler_Set_seed(&scrambler_tx, 0x1234);
			XScrambler_Set_load_seed(&scrambler_tx, 1);
			XScrambler_Start(&scrambler_tx);
			while(!XScrambler_IsDone(&scrambler_tx));
			XScrambler_Set_load_seed(&scrambler_tx, 0);

			// Ricarica l'RX
			XScrambler_Set_seed(&descrambler_rx, 0x1234);
			XScrambler_Set_load_seed(&descrambler_rx, 1);
			XScrambler_Start(&descrambler_rx);
			while(!XScrambler_IsDone(&descrambler_rx));
			XScrambler_Set_load_seed(&descrambler_rx, 0);

			last_sw_check = sw_check; // Aggiorna lo stato
		}

		// --- 4. ROUTING ---
		if (sw_check == 0) {
			// Caso 0: BYPASS (Voce pulita)
		}
		else if (sw_check == 1) {
			// Caso 1: SOLO TX -> RUMORE
			XScrambler_Set_x(&scrambler_tx, u32DataL >> 8);
			ResultAvailScrambler_tx = 0;
			XScrambler_Start(&scrambler_tx);
			while(!ResultAvailScrambler_tx){};

			u32DataL = XScrambler_Get_y(&scrambler_tx);
			u32DataR = u32DataL;

			u32DataL = u32DataL << 8;
			u32DataR = u32DataR << 8;
		}
		else if (sw_check == 2) {
			// Caso 2: SOLO RX -> RUMORE (Dimostra la simmetria)
			XScrambler_Set_x(&descrambler_rx, u32DataL >> 8);
			ResultAvailScrambler_rx = 0;
			XScrambler_Start(&descrambler_rx);
			while(!ResultAvailScrambler_rx){};

			u32DataL = XScrambler_Get_y(&descrambler_rx);
			u32DataR = u32DataL;

			u32DataL = u32DataL << 8;
			u32DataR = u32DataR << 8;
		}
		else if (sw_check == 3) {
			// Caso 3: CASCATA (Cripta e Decripta) -> VOCE PULITA
			XScrambler_Set_x(&scrambler_tx, u32DataL >> 8);
			ResultAvailScrambler_tx = 0;
			XScrambler_Start(&scrambler_tx);
			while(!ResultAvailScrambler_tx){};
			short encrypted_sample = XScrambler_Get_y(&scrambler_tx);

			XScrambler_Set_x(&descrambler_rx, encrypted_sample);
			ResultAvailScrambler_rx = 0;
			XScrambler_Start(&descrambler_rx);
			while(!ResultAvailScrambler_rx){};
			u32DataL = XScrambler_Get_y(&descrambler_rx);
			u32DataR = u32DataL;

			u32DataL = u32DataL << 8;
			u32DataR = u32DataR << 8;
		}

		Xil_Out32(I2S_DATA_TX_L_REG, u32DataL);
		Xil_Out32(I2S_DATA_TX_R_REG, u32DataR);
	}
}


int main(void)
{
	int status;

	IicConfig(XPAR_XIICPS_0_DEVICE_ID);
	TimerInitialize();
	LineinLineoutConfig();
	xil_printf("ADAU1761 configured\n\r");

	// Disabilita il MUTE tramite accesso crudo in memoria (Come faceva il prof)
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR, 0b1);

	// Setup degli Scrambler
	status = hls_scrambler_init(&scrambler_tx, &descrambler_rx);
    if(status != XST_SUCCESS) return(-1);

    // Setup degli interrupt
    status = setup_interrupt();
    if(status != XST_SUCCESS) return(-1);

    // Abilita gli interrupt globali per gli IP
    XScrambler_InterruptEnable(&scrambler_tx, 1);
    XScrambler_InterruptGlobalEnable(&scrambler_tx);
    XScrambler_InterruptEnable(&descrambler_rx, 1);
    XScrambler_InterruptGlobalEnable(&descrambler_rx);

	ResultAvailScrambler_tx = 0;
	ResultAvailScrambler_rx = 0;

    // --- Inizializzazione della CHIAVE CRITTOGRAFICA ---
    // Questo è l'unico pezzo nuovo: carichiamo lo stesso SEED (es. 0x1234) in entrambi i blocchi
    // per farli partire sincronizzati.
    XScrambler_Set_seed(&scrambler_tx, 0x1234);
    XScrambler_Set_load_seed(&scrambler_tx, 1);
    XScrambler_Start(&scrambler_tx);
    while(!XScrambler_IsDone(&scrambler_tx));
    XScrambler_Set_load_seed(&scrambler_tx, 0);

    XScrambler_Set_seed(&descrambler_rx, 0x1234);
    XScrambler_Set_load_seed(&descrambler_rx, 1);
    XScrambler_Start(&descrambler_rx);
    while(!XScrambler_IsDone(&descrambler_rx));
    XScrambler_Set_load_seed(&descrambler_rx, 0);
    // ----------------------------------------------------

	filter_or_bypass_input();
	return 0;
}

unsigned char IicConfig(unsigned int DeviceIdPS)
{

	XIicPs_Config *Config;
	int Status;

	//Initialize the IIC driver so that it's ready to use
	//Look up the configuration in the config table, then initialize it.
	Config = XIicPs_LookupConfig(DeviceIdPS);
	if(NULL == Config) {
		return XST_FAILURE;
	}

	Status = XIicPs_CfgInitialize(&Iic, Config, Config->BaseAddress);
	if(Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	//Set the IIC serial clock rate.
	XIicPs_SetSClk(&Iic, IIC_SCLK_RATE);

	return XST_SUCCESS;
}


/******************************************************************************
 * Function to write 9-bits to one of the registers from the audio
 * controller.
 * @param	u8RegAddr is the register address.
 * @param	u16Data is the data word to write ( only least significant 9 bits).
  * @return	none.
 *****************************************************************************/
void AudioWriteToReg(unsigned char u8RegAddr, short u16Data) {

	unsigned char u8TxData[2];

	u8TxData[0] = (u8RegAddr << 1 ) | ((u16Data >> 8) & 0x01); // append msb of 9-bit data to the reg addr after shifting left
	u8TxData[1] = u16Data & 0xFF;

	XIicPs_MasterSendPolled(&Iic, u8TxData, 2, IIC_SLAVE_ADDR);
	while(XIicPs_BusIsBusy(&Iic));
}

/******************************************************************************
 * Configures Line-In input, ADC's, DAC's, Line-Out and HP-Out.
 * @param   none.
 * @return	none.
 *****************************************************************************/
void LineinLineoutConfig() {

	// software reset
	AudioWriteToReg(R15_SOFTWARE_RESET, 0x000);
	TimerDelay(75000);
	// power mgmt: 0_00110010=>0,Power up, power up, OSC dn, out off, DAC up, ADC up, MIC off, LineIn up
	//	AudioWriteToReg(R6_POWER_MANAGEMENT, 0x030);
	AudioWriteToReg(R6_POWER_MANAGEMENT, 0x032);
	// left ADC Input: 0_01010111=>0,mute disable, Line volume 0 dB
	AudioWriteToReg(R0_LEFT_ADC_INPUT,0x017);
	// right ADC Input: 0_00010111=>0,mute disable, Line volume 0 dB
	AudioWriteToReg(R1_RIGHT_ADC_INPUT,0x017);
	AudioWriteToReg(R2_LEFT_DAC_VOLUME,0x079);
	AudioWriteToReg(R3_RIGHT_DAC_VOLUME,0x079);
	// analog audio path: 0_00010010=>0,-6 dB side attenuation, sidetone off, DAC selected, bypass disabled, line input, mic mute disabled, 0 dB mic
	AudioWriteToReg(R4_ANALOG_AUDIO_PATH, 0x012);
	// digital audio path: 0_00000000=>0_000, clear offset, no mute, no de-emphasize, adc high-pass filter enabled
	AudioWriteToReg(R5_DIGITAL_AUDIO_PATH, 0x000);
	// digital audio interface: 0_00001110=>0, BCLK not inverted, slave mode, no l-r swap, normal LRC and PBRC, 24-bit, I2S mode
	AudioWriteToReg(R7_DIGITAL_AUDIO_INTERFACE, 0x00A);
	TimerDelay(75000);
	// Digital core:0_00000001=>0_0000000, activate core
	AudioWriteToReg(R9_ACTIVE, 0x001);
	// power mgmt: 0_00100010 0_Power up, power up, OSC dn, out ON, DAC up, ADC up, MIC off, LineIn up
	AudioWriteToReg(R6_POWER_MANAGEMENT, 0x022); // power mgmt: 001100010 turn on OUT

}

