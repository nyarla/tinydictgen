all: tools neologd tinysegmenter-maker nix-shell dictionary corpus features model json

tools:
	test -d tools || mkdir -p tools

neologd: tools
	curl -sLO https://github.com/neologd/mecab-ipadic-neologd/archive/master.zip
	unzip -d . master.zip
	rm master.zip
	mv mecab-ipadic-neologd-master tools/neologd

tinysegmenter-maker: tools
	curl -sLO https://github.com/shogo82148/TinySegmenterMaker/archive/master.zip
	unzip -d . master.zip
	rm master.zip
	mv TinySegmenterMaker-master tools/tinysegmenter-maker

nix-shell:
	nix-shell

dictionary: neologd
	test -d out || mkdir -p out
	cd tools/neologd \
		&& test -e out || ln -sf ../../out . \
		&& bin/install-mecab-ipadic-neologd -p $(shell pwd)/out -u -a --forceyes

corpus: dictionary
	cat src/src.txt \
		| perl scripts/fixup.pl \
		| mecab -b 81920 -d $(shell pwd)/out \
		| tr "\t" " " | cut -d\  -f1 \
		| grep -v EOS | tr "\n" " " >src/corpus.txt

features: corpus
	cd tools/tinysegmenter-maker \
		&& python3 extract < ../../src/corpus.txt > ../../src/features.txt

model: features
	cd tools/tinysegmenter-maker \
		&& g++ -O3 -o train train.cpp \
		&& ./train -t 0.001 -n 10000 ../../src/features.txt ../../tinyseg.model

json:
	perl scripts/model-to-json.pl $(shell pwd)/tinyseg.model > tinyseg.json

