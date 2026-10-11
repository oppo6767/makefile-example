#pragma once
#include <stdbool.h>

/* 테스트 함수의 모양: 인자 없음, 성공이면 true / 실패면 false */
typedef bool (*TestFunc)(void);

/* 테스트 하나를 이름과 함께 표에 등록 */
void test_register(const char *name, TestFunc func);

/* 등록된 테스트를 전부 실행하고 결과 출력, 실패 개수를 돌려줌 */
int test_run_all(void);
