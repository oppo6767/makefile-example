#include "test_framework.h"
/* 테스트할 기능의 헤더를 여기에 include */

/* ===== 테스트 함수들 =====
 * 검사 하나당 함수 하나. 성공이면 true, 실패면 false를 돌려준다. */
bool test_example(void) {
    return true;   /* 템플릿 동작 확인용. 실제 테스트로 바꾸거나 지우기 */
}

int main(void) {
    /* ===== 테스트 등록 ===== */
    test_register("test_example", test_example);

    /* ===== 실행: 실패 개수를 종료 코드로 돌려준다 ===== */
    return test_run_all();
}
