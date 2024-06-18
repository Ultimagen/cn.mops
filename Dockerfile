FROM amazonlinux:2023

# Install basic dependencies
RUN yum update -y && \
    yum install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    procps \
    libcurl-devel \
    libxml2-devel \
    openssl-devel \
    bzip2 \
    xz \
    readline-devel \
    zlib-devel \
    pcre2-devel \
    make \
    tar \
    bzip2 \
    bzip2-devel `# for samtools` \
    xz-devel `# for samtools` \
    wget \
    git \
    which \
    bzip2-devel \
    xz-devel \
    curl-devel \
    ncurses-libs `# for samtools` \
    ncurses-devel `# for samtools` \
    openblas-devel \
    yum-utils \
    libstdc++-static `# for bedops` \
    glibc-static `# for bedops` \
    git `# for bedops`

# Download and install R
RUN wget https://cloud.r-project.org/src/base/R-4/R-4.3.1.tar.gz && \
    tar -xzf R-4.3.1.tar.gz && \
    cd R-4.3.1 && \
    ./configure --with-x=no --enable-R-shlib && \
    make && \
    make install && \
    cd .. && \
    rm -rf R-4.3.1 R-4.3.1.tar.gz

# Install Python 3.9 and pip
ARG PYTHON_VERSION=3.9

RUN yum install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-devel && \
    python${PYTHON_VERSION} -m ensurepip && \
    python${PYTHON_VERSION} -m pip install --upgrade pip

# Create symbolic links for python and pip
RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
    ln -s /usr/local/bin/pip${PYTHON_VERSION} /usr/bin/pip

# Install samtools
ARG SAMTOOLS_VERSION=1.17

RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
 tar -vxjf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
 rm samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
 cd samtools-${SAMTOOLS_VERSION} && \
 make -j $(nproc) && \
 make install

# Install samtools
ARG BEDTOOLS_VERSION=2.31.0

# Install bedtools from source
RUN wget https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz && \
    tar -zxvf bedtools-${BEDTOOLS_VERSION}.tar.gz && \
    cd bedtools2 && \
    make && \
    make install && \
    cd .. && \
    rm -rf bedtools-${BEDTOOLS_VERSION}.tar.gz bedtools2

# Install bedops
RUN git clone https://github.com/bedops/bedops.git && \
    cd bedops && \
    make && \
    make install && \
    cp bin/* /usr/local/bin

# Install required pip modules
RUN python3.9 -m pip install pandas==2.2.2 pysam==0.22.1 ugbio-core ugbio-cnv

# Install additional R dependencies
RUN R -e "install.packages(c('argparse', 'BiocManager'), repos='https://cran.r-project.org')"

# Install Bioconductor packages one by one, ensuring dependencies are met
RUN R -e "BiocManager::install(c('BiocGenerics', 'BiocParallel', 'Biostrings', 'Biobase'))"
RUN R -e "BiocManager::install(c('GenomeInfoDb', 'GenomicRanges', 'IRanges', 'S4Vectors', 'XVector', 'zlibbioc'))"
RUN R -e "BiocManager::install(c('rhdf5', 'rhdf5filters', 'rhdf5lib', 'Rhtslib', 'Rsamtools'))"
RUN R -e "BiocManager::install('exomeCopy')"

# Install other necessary R packages
RUN R -e "install.packages(c('bitops', 'codetools', 'cpp11', 'crayon', 'findpython', 'formatR', 'futile.logger', 'futile.options', 'jsonlite', 'lambda.r', 'magrittr', 'R6', 'RCurl', 'snow'), repos='https://cran.r-project.org')"

COPY ./ ./

# Install cn.mops packages from local
RUN  R CMD INSTALL --preclean --no-multiarch --with-keep.source .



