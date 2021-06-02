#include <memory>
#include <verilated.h>
#include "Vtop.h"


int main(int argc, char** argv, char** env) {
    if (false && argc && argv && env) {}

    Verilated::mkdir("logs");

    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    contextp->debug(0);
    contextp->randReset(2);
    contextp->traceEverOn(true);

    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "top"}};

    unsigned prev_hlt = 0;
    top->rst = 0;
    top->clk = 0;
    //for (int i = 0; i < 32000; i += 1) {
    while (1) {
        contextp->timeInc(1);
        
        top->clk = !top->clk;

        if (!top->clk) {
            if (contextp->time() < 5) {
                top->rst = 1;
            } else {
                top->rst = 0;
            }
        }

        top->eval();

    }

    top->final();

    return 0;
}


