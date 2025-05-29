CC = gcc
CFLAGS = -Wall -Wextra -I. -I/nix/store/mvgyx36jmxwplhl6ab2kfrw7hdv25iw6-nanopb-0.4.9.1/include/nanopb
LDFLAGS = -L/nix/store/mvgyx36jmxwplhl6ab2kfrw7hdv25iw6-nanopb-0.4.9.1/lib -lprotobuf-nanopb

TARGET = sensor_example
TEST_TARGET = test_example
PROTO_DIR = proto/gen/c/nanopb/example/v1
PROTO_SRC = $(PROTO_DIR)/sensor.pb.c

EXAMPLE_SOURCES = main.c $(PROTO_SRC)
EXAMPLE_OBJECTS = $(EXAMPLE_SOURCES:.c=.o)

TEST_SOURCES = test.c $(PROTO_SRC)
TEST_OBJECTS = $(TEST_SOURCES:.c=.o)

# Find nanopb runtime sources - fallback to common locations
NANOPB_DIR = $(shell pkg-config --variable=prefix nanopb 2>/dev/null || echo /usr/local)
NANOPB_RUNTIME = $(wildcard $(NANOPB_DIR)/share/nanopb/*.c)
ifeq ($(NANOPB_RUNTIME),)
    # Fallback: look for pb_*.c in the proto gen directory or use embedded
    NANOPB_RUNTIME = $(wildcard $(PROTO_DIR)/pb_*.c)
endif

.PHONY: all clean run test check

all: $(TARGET) $(TEST_TARGET)

$(TARGET): $(EXAMPLE_OBJECTS)
	$(CC) $(EXAMPLE_OBJECTS) $(NANOPB_RUNTIME) -o $(TARGET) $(LDFLAGS)

$(TEST_TARGET): $(TEST_OBJECTS)
	$(CC) $(TEST_OBJECTS) $(NANOPB_RUNTIME) -o $(TEST_TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TEST_TARGET)
	./$(TEST_TARGET)

check: test

clean:
	rm -f $(EXAMPLE_OBJECTS) $(TEST_OBJECTS) $(TARGET) $(TEST_TARGET)