#!/bin/sh
# This script was generated using Makeself 2.4.2
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2157529607"
MD5="f07c0b7567a355549ca786a768f34ca8"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="Script d'installation e-stock"
script="./setup-estock.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="setup-estock"
filesizes="8123"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="666"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    if test x"$accept" = xy; then
      echo "$licensetxt"
    else
      echo "$licensetxt" | more
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.2
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 40 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Mon Sep 14 16:27:12 CEST 2020
	echo Built with Makeself version 2.4.2 on 
	echo Build command was: "./makeself.sh \\
    \"./setup-estock\" \\
    \"./setup-estock.sh\" \\
    \"Script d'installation e-stock\" \\
    \"./setup-estock.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"setup-estock\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
	if ! shift 2; then MS_Help; exit 1; fi
	;;
    --cleanup-args)
    cleanupargs="$2"
    if ! shift 2; then MS_help; exit 1; fi
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 40 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 40; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (40 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� �}__�\�v�H��_���$��o��38�^b'��㴥v��,]B�Ͱϲ1/���Uݺ��� {��X���u�u��v����_|��l����V%�7~=�n��v�w��7�ngg�� �|�W��x`y��m��O_��d濷͒����ە�u��ک�b�omV�����F�T�����V��s���/�d1��ϽK��:c�,�X`��-�����`�Og�[>.�w����e2��7�J$>��vG�wJ<��$��ri�,D4�kl15���g���m��:g1	����a�g��N������I�?X�9h�9��4�N���� � v�,��l��e�)����Գ�@3���v�K�9|8��s�����	�Bo�cr�9��-�x�z���6s���`�yL��e�_��K�;)�nlO{4�|�]2�"Q��y0��Qt�M3B;0��&�H�<��-�>��8g>�q<N�"Z�!���z&�u.�A^�1l��	��q�߇n����P��fA�PWT0Ι�J�|�'#�0���h�L��|d1���R�0��B�S}׸@Gٮ!LV"m�s�*�y�a�f��	���܏�}�ڶ��X^2;��i��3�sv�A�3p���Q� T��&�>�w�����:���e/t"�є�28�T�����}�T}(J�P�� S���Q�]�)�(y�h66*�
�i��ʡ�)���5񰭑��i܁o��&����5j���>z�G#�k��{�5t��&�m;�̤�D0�.b�FYDt����x��@r�@��]tH�b>L\t:&��ҔKp ���JF�a��,�Ԙiz�(�Q�"GX%�Б�^��p�����?���e®��"���)F����z1��A���"n4�q���:�ƙ�yf3��2�q�	�)��gM����BLn�DnSF9���D.4nl!�`
b܊LCO��Bk*��峉�q�%��!e�o4_�++��Í�+�ZAۈ)�
�y�a{;#]-�!"̒��U_�ܛASof��O}�ulkb	[vr���4�d{�	 �Є�3]�}�(F�r��0��L���\�7wD賏��A�K����`�M�0�rAd����(�hXç�*UP���D{b��0�%���3�p��C�R2��Tsϒ��0�sc o���R�<�6��2�|I��1 ��B�rA�0�h�����C�y�PT <�D���8�&�1'����ziD#'#C�g�u�	6Z�A���B=�a��+ZS ��D�CZ�p�B��b����S	���<�xi��q�G�D*S����,1�6�Ea���hu�RK,L�Fn +�¸�e,�����R��-�ђm�(���>��p�)���q
	h���)�d����T�ZMwh����Kvh�a\�6�	�u� �鵔"�ڎ��#8��r��������t�E5)"����R�5 3E�`�a�$�%P=����߸��H�^r��=�$��[�8�e��1/�/�b���	�3���%z�k`9��dZ�0����^@eJ�Ce'������!�g'mPq��`���|��V�T:wȪ4哸/�Q��Q�2��[ͧ����Z�]VJ��������5��Zm���7�*;5���6k�����K�M�z��00�"��_�߃S���8�nEi�����4�}���n���ꉢ4%z��{4XFy���k@�̗������l3%a���2���}���f0�S���x)9�ՃU��OW�m�-�;h��쿁�xC���F=�5�h�q���}�?��p�M5+���C1����<3����/4�HKTXTppz칈�҉�����Dt�� �Zf|��ܵju]�vOP����h��"���H�]wr��(�vwkۛ)1����F�����Z�x]Y������ط���� ����>���x��Z��E���E7�
���U��D�+k�sb9��@�硷�^Ķg�4�'���+[Nw%ɽ���S~��"��e��wY�x���G����@�ca�6��p�m�<�c�~}�&Ƙ��q��@������cU���~W^��{ui&xn�k�8vn��.�>��7����ĝ	Z(�+f[��X�|�č
PX��\j[[�I�$�7h�c��u�>3�2D��9��	#s,`I�gm����]��4�(	����*�����6�v�@���&�'�-׋KLK?�1|��~���o���0O���yd[�wa��fu.1�ќ�QL�*�x+�qU��O1.�lD#K#��i�Y�Z?����[���Z�V�*;Z��A?��o���1�blg{�ܮ�����vwk���c$���%q{:�8/��*�hZ���R���Z���?�����������>g��u|��s'|^��F)��7<���l��n�\��;�k����=|sL�Z�	\�Y���gg�+M�Tm�S��]b����E����1��b�z�AlJ�I]*�}�����O�����Q��s�Fw�5���Z^i,٨�Z��ߣSZ�+�s��1�HT��(b�K��ҥ�c���8�ڮDz�c���&h�;�1a\(%׷�5����-\ރ����j�5����/)�b��e�t,��g����Vq|d�/f$�/����M��c�������47�W��tC�>��m�/�}hM�$
�{����.;3AG����2��l�"��Y/��U�u|w2!�����!�}W%Ȓ�����^�|��[b�����A|�#~��=;K,Ӈ�����=;�0�$��w	e쾴�{0a����s�&Uh��tO#�	h�������w�5�G�wX�%]�$G�_�U�o�D�t0�"��]/���'8�aߩP��i�]��n��UL�8�;#����p��_�sK�]�0��[�4�L>1u����d^,ˤ9�o�D��o��58{�Z2=_�J꺘sQڰ٪��I1�=_���|�+�2����tj�;���S�qw�[��B�M��?cf[���}u	P�e�־�	��T���k�"�����[TJO��ÌE��F��j����
Qݡ�M���&)��PU+8�P�a��~�yhJ�2�������x[�S����/C���c��H�����cs�Q�w-ޟ"�sϕ{���ë4� W��u�6z7�1����g��帜챳�5��o���LR[2I�b�'���;O��0IZ�fg�[�(�<���<Ѿ%;�h��}��,N�ܦ?�V1�R1����t1�E�ŹPɁ�Vt��x��b�_*t�x޾�p5)�����n�*�n�|}�m�Y�[Nw��q�KQ=ގ�)i�ҙ�ې���j�F�/޼�)&�qL��r�PL�נvn����ug�g��ʛ@7��<v&=��3��gҎE���'7�"�FKDv:є���)�4�0�[��z?��JF|��_>©&�R*��_����6����m�9�j���__��ף��r�#�����;��|�Zsj�jE�_��|�O����)�Ry�.���1���	Ծ<�`�ZZڶ�z�3r�∅)h�o]�iy�=���ň��щ��� �SVV��d��~t�*���ͭt���	U��뷏�u�J�BT��!��"�r�n���gǇ��+�~ҫ���� >�'�e?9�Y%�n}I-�\鴈��>�/D�pOi���ۯP���j�)wL:��.��>l��u5zh_<R�y�ǖAF�����A�0�u򈱪tޤ����O�od*Ϗ����x�Jϖ�d#=ӭ*Ǎ~�G�V]���T��~�/�>��V�*�|E��Ns0<n����V���-�ʠs,��4էL膸��J�1����C��z+��9*�u�qT�̢�(V@����fJv�;z�kt�S�lm���u{�ƲU*7z��|��Z��$�0�����]G�L:/RƓJu̈́m��J!����(�dI٘V���^q=L�p^�gp9��Wq���݂OQơ#���0��i0|Z��:(�c1��tPDr��@g9�N����CUy�s4�N;/�A*��JDWV U�cnV�K��N��t+ �%\����1L�/�l��-hW��&����
�K�}$��S�yp�E�n$�-��Ģ�#��1��\��^�׺
���8��>_d��[Kġ��*�BA�F=��\�d���xqt�|~������-������5
ɤ����]�	T�ӹO�C3���4`=P��SD��w*��c��}v�ib���+��>���CE�9k蛄���v�`$����:��>�x��kpM�
n������b��N#c|I)]�v!�{�`�fH�L�:
��-n�~�v��	�iƣ+T����<ǂ^	t�a���4��S���ao��&�g���_�^�άN����2�����>���ȕc�q�����v\�U�[���N��O�t#���s���Rs�o��-�W����>�uD�=o�҅ t�{!�w����D^��E�2Sdg�M���F)K�0=j�����F�GuPEr�"���
�Fc�&Tˡ�Ԣ�\N��03���YBn�dn�������������S�cκ�z�J�:�Os�yGx�Z�uj���J�E<<�M��O!�C�$����*�~��#[�J��i�3�ÙǦ����$w�`-���¥e�uZ�r�0�3���\t_E��������7��&���/&H�OOQ	/A,�-�{�f{�8P�v��=!��:��6�s��e&m�bn=�B�6?y��|Y���qKx���H�-�FF�����>3rŃ8{K���D|�E�^֊ni�5�偸TY�8�1Cu.H+b1)��L��Qbo��N��;�&sZD,P���u��tL4�h�Ѓ�~���V�Kʥ�Ȣ�(��%��Q�9PY6����GT��x��>�քW�����*��9b�sI��^�O�@���FGċ�vNR��ܐې7ʯ�AqV�(�^����U�Tb#�^M�'����:��`Jի~�:���EF'�V��[b��?ð��m�E�kM+�0��h2xD�6�yw��D�=�P|�D+��-:`ʱ좵4$?��}EŞ�Êe���SCˬW�hJ�P�KjQg�"V�J��X�͵��u����lT�T'z�����2�;<�>���#h�}�y|T��(Υ�,��$��%/�Z�ñ�\.�`��F���>���*��=a�hKG���o��/+ɯY�,֞��&�837�@~��#���_bB���}�7�{�ƞ;��W�N���BEA����w�Mq������lK�lW�IB �R���aSu�%�@ZVf_'im���f$���WѤ�Z�yv���kZt�<��KA�:%)�J2~C��IQr��q�ܣ�)٘��I�R���e.%��F nL�gh������A� );F,�$C��X�ϊ�	0���uJ�D�=�� od��0*[��\�`���af ���+�H �sJ�"���Dj�Tn�`��<�>!�ύ!���,A�E���@C�io~�w��������-sR J ��Y�S���!�� ��:N�1!�#x�)>F��)�	�^&�� ����q�Ң0	}�ܮL�2ǣL��X�.)sO_�:ej[��8 M
�1k9�GH�)ST<�}L)$�l$eL��=H]@����Hk�I 'S�>�}
c@>����ʝ�؞@��G}L�*H82��
v>G��� ����Z"��)����p/6�1�Ra�\$'���A�Yu�\�Y��pL�Ug������<�o�cV[������t��ڏ����W�R/�������zy��=/��-;��D��Ⱦ]���@ŒV(Ŀ�m��j�ip}ڏ��:��v[pڱ�%�� }_�06׽��xr���c�T�c��䟎>��(�WBa�^�kV,t����h����}��_ȿI��%�����ES;��z�?���\��9��)���p'���s<g��6�T�(�eQ����7,���&1�y�(����} K��h��~�#Y szT��9�а+�x��U�� �#����w6�}L�r?=�&,�o�AdV*/0�w�����Z.��'��`��L[o�x�F���I��v�N�պh�R{٘L� c�� 4Ɓ|�'>\��'���������M��P6�^��;7��^�p�x�r7�k��4l����V7�o� ��%�*�&�(���jt��c���0���DupK�۝n���%jD�"���	`��sru7jlq���.�m^�[Dj*̂�U�/�����.!/�Kx��A�p���$��!���{��O��� ��q�G���H��0��M�D���\����;E6��(��gI\����ե!�- (�\^QNZToJJ�	��O����<ܷ��o#�����tk=��O��F5����G�hAe�c�V~]eGH�(�Q�,��Ip]��5QT��pQG���&9F�2��1q)e8%G`4���:[k��+i��aF6�~JS vQ>78�Ϣ� ��v�&t���k����Ǌ�K��M�%��`Ne��B�����A	�C �D>H���V��:¥/v��V���fP�� �Խ@
=��*)�Ӹ
�Q����M(:~K��=�L)a�-���n#��z�㾑R�B�t��T��,��Fm���"��LKlQfavE��ct�0-V{= �
�p�|t���!���R�F�)�Ed����� ��*n�{}WZ��\\vj�<d�٢7���l����?Ӷ�V}NJ��ܮK�bכ������6� c��ޗܹT����J�&��g�px�C���@�����ޜ�"o5}g�j�l���fec{ ����އ/%u+���2�Λ(8Y�H���U�~��u�s��V����D�+쭆�C8�eN����=�X=�#1�(��|���[�E��Q���1(��i�,%�X�?���W�v��O�hS��/{G&˞�]Lk:C�ƜK���/��U�3-G[���I��>����ƪ�{�W��;2�/4�9��q͟��o$^�������^��FKLQ��_��\�{{԰��]cV0��up�#�'�8sF���jX)
W	�h[I����(岐�U-;�'mD���}m|3*�RP��w5E��ώ��A��{Oˀ>P��C (�I�m��!=�ܜ��ů	S0��!u��=�}��ZI*.�Ur~>ߔ=�.b�F��Y
�2����X�y�	�xa��"�.�?���y�/��3#�>��2�+c�g*��q4��|���o�u�2��U���\j������ذ*o�\)��̑+t�f�|f�J�֌p�qݎ��Ķ*�݃:|'j�)����Gqr�J��y�U����F��+�K��1�c�:��ӧO�k�󵰻���S��>a�<�O���B�~��/7Mqs��	�Gs�>Oy��t+�P�JA�1+�k=�G�-Oy���/���yNq�0��1ȍ���oZ�Jx�t����^��U}�YW���K�7/�r:���
����I��'OZ1Y�3e�>�b�'H���YL�iO6娉��P��+�N&�k���yDǦ���`�ù���|���~�J/d �ì�H�=q@�� \u���6oT� ����.�uU]�@�a�*{*
&�6��B�
���;�ӹߎ��6NOrs�(醓�r9��(i�}4���f�Y���ψ'i����{}F���������j/"3v���ʭc�2�Gg�����i�ט�g Rl�]�^�D�Т�w�lug�t\�p;t+��Ct4�7/�xt����}�,�b?��@@�.�������y�1ک_s ;P8�cL��0��b���0HvDS�}#wm4���z}����ͼ���5wE[����a�#�Z���a�r{�k��?t�"U,�|���F��04L���ĭA�Dv&c��������U��y����7��_L���������g��߭��Ǆ��?��<��t����"�Ǔ��6���O�/���ԥ.u�K]�R��ԥ.u�K]�R��ԥ.u�K]�R��ԥ.u�K]�R�����x@?t �  