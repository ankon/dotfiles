#/bin/sh

echo "WARNING: Incomplete, and will likely destroy existing configuration" >&2
exit 1

# Install custom mime types
for config in .local/share/mime/*.xml; do
    xdg-mime install "${config}"
done
update-mime-database ~/.local/share/mime/