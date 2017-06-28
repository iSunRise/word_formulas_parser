## Run as console tool:

    > bin/parse myfile.docx output.json

## Support cyrillic

    Text:
    sudo apt-get install texlive-lang-cyrillic
    sudo apt-get install texlive-fonts-recommended

    Formulas:
    sudo apt-get install texlive-math-extra

    Should be packages at least:
      texlive-base
      texlive-binaries
      texlive-fonts-recommended
      texlive-lang-cyrillic
      texlive-latex-base
      texlive-math-extra

## Full list of packages for latex

    dpkg -l \*texlive\* | grep ^ii

