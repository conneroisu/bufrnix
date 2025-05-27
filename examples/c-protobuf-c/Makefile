CC = gcc
CFLAGS = -Wall -Wextra -I.
LDFLAGS = -lprotobuf-c

TARGET = example
TEST_TARGET = test
PROTO_DIR = proto/gen/c/protobuf-c/example/v1
PROTO_SRC = $(PROTO_DIR)/example.pb-c.c

EXAMPLE_SOURCES = main.c $(PROTO_SRC)
EXAMPLE_OBJECTS = $(EXAMPLE_SOURCES:.c=.o)

TEST_SOURCES = test.c $(PROTO_SRC)
TEST_OBJECTS = $(TEST_SOURCES:.c=.o)

.PHONY: all clean run test check

all: $(TARGET) $(TEST_TARGET)

$(TARGET): $(EXAMPLE_OBJECTS)
	$(CC) $(EXAMPLE_OBJECTS) -o $(TARGET) $(LDFLAGS)

$(TEST_TARGET): $(TEST_OBJECTS)
	$(CC) $(TEST_OBJECTS) -o $(TEST_TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TEST_TARGET)
	./$(TEST_TARGET)

check: test

clean:
	rm -f $(EXAMPLE_OBJECTS) $(TEST_OBJECTS) $(TARGET) $(TEST_TARGET)