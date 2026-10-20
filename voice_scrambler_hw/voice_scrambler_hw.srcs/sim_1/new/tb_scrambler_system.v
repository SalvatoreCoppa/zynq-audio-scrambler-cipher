`timescale 1ns / 1ps

module tb_scrambler_system();

// 1. Dichiarazione dei soli segnali utili per il testbench
    wire BCLK;
    wire FCLK_CLK1;
    wire PBDATA;
    wire PBLRCLK;
    wire RECLRCLK;
    wire [0:0] MUTE_tri_o;
    
    reg RECDAT;
    reg [1:0] SW_tri_i;

    wire IIC_1_scl_io;
    wire IIC_1_sda_io;

    // 2. Instanziazione del DUT con i pin flottanti lasciati vuoti
    design_1_wrapper DUT (
        .BCLK(BCLK),
        .DDR_addr(),
        .DDR_ba(),
        .DDR_cas_n(),
        .DDR_ck_n(),
        .DDR_ck_p(),
        .DDR_cke(),
        .DDR_cs_n(),
        .DDR_dm(),
        .DDR_dq(),
        .DDR_dqs_n(),
        .DDR_dqs_p(),
        .DDR_odt(),
        .DDR_ras_n(),
        .DDR_reset_n(),
        .DDR_we_n(),
        .FCLK_CLK1(FCLK_CLK1),
        .FIXED_IO_ddr_vrn(),
        .FIXED_IO_ddr_vrp(),
        .FIXED_IO_mio(),
        .FIXED_IO_ps_clk(),
        .FIXED_IO_ps_porb(),
        .FIXED_IO_ps_srstb(),
        .IIC_1_scl_io(IIC_1_scl_io),
        .IIC_1_sda_io(IIC_1_sda_io),
        .MUTE_tri_o(MUTE_tri_o),
        .PBDATA(PBDATA),
        .PBLRCLK(PBLRCLK),
        .RECDAT(RECDAT),
        .RECLRCLK(RECLRCLK),
        .SW_tri_i(SW_tri_i)
    );

    // -------------------------------------------------------------------------
    // 3. Macro per accedere alle API della Zynq VIP
    // -------------------------------------------------------------------------
    `define ZYNQ_VIP DUT.design_1_i.processing_system7_0.inst

    // Variabili per raccogliere le risposte del bus AXI
    reg [1:0] resp;
    reg [31:0] read_data;

// -------------------------------------------------------------------------
    // 4. Blocco Main di Simulazione
    // -------------------------------------------------------------------------
    initial begin
        // Inizializzazione degli input fisici
        RECDAT = 1'b0;
        SW_tri_i = 2'b11; // Modalità loopback (Stato 3)

        $display("==================================================");
        $display("   INIZIO SIMULAZIONE SYSTEM-LEVEL (ZYNQ VIP)     ");
        $display("==================================================");

        // A. Reset e Inizializzazione della VIP
        $display("[TIME: %0t] Reset del Processing System...", $time);
        `ZYNQ_VIP.fpga_soft_reset(32'h1);
        #200;
        `ZYNQ_VIP.fpga_soft_reset(32'h0);
        #2000;

        // =========================================================
        // FASE 1: INIZIALIZZAZIONE DEL SEED 
        // =========================================================
        $display("[TIME: %0t] FASE 1: Caricamento Seed (0x1234)...", $time);
        
        // Scrittura Seed TX
        `ZYNQ_VIP.write_data(32'h40010028, 4, 32'h00001234, resp);
        // Asserzione load_seed = 1
        `ZYNQ_VIP.write_data(32'h40010030, 4, 32'h00000001, resp);
        
        // PRIMO START: L'hardware si avvia, legge load_seed=1 e carica 0x1234 nel registro interno
        `ZYNQ_VIP.write_data(32'h40010000, 4, 32'h00000001, resp);

        // Polling: Attendiamo che l'IP abbia finito di caricare il seed
        read_data = 0;
        while ((read_data & 32'h00000002) == 0) begin
            `ZYNQ_VIP.read_data(32'h40010000, 4, read_data, resp);
            #10;
        end

        // De-asserzione load_seed = 0 (Altrimenti al prossimo start si resetta)
        `ZYNQ_VIP.write_data(32'h40010030, 4, 32'h00000000, resp);

        // =========================================================
        // FASE 2: ELABORAZIONE CAMPIONE AUDIO 
        // =========================================================
        $display("[TIME: %0t] FASE 2: Invio campione audio (x = 500)...", $time);
        
        // Scrittura del Campione Audio (x = 500 dec = 0x01F4)
        `ZYNQ_VIP.write_data(32'h40010020, 4, 32'h000001F4, resp);

        // SECONDO START: L'hardware si avvia, legge x=500, vede load_seed=0, ed esegue lo XOR
        `ZYNQ_VIP.write_data(32'h40010000, 4, 32'h00000001, resp);

        // Polling: Aspetto che il calcolo del campione finisca
        read_data = 0;
        while ((read_data & 32'h00000002) == 0) begin
            `ZYNQ_VIP.read_data(32'h40010000, 4, read_data, resp);
            #10;
        end

        // Lettura del Campione Criptato in uscita 'y'
        `ZYNQ_VIP.read_data(32'h40010010, 4, read_data, resp);
        
        $display("--------------------------------------------------");
        $display("   RISULTATO LETTO DAL BUS AXI: 0x%08X", read_data);
        $display("--------------------------------------------------");

        #1000;
        $finish;
    end

endmodule