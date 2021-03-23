from archlinux

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm python python-pip r sudo texlive-core base-devel base

WORKDIR /tmp/report

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt
RUN R -e "install.packages(c('tidyverse','knitr', 'lubridate'),repos='http://cran.us.r-project.org')"
