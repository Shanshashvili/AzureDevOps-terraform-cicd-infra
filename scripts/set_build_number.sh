#!/bin/bash

# Update build number format
echo "##vso[build.updatebuildnumber]ADOLab-App-CI-CD-$(date +%Y.%m.%d).$BUILD_BUILDID"
