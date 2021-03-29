from archlinux

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm python python-pip r sudo texlive-core base-devel base zathura zathura-pdf-poppler gdal

COPY . /opt/report
WORKDIR /opt/report

RUN pip install -r requirements.txt

RUN Rscript -e "install.packages(c('tidyverse','knitr','lubridate',''),repos='http://cran.us.r-project.org')"

CMD cd diss && \
    R -e "require('knitr'); knit('diss.rnw')" && \
    pdflatex diss.tex && \
    biber diss && \
    pdflatex diss.tex && \
    zathura diss.pdf
