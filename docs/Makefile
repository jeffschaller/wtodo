# export TEXINPUTS=:/home/schaller/tars/latex2html/texinputs/:

default: html guide.ps

%.ps: %.dvi
	dvips -o $@ $<

%.dvi: %.tex
	latex $<
	latex $<

html: guide.tex
	latex2html -split 0 -dir guide $<
	rm guide/WARNINGS guide/labels.pl guide/guide.css
