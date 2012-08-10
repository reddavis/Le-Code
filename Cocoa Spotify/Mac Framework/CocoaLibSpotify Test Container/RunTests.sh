#! /bin/bash

DYLD_FALLBACK_FRAMEWORK_PATH=../Frameworks/ ./CocoaLSTests $@
exit $?
