SHELL=/usr/bin/env bash
.PHONY: clean base remanaged

BUILD_ROOT=$(CURDIR)/tmp
PACKAGE_DIR=$(CURDIR)/packages
INSTALL_LOCATION=$(CURDIR)/build_output
INSTALL_BIN= ${INSTALL_LOCATION}/bin
OPEN_SSL= ${INSTALL_LOCATION}/usr/local/ssl/bin/openssl
OPEN_SSL_SOURCE= ${BUILD_ROOT}/openssl-1.0.1c 
LUAJIT=${INSTALL_LOCATION}/bin/luajit
NGINX=${INSTALL_LOCATION}/sbin/nginx
PCRE_SOURCE=${BUILD_ROOT}/pcre-8.32
LUA=${INSTALL_LOCATION}/bin/lua
LUA_SOURCE=${BUILD_ROOT}/lua-5.1
LUAJIT_LIB=${INSTALL_LOCATION}/lib
LUAJIT_INC=${INSTALL_LOCATION}/include/luajit-2.0
LUA_CRYPTO= ${INSTALL_LOCATION}/lib/crypto.la
PKG_CONFIG_PATH=${INSTALL_LOCATION}/lib/pkgconfig:${INSTALL_LOCATION}/usr/local/ssl/lib/pkgconfig
.EXPORT_ALL_VARIABLES:

${OPEN_SSL}: ${NGINX} ${LUA}
	cd ${OPEN_SSL_SOURCE} && ./config --prefix=${INSTALL_LOCATION}
	cd ${OPEN_SSL_SOURCE} && make install 

${LUA}: ${LUAJIT}
	cd ${INSTALL_BIN} && ln -s luajit lua

${NGINX}: ${LUAJIT} ${INSTALL_LOCATION} ${BUILD_ROOT}
	cd ${BUILD_ROOT}/nginx-1.2.4/ && export LUAJIT_LIB=${LUAJIT_LIB} && ./configure  --with-mail --with-mail_ssl_module --with-http_ssl_module --prefix=${INSTALL_LOCATION} --add-module=${BUILD_ROOT}/ngx_devel_kit-0.2.17rc2 --add-module=${BUILD_ROOT}/lua-nginx-module-0.7.6rc1 --with-pcre=${BUILD_ROOT}/pcre-8.32
	cd ${BUILD_ROOT}/nginx-1.2.4/ && make install

${LUAJIT}: ${INSTALL_LOCATION} ${BUILD_ROOT}
	cd ${BUILD_ROOT}/LuaJIT-2.0.0 && make install -e PREFIX=${INSTALL_LOCATION}

${INSTALL_LOCATION}:
	mkdir -p ${INSTALL_LOCATION}

${BUILD_ROOT}:
	mkdir -p ${BUILD_ROOT}
	cd ${PACKAGE_DIR} && for file in *.tar.gz; do tar xf $${file} -C ${BUILD_ROOT}; done

remanaged:
	@-rm -rf ./managed/prod/instance1/*
	@-rm -rf ./managed/prod/instance1/.??*
	@-rm -rf ./managed/prod/instance2/*
	@-rm -rf ./managed/prod/instance2/.??*
	@-rm -rf ./managed/alternates/*

clean:
	-rm -rf ${INSTALL_LOCATION}
	-rm -rf ${BUILD_ROOT}
