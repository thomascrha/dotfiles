build:
	go build -o ./tmux-sessionizer.bin ./tmux-sessionizer.go

bash:
	rm ./tmux-sessionizer
	ln -s ./tmux-sessionizer.sh ./tmux-sessionizer

go: build
	rm ./tmux-sessionizer
	ln -s ./tmux-sessionizer.bin ./tmux-sessionizer
