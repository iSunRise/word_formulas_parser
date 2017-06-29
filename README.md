## Use
```ruby
WordFormulasParser.detect_and_parse(input_file_path)
```

## Additional programs
LibreOffice:
<br>
https://www.libreoffice.org/download/download/

writer2latex:
<br>
http://writer2latex.sourceforge.net/index11.html
<br>
https://sourceforge.net/projects/writer2latex/

texlive:
<br>
https://www.tug.org/texlive/
<br>
or for linux:

```shell
apt-get install texlive
```

## Support cyrillic

Text:
```shell
sudo apt-get install texlive-lang-cyrillic
sudo apt-get install texlive-fonts-recommended
```
Formulas:
```shell
sudo apt-get install texlive-math-extra
```

Should be packages at least:
```shell
texlive-base
texlive-binaries
texlive-fonts-recommended
texlive-lang-cyrillic
texlive-latex-base
texlive-math-extra
```

## Full list of packages for latex
```shell
dpkg -l \*texlive\* | grep ^ii
```
