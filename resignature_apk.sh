#!/bin/bash
# key's name
KEYSTORE_NAME=debug.keystore
echo "key's name: "$KEYSTORE_NAME
# key's alias name
KEYSTORE_ALIAS=androiddebugkey
echo "key's alias name: "$KEYSTORE_ALIAS
# key's password
KEYSTORE_STOREPASS=android
echo "key's store password: "$KEYSTORE_STOREPASS
KEYSTORE_KEYPASS=android
echo "key's key password "$KEYSTORE_KEYPASS
# name of temporary file or temporary directory
TEMP_PREFIX=temp_
echo "name of temporary file or temporary directory: "$TEMP_PREFIX
# name of apk with re-signatured
RE_SIGNED=re_signed_
echo "name of apk with re-signatured "$RE_SIGNED

TEMP_DIR=""
LIST="$(ls *.apk)"
for i in "$LIST" ; do
    echo "Re-signature : "$i
        echo "creat the same name directory with the apk"
	# Create the directory, if exist, delete it and re-create
	NAME_OF_APK=${i%.*}
	echo "name of apk without filename extension ："$NAME_OF_APK
#	if [! -d "$NAME_OF_APK"]; then
	if [-d "$NAME_OF_APK"]; then
#	    TEMP_DIR=$TEMP_PREFIX_"$NAME_OF_APK"
#	    echo "temporary_directory name : "$TEMP_DIR
#	    mkdir $TEMP_DIR
#	else
	    rm -rf "$NAME_OF_APK"
#	    mkdir $TEMP_DIR
	fi
#	cp i $TEMP_DIR
#	cp $KEYSTORE_NAME $TEMP_DIR
#	cd $TEMP_DIR

    echo "unzip apk file"
	apktool d $i
	# delte the apk file
#	echo "delete the apk file"
#	rm $i
	# delete the META-INF
	echo "delete the META-INF"
	rm -rf $NAME_OF_APK/original/META-INF


    echo "rezip apk file"
	apktool b $NAME_OF_APK -o ${TEMP_PREFIX}${i}
	echo "new rezip apk file is : "${TEMP_PREFIX}${i}
	rm -rf $NAME_OF_APK


    echo "signature"
	JARSIGNER -VERBOSE -KEYSTORE $KEYSTORE_NAME -STOREPASS $KEYSTORE_STOREPASS ${TEMP_PREFIX}${i} $KEYSTORE_ALIAS -KEYPASS $KEYSTORE_KEYPASS


    echo "optimize with zipalign"
#	zipalign -v 4 ${TEMP_PREFIX}${i} ${RE_SIGNED}${i}
	# check the apk file is optimized or not
#	zipalign -c -v 4 ${TEMP_PREFIX}${i} ${RE_SIGNED}${i}
	# delete the temprotary apk file
#	rm ${TEMP_PREFIX}${i}

    echo "re-signature the apk file finished"

done
