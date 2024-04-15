#!/bin/sh

# See https://stackoverflow.com/questions/17510099/ugly-fonts-in-java-applications-on-ubuntu
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dsun.java2d.xrender=true"
