#!/usr/bin/env bash
# This script is part of the package that is managed by 4NET

# Reload pm2
cd $CURRENT_LINK
su gitlab -c "pm2 reload ecosystem.config.js;";
