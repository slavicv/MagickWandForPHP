PHP_ARG_WITH(magickwand, whether to enable the magickwand extension,
[ --with-magickwand[=DIR]	Enables the magickwand extension. DIR is the prefix to Imagemagick installation directory.], no)

if test $PHP_MAGICKWAND != "no"; then

    if test -r $PHP_MAGICKWAND/bin/Wand-config; then
        WAND_CONFIG_PATH=$PHP_MAGICKWAND/bin
    else
        AC_MSG_CHECKING(Wand-config in default path)

        for i in /usr/local /usr;
        do
            test -r $i/bin/Wand-config && WAND_CONFIG_PATH=$i/bin && break
        done

        if test -z "$WAND_CONFIG_PATH"; then
            for i in $PHP_MAGICKWAND /usr/local /usr;
            do
                test -r $i/Wand-config && WAND_CONFIG_PATH=$i && break
            done
        fi
        if test -z "$WAND_CONFIG_PATH"; then
            AC_MSG_ERROR(Cannot locate configuration program Wand-config)
        else
            AC_MSG_RESULT(found in $WAND_CONFIG_PATH)
        fi
    fi

		WAND_DIR=`$WAND_CONFIG_PATH/Wand-config --prefix`
		AC_MSG_CHECKING(for magick-wand.h header file)

		if test -r $WAND_DIR/include/wand/magick-wand.h; then
				AC_MSG_RESULT(found in $WAND_DIR/include/wand/magick-wand.h)
		else
				AC_MSG_ERROR(Cannot locate header file magick-wand.h)
		fi


		IMAGEMAGICK_VERSION_ORIG=`$WAND_CONFIG_PATH/Wand-config --version`
		IMAGEMAGICK_VERSION_MASK=`echo ${IMAGEMAGICK_VERSION_ORIG} | awk 'BEGIN { FS = "."; } { printf "%d", ($1 * 1000 + $2) * 1000 + $3;}'`


		AC_MSG_CHECKING(if ImageMagick version is at least 6.3.5)
		if test "$IMAGEMAGICK_VERSION_MASK" -ge 6003005; then
				AC_MSG_RESULT(found version $IMAGEMAGICK_VERSION_ORIG)
		else
				AC_MSG_ERROR(no. You need at least Imagemagick version 6.3.5 to use MagickWand for PHP.)
		fi

		AC_MSG_CHECKING(if PHP version is at least 4.1.3)

		tmp_version=$PHP_VERSION
		if test -z "$tmp_version"; then
  		if test -z "$PHP_CONFIG"; then
    			AC_MSG_ERROR([php-config not found])
  		fi
   			MAGICKWAND_PHP_VERSION_ORIG=`$PHP_CONFIG --version`;
		else
			MAGICKWAND_PHP_VERSION_ORIG=$tmp_version
		fi

		if test -z $MAGICKWAND_PHP_VERSION_ORIG; then
			AC_MSG_ERROR([failed to detect PHP version, please report])
		fi

		MAGICKWAND_PHP_VERSION_MASK=`echo ${MAGICKWAND_PHP_VERSION_ORIG} | awk 'BEGIN { FS = "."; } { printf "%d", ($1 * 1000 + $2) * 1000 + $3;}'`

		if test $MAGICKWAND_PHP_VERSION_MASK -ge 4001003; then
				AC_MSG_RESULT(found version $MAGICKWAND_PHP_VERSION_ORIG)
		else
				AC_MSG_ERROR(no. You need at least PHP version 4.1.3 to use MagickWand.)
		fi

		AC_DEFINE(HAVE_MAGICKWAND,1,[ ])

		PHP_ADD_LIBRARY_WITH_PATH(Magick, $WAND_DIR/lib, MAGICKWAND_SHARED_LIBADD)
		PHP_ADD_LIBRARY_WITH_PATH(Wand, $WAND_DIR/lib, MAGICKWAND_SHARED_LIBADD)
		PHP_ADD_INCLUDE($WAND_DIR/include)
		PHP_SUBST(MAGICKWAND_SHARED_LIBADD)
		PHP_NEW_EXTENSION(magickwand, magickwand.c, $ext_shared)

fi
