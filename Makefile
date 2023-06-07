# GNU Make 4.4.1

TARGET	= vulkanite-server


CC		= cc
CFLAGS	= -Wall -Wextra -pedantic
LDFLAGS	= 

CFLAGS_FILE	= .cflags

SRCDIR	= src
OBJDIR	= obj

SRC		= $(wildcard $(SRCDIR)/*.c)
OBJ		= $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRC))


.PHONY: all verify_cflags optimized debug clean install uninstall


all: $(OBJDIR) verify_cflags $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) -c $< -o $@ $(CFLAGS)

$(OBJDIR):
	@mkdir -p $(OBJDIR)

optimized:
	@$(eval CFLAGS+=-O2)
	@make all CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" --no-print-directory

debug:
	@$(eval CFLAGS+=-fsanitize=address -g)
	@$(eval LDFLAGS+=-fsanitize=address)
	@make all CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" --no-print-directory
	@gdb $(TARGET)

clean:
	@if [ -d obj ]; then \
		rm -frv $(OBJDIR); \
	else \
		printf "Already clean.\n"; \
	fi
	@rm -fv $(CFLAGS_FILE)
	@rm -fv $(TARGET)

install: optimized
	@cp -v $(TARGET) /usr/bin

uninstall:
	@rm -v /usr/bin/$(TARGET)

verify_cflags:
	@printf "CFLAGS=\"$(CFLAGS)\"\n"
	@if [ -e $(CFLAGS_FILE) ]; then \
		if [ "$$(cat $(CFLAGS_FILE))" != "$(CFLAGS)" ]; then \
			printf "New CFLAGS, cleaning objects...\n"; \
			echo "$(CFLAGS)" > $(CFLAGS_FILE); \
			rm -frv $(OBJDIR)/*; \
			rm -fv $(TARGET); \
		else \
			printf "CFLAGS are identical to $(CFLAGS_FILE)\n"; \
		fi \
	else \
		echo "$(CFLAGS)" > $(CFLAGS_FILE); \
	fi

