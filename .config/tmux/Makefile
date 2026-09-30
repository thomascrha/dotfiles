build-go:
	go build -o ./tmux-sessionizer-go.bin ./tmux-sessionizer.go

bash:
	ln -s ./tmux-sessionizer.sh ../../.local/bin/tmux-sessionizer

go: build-go
	rm -rf ../../.local/bin/tmux-sessionizer
	ln -s $(shell pwd)/tmux-sessionizer-go.bin $(shell pwd)/../../.local/bin/tmux-sessionizer

python:
	ln -s tmux-sessionizer.py ../../.local/bin/tmux-sessionizer

