SHELL=/usr/bin/env bash
.PHONY: clean base remanaged prereqs

BUILD_ROOT=$(CURDIR)/tmp
PACKAGE_DIR=$(CURDIR)/packages
MANAGED_ROOT=$(CURDIR)/managed
INSTALL_LOCATION=$(CURDIR)/build_output
INSTALL_BIN= ${INSTALL_LOCATION}/bin
PERPD_ROOT=${INSTALL_LOCATION}/usr/sbin
PERPD_EXECUTABLE=${INSTALL_LOCATION}/usr/sbin/perpd
OPEN_SSL= ${INSTALL_LOCATION}/usr/local/ssl/bin/openssl
OPEN_SSL_SOURCE= ${BUILD_ROOT}/openssl-1.0.1g 
POPT_SOURCE=${BUILD_ROOT}/popt-1.16
POPT=${POPT_SOURCE}/popt.o
LUAJIT=${INSTALL_LOCATION}/bin/luajit
NGINX=${INSTALL_LOCATION}/sbin/nginx
PCRE_SOURCE=${BUILD_ROOT}/pcre-8.32
LUA=${INSTALL_LOCATION}/bin/lua
LUA_SOURCE=${BUILD_ROOT}/lua-5.1
LUAJIT_LIB=${INSTALL_LOCATION}/lib
LUAJIT_INC=${INSTALL_LOCATION}/include/luajit-2.0
LUA_CRYPTO= ${INSTALL_LOCATION}/lib/crypto.la
PKG_CONFIG_PATH=${INSTALL_LOCATION}/lib/pkgconfig:${INSTALL_LOCATION}/usr/local/ssl/lib/pkgconfig
LOGROTATE=${INSTALL_LOCATION}/usr/sbin/logrotate
LOGROTATE_ALT_LOC=${INSTALL_LOCATION}/sbin/logrotate
.EXPORT_ALL_VARIABLES:

${OPEN_SSL}: ${NGINX} ${LUA} ${PERPD_EXECUTABLE} ${LOGROTATE} prereqs
	cd ${OPEN_SSL_SOURCE} && ./config --prefix=${INSTALL_LOCATION}
	cd ${OPEN_SSL_SOURCE} && make install 

${LUA}: ${LUAJIT}
	cd ${INSTALL_BIN} && ln -s luajit lua

${NGINX}: ${LUAJIT} ${INSTALL_LOCATION} ${BUILD_ROOT} ${PERPD_EXECUTABLE}
	cd ${BUILD_ROOT}/nginx/ && export LUAJIT_LIB=${LUAJIT_LIB} && \
	  ./configure  --with-mail --with-mail_ssl_module --with-http_ssl_module \
	 	--prefix=${INSTALL_LOCATION} \
		--add-module=${BUILD_ROOT}/ngx_devel_kit-0.2.17rc2 \
		--add-module=${BUILD_ROOT}/lua-nginx-module \
		--with-pcre=${BUILD_ROOT}/pcre-8.32
	cd ${BUILD_ROOT}/nginx/ && make install

${LUAJIT}: ${INSTALL_LOCATION} ${BUILD_ROOT}
	cd ${BUILD_ROOT}/LuaJIT-2.0.0 && make install -e PREFIX=${INSTALL_LOCATION}

${PERPD_EXECUTABLE}: ${INSTALL_LOCATION} ${BUILD_ROOT}
	cd ${BUILD_ROOT}/perp-2.07 && make -e DESTDIR=${INSTALL_LOCATION} install
	export DESTDIR=${MANAGED_ROOT} && ${PERPD_ROOT}/perp-setup /etc/perpd ${MANAGED_ROOT}/var/run/perpd
	sed -i -e s[/var/log/perpd[${MANAGED_ROOT}/var/log/perpd[g ${MANAGED_ROOT}/etc/perpd/.boot/rc.log

${INSTALL_LOCATION}:
	mkdir -p ${INSTALL_LOCATION}

${POPT}: ${BUILD_ROOT}
	cd ${POPT_SOURCE} && ./configure && make

${LOGROTATE}: ${BUILD_ROOT} ${POPT}
	cd tmp/logrotate-3.8.3 && make -e EXTRA_CFLAGS="-I${POPT_SOURCE}" -e EXTRA_LDFLAGS="-L${POPT_SOURCE}/.libs" && make install -e PREFIX=${INSTALL_LOCATION} -e INSTALL=install install
	([ ! -f "${LOGROTATE}" ] && ln -s ${LOGROTATE_ALT_LOC} ${LOGROTATE} ) || true
	([ ! -f "${LOGROTATE_ALT_LOC}" ] && ln -s ${LOGROTATE} ${LOGROTATE_ALT_LOC} ) || true

${BUILD_ROOT}:
	mkdir -p ${BUILD_ROOT}
	cd ${PACKAGE_DIR} && for file in *.tar.gz; do tar xf $${file} -C ${BUILD_ROOT}; done

prereqs: 
	./bin/install_prereqs

remanaged:
	@-rm -rf ./managed

clean_managed: remanaged
	echo "cleaned up all the managed code"

clean: remanaged
	-rm -rf ${INSTALL_LOCATION}
	-rm -rf ${BUILD_ROOT}
