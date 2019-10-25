pushd ../
zip --exclude *.sw[op] -r introlin introlin

# introlin.zip goes in the same directory as the html files
# but here it is kept at one level above.

rsync -uvi --checksum introlin.zip  \
sco@v0262.nbi.ac.uk:/var/www/nondb/html/customers/training/linux/
pushd

