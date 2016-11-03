DEPS=main components
FILENAME=main

all: $(FILENAME).pdf

$(FILENAME).pdf: $(FILENAME).tex $(patsubst %,%.tex,${DEPS})
	pdflatex -shell-escape  $(FILENAME).tex
	makeglossaries $(FILENAME)
	pdflatex -shell-escape $(FILENAME).tex

view:
	nohup evince $(FILENAME).pdf &> /dev/null &

clean:
	rm -f *.acn *.acr *.alg *.aux *.glg *.glo *.gls *.ist *.lof *.log *.out *.toc *.pdf *.lot
