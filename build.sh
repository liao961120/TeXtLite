hugo -D
minify -r -o out/ public
rm -r public
mv out public
