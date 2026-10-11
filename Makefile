# ============================================================
#  범용 Makefile 템플릿 (C / C++ / Java / Python)
#
#  사용법
#   1. 이 파일을 새 프로젝트 폴더에 복사
#   2. [설정 구역]에서 LANGUAGE와 필요한 값만 수정
#   3. make init  -> 언어에 맞는 폴더 구조 자동 생성
#   4. make / make run / make test / make clean
#
#  기준 환경: Git Bash / MSYS2 / Linux / macOS (sh 계열 셸)
#  주의: 설정 값 줄 끝에 주석(#)을 붙이지 말 것 (값에 공백이 섞임)
# ============================================================


# ------------------------------------------------------------
# [설정 구역] 프로젝트마다 여기만 바꾸기
# ------------------------------------------------------------

# 사용할 언어: c | cpp | java | py
LANGUAGE := c

# 실행 파일 이름 (c/cpp 전용, 윈도우에서는 .exe 자동 부착)
APP_NAME := main

# 프로그램 시작점
#  c/cpp : main 함수가 있는 파일 이름 (확장자 빼고)      예) main
#  java  : main 메서드가 있는 클래스 전체 이름            예) Main, com.example.Main
#  py    : 처음 실행할 파일 이름 (확장자 빼고, src 기준)   예) main
ENTRY := main

# 테스트 시작점 (java 전용: 테스트용 main이 있는 클래스 이름)
TEST_ENTRY := TestMain

# --- C / C++ 전용 ---
C_STD   := c11
CPP_STD := c++17
# 디버깅할 땐 -O0 -g, 배포할 땐 -O2
OPT_FLAGS := -O2
# 외부 라이브러리 헤더 폴더 (안 쓰면 비워두기)
EXT_INC_DIRS :=
# 외부 라이브러리 파일(.a/.so) 폴더 (안 쓰면 비워두기)
EXT_LIB_DIRS :=
# 링크할 라이브러리 이름, -l 없이 (예: raylib opengl32 gdi32 winmm)
EXT_LIBS :=
# 본 프로그램에만 붙일 링크 옵션 (예: -mwindows)
APP_ONLY_LDFLAGS :=
# 정적 링크 옵션 (예: -static -static-libgcc)
STATIC_LDFLAGS :=

# --- Java 전용 ---
# 외부 .jar 파일을 넣어둘 폴더
JAVA_LIB_DIR := libs

# --- Python 전용 ---
# 비워두면 자동 (윈도우: python, 그 외: python3)
PYTHON :=

# 실행할 때 넘길 인자 (make run ARGS="a b c" 처럼 명령줄에서도 지정 가능)
ARGS :=


# ------------------------------------------------------------
# [공통 규칙 구역] 여기부터는 보통 수정할 필요 없음
# ------------------------------------------------------------

SRC_DIR   := src
INC_DIR   := include
TEST_DIR  := tests
BUILD_DIR := build

# 언어 값 검사
ifeq ($(filter $(LANGUAGE),c cpp java py),)
    $(error LANGUAGE 값이 잘못됐습니다: '$(LANGUAGE)' (c, cpp, java, py 중 하나))
endif

# 운영체제별 차이
ifeq ($(OS),Windows_NT)
    EXE      := .exe
    PATHSEP  := ;
    PY_AUTO  := python
else
    EXE      :=
    PATHSEP  := :
    PY_AUTO  := python3
endif

ifeq ($(strip $(PYTHON)),)
    PYTHON := $(PY_AUTO)
endif

# 공백 문자 (경로 목록을 ; 또는 : 로 잇는 데 사용)
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

# 하위 폴더까지 전부 뒤지는 파일 탐색 함수
#  사용: $(call rwildcard,폴더,*.확장자)
rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

.DEFAULT_GOAL := all
.PHONY: all build run test clean init

all: build


# ============================================================
#  C / C++
# ============================================================
ifneq ($(filter $(LANGUAGE),c cpp),)

ifeq ($(LANGUAGE),c)
    COMPILER := gcc
    SRC_EXT  := c
    STD_FLAG := -std=$(C_STD)
else
    COMPILER := g++
    SRC_EXT  := cpp
    STD_FLAG := -std=$(CPP_STD)
endif

OBJ_DIR     := $(BUILD_DIR)/obj
TARGET      := $(BUILD_DIR)/$(APP_NAME)$(EXE)
TEST_TARGET := $(BUILD_DIR)/test_runner$(EXE)

# -MMD -MP : 헤더(.h)가 바뀌면 그 헤더를 쓰는 소스도 자동 재컴파일
CFLAGS  := -Wall -Wextra $(STD_FLAG) $(OPT_FLAGS) -MMD -MP \
           -I$(INC_DIR) $(addprefix -I,$(EXT_INC_DIRS))
LDFLAGS := $(addprefix -L,$(EXT_LIB_DIRS)) $(STATIC_LDFLAGS)
LDLIBS  := $(addprefix -l,$(EXT_LIBS))

SRCS      := $(call rwildcard,$(SRC_DIR),*.$(SRC_EXT))
TEST_SRCS := $(call rwildcard,$(TEST_DIR),*.$(SRC_EXT))

OBJS      := $(patsubst $(SRC_DIR)/%.$(SRC_EXT),$(OBJ_DIR)/src/%.o,$(SRCS))
TEST_OBJS := $(patsubst $(TEST_DIR)/%.$(SRC_EXT),$(OBJ_DIR)/tests/%.o,$(TEST_SRCS))

# 테스트 빌드 시 main 중복 방지: 본 프로그램의 시작점 .o 제외
MAIN_OBJ          := $(OBJ_DIR)/src/$(ENTRY).o
OBJS_WITHOUT_MAIN := $(filter-out $(MAIN_OBJ),$(OBJS))

DEPS := $(OBJS:.o=.d) $(TEST_OBJS:.o=.d)

build: $(TARGET)

# [링크] 본 프로그램
$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	$(COMPILER) $^ -o $@ $(LDFLAGS) $(APP_ONLY_LDFLAGS) $(LDLIBS)

# [링크] 테스트 프로그램 (tests 안의 소스 중 하나에 main이 있어야 함)
$(TEST_TARGET): $(OBJS_WITHOUT_MAIN) $(TEST_OBJS)
	@mkdir -p $(dir $@)
	$(COMPILER) $^ -o $@ $(LDFLAGS) $(LDLIBS)

# [컴파일] src -> build/obj/src
$(OBJ_DIR)/src/%.o: $(SRC_DIR)/%.$(SRC_EXT)
	@mkdir -p $(dir $@)
	$(COMPILER) $(CFLAGS) -c $< -o $@

# [컴파일] tests -> build/obj/tests
$(OBJ_DIR)/tests/%.o: $(TEST_DIR)/%.$(SRC_EXT)
	@mkdir -p $(dir $@)
	$(COMPILER) $(CFLAGS) -c $< -o $@

run: build
	./$(TARGET) $(ARGS)

test: $(TEST_TARGET)
	@echo "------------ 테스트 실행 ------------"
	./$(TEST_TARGET)

init:
	mkdir -p $(SRC_DIR) $(INC_DIR) $(TEST_DIR)

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)

endif


# ============================================================
#  Java
# ============================================================
ifeq ($(LANGUAGE),java)

CLASS_DIR      := $(BUILD_DIR)/classes
TEST_CLASS_DIR := $(BUILD_DIR)/test-classes

JAVA_SRCS := $(call rwildcard,$(SRC_DIR),*.java)
TEST_SRCS := $(call rwildcard,$(TEST_DIR),*.java)
JARS      := $(wildcard $(JAVA_LIB_DIR)/*.jar)

# 클래스패스 (윈도우는 ; , 그 외는 : 로 연결)
CP      := $(subst $(SPACE),$(PATHSEP),$(strip $(CLASS_DIR) $(JARS)))
TEST_CP := $(subst $(SPACE),$(PATHSEP),$(strip $(TEST_CLASS_DIR) $(CLASS_DIR) $(JARS)))

# 소스가 바뀌었는지 기록하는 표시 파일
STAMP      := $(CLASS_DIR)/.compiled
TEST_STAMP := $(TEST_CLASS_DIR)/.compiled

build: $(STAMP)

$(STAMP): $(JAVA_SRCS)
	@mkdir -p $(CLASS_DIR)
	javac -d $(CLASS_DIR) -cp "$(CP)" $(JAVA_SRCS)
	@touch $@

$(TEST_STAMP): $(TEST_SRCS) $(STAMP)
	@mkdir -p $(TEST_CLASS_DIR)
	javac -d $(TEST_CLASS_DIR) -cp "$(TEST_CP)" $(TEST_SRCS)
	@touch $@

run: build
	java -cp "$(CP)" $(ENTRY) $(ARGS)

test: $(TEST_STAMP)
	@echo "------------ 테스트 실행 ------------"
	java -cp "$(TEST_CP)" $(TEST_ENTRY)

init:
	mkdir -p $(SRC_DIR) $(TEST_DIR) $(JAVA_LIB_DIR)

clean:
	rm -rf $(BUILD_DIR)

endif


# ============================================================
#  Python
# ============================================================
ifeq ($(LANGUAGE),py)

# 파이썬은 컴파일이 없으므로 build = 문법 검사
build:
	$(PYTHON) -m compileall -q $(SRC_DIR)

run:
	$(PYTHON) $(SRC_DIR)/$(ENTRY).py $(ARGS)

# tests 폴더 안의 test*.py 파일을 자동으로 찾아 실행
# (src 폴더를 import 경로에 추가해서 테스트에서 src 모듈을 불러올 수 있음)
test:
	@echo "------------ 테스트 실행 ------------"
	PYTHONPATH=$(SRC_DIR) $(PYTHON) -m unittest discover -s $(TEST_DIR) -v

init:
	mkdir -p $(SRC_DIR) $(TEST_DIR)

clean:
	rm -rf $(BUILD_DIR)
	find . -name "__pycache__" -type d -prune -exec rm -rf {} +

endif