build-go:
	go build -o ./tmux-sessionizer-go.bin ./tmux-sessionizer.go

build-rust:
	rustc -o ./tmux-sessionizer-rust.bin ./tmux-sessionizer.rs

bash:
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer.sh ./tmux-sessionizer

go: build-go
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer-go.bin ./tmux-sessionizer

python:
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer.py ./tmux-sessionizer

rust: build-rust
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer-rust.bin ./tmux-sessionizer
