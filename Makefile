.PHONY: setup test clean

MINI_DIR := tests/.deps/mini.nvim

setup:
	@test -d $(MINI_DIR) || git clone --depth 1 https://github.com/nvim-mini/mini.nvim $(MINI_DIR)

test: setup
	nvim --headless -u tests/init.lua -c 'lua MiniTest.run()'

clean:
	rm -rf tests/.deps
