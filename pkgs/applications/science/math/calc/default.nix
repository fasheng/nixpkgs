{ stdenv, lib, fetchurl, util-linux, makeWrapper
, enableReadline ? true, readline, ncurses }:

stdenv.mkDerivation rec {
  pname = "calc";
  version = "2.12.8.1";

  src = fetchurl {
    urls = [
      "https://github.com/lcn2/calc/releases/download/${version}/${pname}-${version}.tar.bz2"
      "http://www.isthe.com/chongo/src/calc/${pname}-${version}.tar.bz2"
    ];
    sha256 = "sha256-TwVcuGaWIgzEc34DFEGFcmckXrwZ4ruRqselJClz15o=";
  };

  patchPhase = ''
    substituteInPlace Makefile \
      --replace '-install_name ''${LIBDIR}/libcalc''${LIB_EXT_VERSION}' '-install_name ''${T}''${LIBDIR}/libcalc''${LIB_EXT_VERSION}' \
      --replace '-install_name ''${LIBDIR}/libcustcalc''${LIB_EXT_VERSION}' '-install_name ''${T}''${LIBDIR}/libcustcalc''${LIB_EXT_VERSION}'
  '';

  buildInputs = [ util-linux makeWrapper ]
             ++ lib.optionals enableReadline [ readline ncurses ];

  makeFlags = [
    "T=$(out)"
    "INCDIR="
    "BINDIR=/bin"
    "LIBDIR=/lib"
    "CALC_SHAREDIR=/share/calc"
    "CALC_INCDIR=/include"
    "MANDIR=/share/man/man1"

    # Handle LDFLAGS defaults in calc
    "DEFAULT_LIB_INSTALL_PATH=$(out)/lib"
  ] ++ lib.optionals enableReadline [
    "READLINE_LIB=-lreadline"
    "USE_READLINE=-DUSE_READLINE"
  ];

  meta = with lib; {
    description = "C-style arbitrary precision calculator";
    homepage = "http://www.isthe.com/chongo/tech/comp/calc/";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ matthewbauer ];
    platforms = platforms.all;
  };
}
