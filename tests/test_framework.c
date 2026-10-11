#include <stdio.h>
#include "test_framework.h"

/* ============================================================
 * [설정] 등록할 수 있는 최대 테스트 개수
 *  "[경고] 표가 가득 차서..."가 뜨면 이 숫자를 늘리기
 * ============================================================ */
#define MAX_TESTS 10

/* ============================================================
 * [뼈대] 테스트 프레임워크 본체
 *  보통은 그대로 써도 되고, 기능을 늘리고 싶을 때 수정
 *  (예: 실패한 테스트만 출력, 테스트별 실행 시간 측정,
 *       특정 테스트 건너뛰기 등)
 * ============================================================ */

/* 테스트 한 칸: 이름 + 함수 주소 */
typedef struct {
    const char *name;
    TestFunc func;
} TestCase;

static TestCase tests[MAX_TESTS];   /* 등록 표 */
static int test_count = 0;          /* 등록된 개수 */

/* 테스트를 표의 빈칸에 등록 */
void testRegister(const char *name, TestFunc func) {
    if (test_count >= MAX_TESTS) {
        printf("[경고] 표가 가득 차서 %s는 등록 못 함\n", name);
        return;
    }

    tests[test_count].name = name;
    tests[test_count].func = func;
    test_count++;
}

/* 등록된 테스트를 차례로 부르고 결과를 세서 실패 개수를 돌려줌 */
int playTest(void) {
    int passed = 0;
    int failed = 0;

    for (int i = 0; i < test_count; i++) {
        bool result = tests[i].func();   /* 프레임워크가 내 테스트를 부름 */

        /* [설정] 결과 출력 모양
         *  %-30s = 이름을 30칸 폭으로 왼쪽 정렬, 이름 길이에 맞춰 조절 */
        if (result) {
            printf("pass func name: %-30s\n", tests[i].name);
            passed++;
        } else {
            printf("fail func name: %-30s\n", tests[i].name);
            failed++;
        }
    }

    /* [설정] 집계 출력 모양 */
    printf("pass: %d / fail: %d\n", passed, failed);
    return failed;
}
