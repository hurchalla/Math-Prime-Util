
#include "hurchalla/factoring/factorize.h"
#include "hurchalla/util/traits/ut_numeric_limits.h"
#include <inttypes.h>
#include <iostream>
#include <chrono>
#include <iomanip>
#if defined(__GNUC__)
#  include <cpuid.h>
#  include <string>
#  include <cstring>
#endif

#ifndef NDEBUG
#error "asserts are enabled and will slow performance"
#endif


typedef unsigned long UV;
//extern int factor(UV n, UV *factors);
#define MPU_MAX_FACTORS 64

extern "C" {
    int factor(UV n, UV *factors);
};


#if defined(__GNUC__)
std::string displayCPU()
{
    // this code is copied from https://stackoverflow.com/a/50021699
    // licensed CC-BY-SA-3.0  https://creativecommons.org/licenses/by-sa/3.0/
    char CPUBrandString[0x40];
    unsigned int CPUInfo[4] = {0,0,0,0};

    __get_cpuid(0x80000000, &CPUInfo[0], &CPUInfo[1], &CPUInfo[2], &CPUInfo[3]);
    unsigned int nExIds = CPUInfo[0];

    std::memset(CPUBrandString, 0, sizeof(CPUBrandString));

    for (unsigned int i = 0x80000000; i <= nExIds; ++i)
    {
        __get_cpuid(i, &CPUInfo[0], &CPUInfo[1], &CPUInfo[2], &CPUInfo[3]);

        if (i == 0x80000002)
            memcpy(CPUBrandString, CPUInfo, sizeof(CPUInfo));
        else if (i == 0x80000003)
            memcpy(CPUBrandString + 16, CPUInfo, sizeof(CPUInfo));
        else if (i == 0x80000004)
            memcpy(CPUBrandString + 32, CPUInfo, sizeof(CPUInfo));
    }
    std::string result("CPU Type: ");
    result += CPUBrandString;
    return result;
}
#endif


void test64()
{
    using namespace hurchalla;
    using namespace std::chrono;
    using dsec = duration<double>;

    using T = int64_t;
    T max = ut_numeric_limits<T>::max();
    T x;
    T end = max - 200000;

    double mpbest = 1000000000;
    double hcbest = 1000000000;

    std::cout << " \n***Math-Prime-Util***" << std::endl;
    for (int i=0; i<4; ++i) {
        auto t0 = steady_clock::now();
        for (x = max; x >= end; x = x-2) {
            int num_factors;
            static_assert(sizeof(UV) == sizeof(std::uint64_t), "");
            UV factors[MPU_MAX_FACTORS+1];
            num_factors = factor(x, factors);
            if (factors[0] == 0)
              break;
        }
        if (x >= end)
          std::cout << "impossible64" << std::endl;
        auto t1 = steady_clock::now();
        auto elapsed = dsec(t1-t0).count();
        if (elapsed < mpbest)
            mpbest = elapsed;
        std::cout << elapsed << std::endl;
    }

    std::cout << " \n***Factor-Hurchalla***" << std::endl;
    for (int i=0; i<4; ++i) {
        auto t0 = steady_clock::now();
        for (x = max; x >= end; x = x-2) {
            int num_factors;
            auto factors = factorize(x, num_factors);
            if (factors[0] == 0)
              break;
        }
        if (x >= end)
          std::cout << "impossible64" << std::endl;
        auto t1 = steady_clock::now();
        auto elapsed = dsec(t1-t0).count();
        if (elapsed < hcbest)
            hcbest = elapsed;
        std::cout << elapsed << std::endl;
    }

    std::cout << std::fixed << std::setprecision(2);
    std::cout << " \n" << mpbest/hcbest << "x speedup" << std::endl;
}


int main()
{
#if defined(__GNUC__)
   std::cout << displayCPU() << std::endl;
#endif
    test64();
}
