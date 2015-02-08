CXXFLAGS = -g -O2
RM = rm -rf
SRC_DIR=src
BIN_DIR=bin
LIB_DIR=lib/libsvm-3.17

SRCS = $(SRC_DIR)/parse-strace-log.cpp $(SRC_DIR)/sparsify.cpp $(SRC_DIR)/create_datasets.cpp $(SRC_DIR)/transforms_data.cpp $(SRC_DIR)/create_datasets_cv.cpp
_OBJS = $(subst .cpp,,$(SRCS))
OBJS = $(patsubst $(SRC_DIR)%,$(BIN_DIR)%,$(_OBJS))

all: maline libsvm

maline: $(OBJS) scripts

$(BIN_DIR)/%: $(SRC_DIR)/%.cpp create_bin
	$(CXX) $(CXXFLAGS) -o $@ $<

create_bin:
	mkdir -p $(BIN_DIR) -m 775

libsvm:
	cd $(LIB_DIR) && make && cp svm-train ../../bin && cp svm-predict ../../bin

scripts:
	find $(SRC_DIR) -not -name "*.cpp" -type f -print0 | xargs -0 cp -t $(BIN_DIR)

clean:
	$(RM) $(BIN_DIR)
	cd $(LIB_DIR) && make clean
