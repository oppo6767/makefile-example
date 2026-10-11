#include "test_framework.h"
/* [수정] 테스트할 기능의 헤더를 여기에 include */

/* ============================================================
 * [수정] 테스트 함수들
 *  이름 규칙: test_ + 검사 대상 + 기대 동작
 *  검사 하나당 함수 하나, 성공이면 true / 실패면 false
 * ============================================================ */
bool test_example_always_pass(void) {
    return true;   /* 템플릿 동작 확인용. 실제 테스트로 바꾸거나 지우기 */
}

int main(void) {
    /* [수정] 테스트 등록 (등록 이름 = 함수 이름) */
    testRegister("test_example_always_pass", test_example_always_pass);

    /* 실행: 실패 개수를 종료 코드로 돌려준다 (수정 X) */
    return playTest();
}
