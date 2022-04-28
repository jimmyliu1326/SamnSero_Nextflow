FROM rocker/r-ver:4.0.2

RUN apt-get update -y && \
    apt-get install -y libcairo2-dev \
        libxt-dev \
        pandoc && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c( \
                'dplyr', \
                'tidyr', \
                'tibble', \
                'ggplot2', \
                'purrr', \
                'gt', \
                'data.table', \
                'knitr', \
                'BiocManager', \
                'circlize', \
                'plotly', \
                'RColorBrewer', \
                'stringr', \
                'rmarkdown', \
                'bit64', \
                'Cairo'))" && \
    R -e "BiocManager::install('ComplexHeatmap')"

ADD src/abricate_plot.R  \
    src/annot_report.Rmd \
    src/samnsero_load.R \
    src/qc_report.Rmd \
    src/samnsero_combine.R \
    /

ADD src/make_annot_report.sh \
    src/make_qc_report.sh \
    /usr/bin/

RUN chmod +x /usr/bin/*.sh

WORKDIR /data