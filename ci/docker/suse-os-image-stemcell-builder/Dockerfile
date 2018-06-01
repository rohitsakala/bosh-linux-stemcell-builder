FROM opensuse/tumbleweed

RUN zypper --non-interactive in --oldpackage product:openSUSE-20170505-0.s390x
RUN zypper --non-interactive in --force rpm zypper libsolv-tools libzypp libpopt0
RUN cp /usr/lib64/liblua5.3.so.5.3.0 .
RUN rpm -e --nodeps liblua5_3-5
RUN cp liblua5.3.so.5.3.0 /usr/lib64/liblua5.3.so.5
RUN cp liblua5.3.so.5.3.0 /usr/lib64/liblua.so.5.3
RUN zypper --non-interactive in liblua5_3
RUN zypper --non-interactive dup --download as-needed
RUN rm liblua5.3.so.5.3.0

ENV GOROOT /usr/local/go
ENV PATH $GOROOT/bin:$PATH
RUN echo 'export PATH=$GOROOT/bin:$PATH' >> /etc/profile.d/go.sh

RUN zypper -n in ruby-devel libmysqld-devel sqlite3-devel postgresql-devel libxslt-devel libxml2-devel libxml2 python3-kiwi wget sudo gcc-c++ curl git kpartx dracut libopenssl-devel which

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.1

RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install bundler '--version=1.11.2' --no-format-executable"

ADD scripts/install-go.sh /tmp/install-go.sh
RUN /tmp/install-go.sh && rm /tmp/install-go.sh
RUN ln -s /usr/local/go/bin/go /usr/bin

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

RUN useradd --shell /bin/bash -u 1000 -o -c "" -m user \
    && echo 'user ALL=NOPASSWD:ALL' >> /etc/sudoers \
    && usermod -G users,rvm user \
    && mkdir /mnt/stemcells \
    && chown user /mnt/stemcells

USER user:users

CMD ["/bin/bash", "-l"]
