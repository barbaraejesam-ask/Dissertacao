.PHONY: install build serve clean

install:
	pip install -r requirements.txt

build:
	python build.py --csv

serve: build
	python -m http.server 8000 --directory public

clean:
	rm -rf public/index.html public/indicadores_sc_long.csv
