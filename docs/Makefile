# export TEXINPUTS=:/home/schaller/tars/latex2html/texinputs/:

default: html guide.ps

%.ps: %.dvi
	dvips -o $@ $<

%.dvi: %.tex
	latex $<
	latex $<
	rm guide.aux guide.log

html: guide.tex
	latex2html -split 0 -dir guide -no_navigation $<
	rm guide/WARNINGS guide/labels.pl guide/guide.css
