from archlinux
# Update System
RUN pacman -Syu --noconfirm --noprogressbar
# Install system dependencies
RUN pacman -S --noconfirm --noprogressbar python python-pip r sudo texlive-core base-devel base gdal proj geos \
    wget gcc-fortran

# Install dependency "udunits" manually
WORKDIR /usr/local/src
RUN wget https://artifacts.unidata.ucar.edu/repository/downloads-udunits/udunits-2.2.28.tar.gz && \
    tar -xzf udunits-2.2.28.tar.gz && \
    cd udunits-2.2.28 && \
    ls && \
    ./configure --prefix=/usr/ && \
    make && make check && make install

# Install R packages
RUN Rscript -e "install.packages(c('tidyverse','knitr','lubridate', 'sf'),repos='http://cran.us.r-project.org')"

WORKDIR /opt/report

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . /opt/report

CMD cd diss && \
    R -e "require('knitr'); knit('diss.rnw')" && \
    pdflatex diss.tex && \
    biber diss && \
    pdflatex diss.tex
