
all:
	stow --no-folding -t ${HOME} -v -R -d ${PWD} -S .

clean:
	stow -t ${HOME} -d ${PWD} -D .
