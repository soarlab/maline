CXXFLAGS = -O2
RM = rm -rf
SRC_DIR=src
BIN_DIR=bin

SRCS = $(SRC_DIR)/parse-strace-log.cpp $(SRC_DIR)/sparsify.cpp
_OBJS = $(subst .cpp,,$(SRCS))
OBJS = $(patsubst $(SRC_DIR)%,$(BIN_DIR)%,$(_OBJS))

all: maline

maline: $(OBJS) scripts

$(BIN_DIR)/%: $(SRC_DIR)/%.cpp create_bin
	$(CXX) $(CXXFLAGS) -o $@ $<

create_bin:
	mkdir -p $(BIN_DIR)

scripts:
	find $(SRC_DIR) -not -name "*.cpp" -type f -print0 | xargs -0 cp -t $(BIN_DIR)

clean:
	$(RM) $(BIN_DIR)
