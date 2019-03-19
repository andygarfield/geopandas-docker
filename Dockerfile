FROM debian:buster-slim

ENV gdb_archive      /tmp/filegdb.tar.gz
ENV gdb_install_dir  /tmp/gdb/FileGDB_API_1.5.1
ENV gdb_dir          /usr/lib
ENV gdal_archive     /tmp/gdal.tar.gz
ENV gdal_install_dir /tmp/gdal
ENV proj_archive     /tmp/proj.tar.gz
ENV proj_install_dir /tmp/proj

ENV PROJ_LIB         /usr/local/share/proj

RUN apt-get update
RUN apt-get install -y \
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
        sqlite3
RUN git clone https://github.com/Esri/file-geodatabase-api.git /tmp/gdb
RUN git clone https://github.com/libspatialindex/libspatialindex.git /tmp/libspat
RUN wget \ 
        http://download.osgeo.org/gdal/2.4.0/gdal-2.4.0.tar.gz \
        -O $gdal_archive
RUN wget \
        http://download.osgeo.org/proj/proj-5.2.0.tar.gz \
        -O $proj_archive
RUN tar xvzf $proj_archive -C /tmp
RUN tar xvzf $gdal_archive -C /tmp
RUN tar xvzf $gdb_install_dir/FileGDB_API_1_5_1-64gcc51.tar.gz
RUN cp /FileGDB_API-64gcc51/lib/* /usr/lib
RUN cp /FileGDB_API-64gcc51/include/* /usr/include
RUN cd /tmp/libspat && ./autogen.sh && ./configure && make && make install
RUN cd /tmp/proj-5.2.0 && ./configure && make && make install && ldconfig
RUN cd /tmp/gdal-2.4.0 && ./configure --with-fgdb=/usr --with-proj=/usr/local
RUN cd /tmp/gdal-2.4.0 && make && make install && ldconfig
RUN python3.7 -m pip install -I fiona --no-binary fiona
RUN python3.7 -m pip install \
        cython \
        geopandas \
        git+https://github.com/pyproj4/pyproj.git@v1.9.6rel \
        rtree
RUN apt-get remove -y \
        automake \
        build-essential \
        git \
        libtool \
        m4 \
        pkg-config \
        wget
RUN apt -y autoremove
RUN rm -rd /tmp/*
RUN rm -rd /FileGDB_API-64gcc51
