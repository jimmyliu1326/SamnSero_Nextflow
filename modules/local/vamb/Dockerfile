FROM mambaorg/micromamba:0.14.0

RUN apt-get update && \
    apt-get install -y procps git gcc python3-dev && \
    rm -rf /var/lib/apt/lists/* && \
    CONDA_DIR="/opt/conda" && \
    micromamba install -n base -y -c pytorch -c conda-forge pip cudatoolkit=10.2

RUN git clone https://github.com/RasmussenLab/vamb -b master && \
    cd vamb && \
    pip install --upgrade pip && \
    pip install -e .

RUN micromamba clean --all --yes && \
    rm -rf $CONDA_DIR/conda-meta && \
    rm -rf $CONDA_DIR/include && \
    find $CONDA_DIR -name '__pycache__' -type d -exec rm -rf '{}' '+'