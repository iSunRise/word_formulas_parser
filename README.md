## Additional programs
    LibreOffice:
    https://www.libreoffice.org/download/download/
    
    writer2latex:
    http://writer2latex.sourceforge.net/index11.html
    https://sourceforge.net/projects/writer2latex/

    texlive:
    https://www.tug.org/texlive/
    or for linux:
    
    ```
    apt-get install texlive
    ```

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

