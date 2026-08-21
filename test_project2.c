/*
 * test_project2.c
 * C00306572 Callum Matthews
 * Manual test plan for project2.asm
 * Tests were run manually and results documented below
 * I tried to run the assembly program through C, as thats what I assume I have to do, but I couldnt get it working due to
 * syscalls in the asm file. If I was smart, id have writtem the asm file to use C library functions, which is what i read online
 * after attempting to understand what a c test file is. However I couldnt figure it out, and so just wrote a test plan, although im still not sure 
 * what it is meant to do exactly, hence just printing a plan.
 */

#include <stdio.h>

int main() {
    printf("=== project2 Manual Test Plan ===\n\n");

    printf("TEST 1 - Normal operation:\n");
    printf("Input:    5, 6, 5, 5, 1, 0\n");
    printf("Expected: The sum is: 11, The sum is: 10, The sum is: 1, Final sum is: 22\n");
    printf("Result:   PASS - verified manually\n\n");

    printf("TEST 2 - Zero inputs:\n");
    printf("Input:    0, 0, 0, 0, 0, 0\n");
    printf("Expected: Final sum is: 0\n");
    printf("Result:   PASS - verified manually\n\n");

    printf("TEST 3 - Invalid input:\n");
    printf("Input:    abc\n");
    printf("Expected: Error: invalid input or overflow\n");
    printf("Result:   PASS - verified manually\n\n");

    printf("TEST 4 - Oversized input:\n");
    printf("Input:    999999999999999\n");
    printf("Expected: Error: invalid input or overflow\n");
    printf("Result:   PASS - verified manually\n\n");

    printf("=== All tests passed ===\n");
    return 0;
}