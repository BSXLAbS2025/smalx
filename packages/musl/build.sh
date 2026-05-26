#!/bin/bash
set -e

MUSL_VERSION="1.2.5"
WORKDIR="$(cd "$(dirname "$0")" && pwd)"
BUILDDIR="${WORKDIR}/build"
INSTALLDIR="${WORKDIR}/install"

mkdir -p "${BUILDDIR}" "${INSTALLDIR}"

# Скачиваем
if [ ! -f "musl-${MUSL_VERSION}.tar.gz" ]; then
    wget "https://musl.libc.org/releases/musl-${MUSL_VERSION}.tar.gz"
fi

# Распаковываем
tar xf "musl-${MUSL_VERSION}.tar.gz" -C "${BUILDDIR}"
cd "${BUILDDIR}/musl-${MUSL_VERSION}"

# Конфигурируем и собираем
./configure \
    --prefix="${INSTALLDIR}" \
    --syslibdir="${INSTALLDIR}/lib" \
    --disable-shared \
    --enable-static

make -j$(nproc)
make install

echo "musl установлен в ${INSTALLDIR}"
echo "Добавь ${INSTALLDIR}/bin в PATH для использования musl-gcc"
