#!/bin/bash
./gradlew clean
./gradlew build
./gradlew assembleRelease
#python path_of_sendmail_script/sendmail.py send_email_file_path file_name apk_name
