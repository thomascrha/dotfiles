build-go:
	go build -o ./tmux-sessionizer-go.bin ./tmux-sessionizer.go

build-rust:
	rustc -o ./tmux-sessionizer-rust.bin ./tmux-sessionizer.rs

build-ocaml:
	ocamlopt -w -24 -o ./tmux-sessionizer-ocaml.bin unix.cmxa ./tmux-sessionizer.ml

build-c:
	gcc -o ./tmux-sessionizer-c.bin ./tmux-sessionizer.c

build-cpp:
	g++ -std=c++17 -o ./tmux-sessionizer-cpp.bin ./tmux-sessionizer.cpp

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

ocaml: build-ocaml
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer-ocaml.bin ./tmux-sessionizer

c: build-c
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer-c.bin ./tmux-sessionizer

cpp: build-cpp
	rm -f ./tmux-sessionizer
	ln -s ./tmux-sessionizer-cpp.bin ./tmux-sessionizer
