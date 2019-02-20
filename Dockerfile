FROM python:3.7-slim

ENV gdb_archive      /tmp/filegdb.tar.gz
ENV gdb_install_dir  /tmp/gdb/FileGDB_API_1.5.1
ENV gdb_dir          /usr/lib
ENV gdal_archive     /tmp/gdal.tar.gz
ENV gdal_install_dir /tmp/gdal-2.3.2
ENV proj_archive     /tmp/proj.tar.gz
ENV proj_install_dir /tmp/proj-5.2.0

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git \
        wget \
        libgeos-3.5.1 \
        libspatialite7 && \

    git clone https://github.com/Esri/file-geodatabase-api.git /tmp/gdb && \
    wget \ 
        http://download.osgeo.org/gdal/2.3.2/gdal-2.3.2.tar.gz \
        -O $gdal_archive && \
    
    wget \
        http://download.osgeo.org/proj/proj-5.2.0.tar.gz \
        -O $proj_archive && \

    tar xvzf $proj_archive -C /tmp && \
    tar xvzf $gdal_archive -C /tmp && \
    tar xvzf $gdb_install_dir/FileGDB_API_1_5_1-64gcc51.tar.gz && \

    cp /FileGDB_API-64gcc51/lib/* /usr/lib && \
    cp /FileGDB_API-64gcc51/include/* /usr/include && \

    cd $proj_install_dir && ./configure && make && make install && ldconfig && \

    cd $gdal_install_dir && \
    ./configure --with-fgdb=/usr --with-proj=/usr/local && \
    cd $gdal_install_dir && make && make install && ldconfig && \

    pip install cython && \
    pip install git+https://github.com/jswhit/pyproj.git && \
    pip install geopandas && \

    apt-get remove -y \
        build-essential \
        git \
        wget && \
    rm -rd /tmp/* && \
    rm -rd /FileGDB_API-64gcc51
