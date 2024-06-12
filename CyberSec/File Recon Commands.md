# File Recon Information

## File Contents

Get file contents without opening it: 

```bash
strings targetFile | grep flag

strings -o targetFile

strings -a targetFile

strings -t d targetFile

strings -f targetFile

strings targetFile | more

more targetFile

binwalk targetFile

binwalk -e targetFile

binwalk -e -c targetFile

binwalk --dd='.*' targetFile

unzip targetFile 
```

## Bruteforcing Files

```bash
fcrackzip -u -c a --length 2-5 targetFile

fcrackzip -b -D -p rockyou.txt -u targetFile

fcrackzip "targetFile" -u -v -m zip2 -l1 -c a

zip -FF targetFile.zip --out targetFile-out.zip

pdfcrack -f targetFile --wordlist=rockyou.txt

stegcracker targetFile rockyou.txt
```

## PDF Specific

```bash
pdfinfo targetFile

pdfcrack -f targetFile --wordlist=rockyou.txt

pdf-parser -a targetFile

pdfid targetFile

peepdf -x targetFile
```

## Exif & Hidden Data
```bash
mat2 -s file.png

stegcracker targetFile

exiv2 targetFile

exiftool -s targetFile

exiftool -list targetFile

exiftool -a -u -g1 targetFile

```

## Other formats

```bash
xxd -p targetFile

pdgmail -v -f targetFile.dmp

hexdump -C targetFile | grep "agg" -A 0 -B 3

dd if=./targetFile of=./targetFile-out.zip skip=411781 bs=1

dd if=./targetFile of=./targetFile-out.zip skip=Y bs=1 count=Z

foremost -i targetFile

foremost -t doc,jpg,pdf,xls -i targetFile

python3 WavSteg.py -r -s targetFile -o targetFile-out

```
