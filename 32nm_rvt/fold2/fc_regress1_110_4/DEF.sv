//==========RNG/CNT sharing=============
// RNG and CNT sharing constant
// Defines how many weight/inputs share the same cnt/rng
// To amortize fan-out nets

//`define SHARE 16
`define SHARE 32
//`define SHARE 1 //No sharing

`define NUM_CNT (`DIM_IN*`DIM_OUT+`SHARE-1)/`SHARE
`define NUM_RNG (`DIM_IN+`SHARE-1)/`SHARE

//========Folding const for 1st FC layer=======
`define LOG_FOLD 1
`define MUX2
//`define LOG_FOLD 2
//`define MUX4


//========Binary Bit Width==============
// `define INWD3
// `define INWD4
// `define INWD5
// `define INWD6
// `define INWD7
// `define INWD8
// `define INWD9
`define INWD10

//`define DIM_110_256 // 1st FC layer config (cannot syn)
//`define DIM_64_5 //last FC layer config 1
//`define DIM_64_2 //last FC layer config 2
//=========regression config============
`define DIM_110_4
//`define DIM_110_8
//`define DIM_110_16
//`define DIM_110_32
//`define DIM_110_64


`ifdef INWD3
    `define INWD 3
    `define LOGINWD 2
`endif

`ifdef INWD4
    `define INWD 4
    `define LOGINWD 2
`endif

`ifdef INWD5
    `define INWD 5
    `define LOGINWD 3
`endif

`ifdef INWD6
    `define INWD 6
    `define LOGINWD 3
`endif

`ifdef INWD7
    `define INWD 7
    `define LOGINWD 3
`endif

`ifdef INWD8
    `define INWD 8
    `define LOGINWD 3
`endif

`ifdef INWD9
    `define INWD 9
    `define LOGINWD 4
`endif

`ifdef INWD10
    `define INWD 10
    `define LOGINWD 4
`endif

//////////Real config/////////
`ifdef DIM_110_256
    `define DIM_IN 110
    `define LOG_DIM_IN 7
    `define DIM_OUT 256
    `define DOUBLE_BUFF
    `define NP2
`ifdef MUX2
    `define FOLD 2
`endif
`ifdef MUX4
    `define FOLD 4
`endif
`endif

`ifdef DIM_64_5
    `define DIM_IN 64
    `define LOG_DIM_IN 6
    `define DIM_OUT 5
    `define HARDTANH
`endif
`ifdef DIM_64_2
    `define DIM_IN 64
    `define LOG_DIM_IN 6
    `define DIM_OUT 2
    `define HARDTANH
`endif

////////Regression config//////////
// For regression 1st FC layer
`ifdef DIM_110_4
    `define DIM_IN 110
    `define LOG_DIM_IN 7
    `define DIM_OUT 4
    `define DOUBLE_BUFF //Accucumlator double buffer version
    `define NP2 //Non-power-of-2, used for ReLU.sv
`ifdef MUX2
    `define FOLD 2
`endif
`ifdef MUX4
    `define FOLD 4
`endif
`endif

`ifdef DIM_110_8
    `define DIM_IN 110
    `define LOG_DIM_IN 7
    `define DIM_OUT 8
    `define DOUBLE_BUFF
    `define NP2
`ifdef MUX2
    `define FOLD 2
`endif
`ifdef MUX4
    `define FOLD 4
`endif
`endif

`ifdef DIM_110_16
    `define DIM_IN 110
    `define LOG_DIM_IN 7
    `define DIM_OUT 16
    `define DOUBLE_BUFF
    `define NP2
`ifdef MUX2
    `define FOLD 2
`endif
`ifdef MUX4
    `define FOLD 4
`endif
`endif

`ifdef DIM_110_32
    `define DIM_IN 110
    `define LOG_DIM_IN 7
    `define DIM_OUT 32
    `define DOUBLE_BUFF
    `define NP2
`ifdef MUX2
    `define FOLD 2
`endif
`ifdef MUX4
    `define FOLD 4
`endif
`endif

`ifdef DIM_110_64
    `define DIM_IN 110
    `define LOG_DIM_IN 7
    `define DIM_OUT 64
    `define DOUBLE_BUFF
    `define NP2
`ifdef MUX2
    `define FOLD 2
`endif
`ifdef MUX4
    `define FOLD 4
`endif
`endif
