all: go
.PHONY: all

clean:
	rm -rf ../../.local/bin/tmux-sessionizer
.PHONY: clean

go: clean
	go build -o ./tmux-sessionizer-go.bin ./tmux-sessionizer.go
	cp ./tmux-sessionizer-go.bin ../../.local/bin/tmux-sessionizer
	rm -rf ./tmux-sessionizer-go.bin
.PHONY: go

bash: clean
	cp ./tmux-sessionizer.sh ../../.local/bin/tmux-sessionizer
.PHONY: bash


python: clean
	cp tmux-sessionizer.py ../../.local/bin/tmux-sessionizer
.PHONY: python

