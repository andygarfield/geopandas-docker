FROM debian:buster-slim

ENV gdb_archive      /tmp/filegdb.tar.gz
ENV gdb_install_dir  /tmp/gdb/FileGDB_API_1.5.1
ENV gdb_dir          /usr/lib
ENV gdal_archive     /tmp/gdal.tar.gz
ENV gdal_install_dir /tmp/gdal-2.4.0
ENV proj_archive     /tmp/proj.tar.gz
ENV proj_install_dir /tmp/proj-5.2.0

ENV PROJ_LIB         /usr/local/share/proj

RUN apt-get update && \
    apt-get install -y \
        automake \
        build-essential \
        git \
        wget \
        libgeos-3.7.1 \
        libsqlite3-dev \
        libsqlite3-mod-spatialite \
        libtool \
        m4 \
        pkg-config \
        python3.7 \
        python3.7-dev \
        python3-pip \
        spatialite-bin \
        sqlite3 && \
    git clone https://github.com/Esri/file-geodatabase-api.git /tmp/gdb && \
    git clone https://github.com/libspatialindex/libspatialindex.git /tmp/libspat && \
    cd /tmp/libspat && git checkout tags/1.9.0 && cd / && \
    wget \ 
        http://download.osgeo.org/gdal/2.4.0/gdal-2.4.0.tar.gz \
        -O $gdal_archive && \
    wget \
        http://download.osgeo.org/proj/proj-5.2.0.tar.gz \
        -O $proj_archive && \
    tar xvzf $proj_archive -C /tmp && \
    tar xvzf $gdal_archive -C /tmp && \
    tar xvzf $gdb_install_dir/FileGDB_API_1_5_1-64gcc51.tar.gz && \
    cp /FileGDB_API-64gcc51/lib/* /usr/lib && \
    cp /FileGDB_API-64gcc51/include/* /usr/include && \
    cd /tmp/libspat && ./autogen.sh && ./configure && make && make install && \
    cd $proj_install_dir && ./configure && make && make install && ldconfig && \
    cd $gdal_install_dir && ./configure --with-fgdb=/usr --with-proj=/usr/local && \
    make && make install && ldconfig && \
    python3 -m pip install -I fiona --no-binary fiona && \
    python3 -m pip install numpy && \
    python3 -m pip install \
        cython \
        shapely[vectorized] && \
    python3 -m pip install \
        geopandas \
        git+https://github.com/pyproj4/pyproj.git@v1.9.6rel \
        rtree && \
    apt-get remove -y \
        automake \
        build-essential \
        git \
        libtool \
        m4 \
        pkg-config \
        wget && \
    apt -y autoremove && \
    rm -rd /tmp/* && \
    rm -rd /FileGDB_API-64gcc51 && \
    ln -s /usr/bin/python3 /usr/bin/python
