from archlinux
# Update System
RUN pacman -Syyu --noconfirm --noprogressbar
# Install system dependencies
RUN pacman -S --noconfirm --noprogressbar python python-pip r sudo texlive-core base-devel base gdal proj geos \
    wget gcc-fortran texlive-latexextra texlive-bibtexextra biber

# Install dependency "udunits" manually
WORKDIR /usr/local/src
RUN wget https://artifacts.unidata.ucar.edu/repository/downloads-udunits/udunits-2.2.28.tar.gz && \
    tar -xzf udunits-2.2.28.tar.gz && \
    cd udunits-2.2.28 && \
    ls && \
    ./configure --prefix=/usr/ && \
    make && make check && make install

# Install R packages
RUN Rscript -e "install.packages(c('tidyverse','ggrepel','knitr','lubridate', 'sf'),repos='http://cran.us.r-project.org')"
RUN Rscript -e "install.packages(c('biglm', 'broom', 'texreg', 'stargazer'),repos='http://cran.us.r-project.org')"

WORKDIR /opt/report

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

#RUN curl -s "https://archlinux.org/mirrorlist/?country=FR&country=GB&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist

RUN pacman -S --noconfirm --noprogressbar texlive-bibtexextra biber

COPY . /opt/report

CMD cd code && \
    # ./00_replicate.sh && \ # uncomment to re-run models
    cd ../diss && \
    export PATH=$PATH:/usr/bin/vendor_perl && \
    R -e "require('knitr'); knit('diss.Rnw')" && \
    pdflatex diss.tex && \
    biber diss && \
    pdflatex diss.tex && \
    rm diss.aux diss.bbl diss.bcf diss.blg diss.log diss.out diss.toc diss.run.xml diss.R
