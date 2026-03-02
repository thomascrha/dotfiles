build-go:
	go build -o ./tmux-sessionizer-go.bin ./tmux-sessionizer.go

bash:
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer.sh ./tmux-sessionizer

go: build-go
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer-go.bin ./tmux-sessionizer

python:
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer.py ./tmux-sessionizer

