#!/bin/bash
# name of the key
KEYSTORE_NAME=debug.keystore
# alias name of the key
KEYSTORE_ALIAS=androiddebugkey
# password of the key
KEYSTORE_STOREPASS=android
KEYSTORE_KEYPASS=android
# name of temporary file or temporary directory
TEMP_PREFIX=temp_
# prefixed name of the re-signatured apk
RE_SIGNED=re_signed_
echo "prefixed name of the re-signatured apk "$RE_SIGNED

TEMP_DIR=""
LIST="$(ls *.apk)"
for i in "$LIST" ; do
    echo "Re-signature : "$i
        echo "creat the same name directory with the apk"
	# Create the directory, if exist, delete it and re-create
	NAME_OF_APK=${i%.*}
	echo "name of apk without filename extension ："$NAME_OF_APK
	if [-d "$NAME_OF_APK"]; then
	    rm -rf "$NAME_OF_APK"
	fi

    echo "unzip apk file"
	apktool d $i
	# delete the META-INF
	echo "delete the META-INF"
	rm -rf $NAME_OF_APK/original/META-INF


    echo "rezip apk file"
	apktool b $NAME_OF_APK -o ${TEMP_PREFIX}${i}
	echo "new rezip apk file is : "${TEMP_PREFIX}${i}
	rm -rf $NAME_OF_APK


    echo "signature"
	JARSIGNER -VERBOSE -KEYSTORE $KEYSTORE_NAME -STOREPASS $KEYSTORE_STOREPASS ${TEMP_PREFIX}${i} $KEYSTORE_ALIAS -KEYPASS $KEYSTORE_KEYPASS


    echo "re-signature the apk file finished"

done
