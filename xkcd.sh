#!/bin/bash

# Fetch the latest comic number
latest_comic=$(curl -s https://xkcd.com/info.0.json | jq .num)

# Calculate the numbers for the last 3 comics
comic1=$((latest_comic - 2))
comic2=$((latest_comic - 1))
comic3=$latest_comic

# Create a temporary directory for comic images
mkdir -p xkcd_comics
cd xkcd_comics

# Download the last 3 comics and add title and number above each image
for i in $comic1 $comic2 $comic3; do
 # Fetch comic details
 comic_data=$(curl -s https://xkcd.com/$i/info.0.json)
 img_url=$(echo $comic_data | jq -r .img)
 title=$(echo $comic_data | jq -r .title)
 number=$(echo $comic_data | jq -r .num)

 # Download the comic image
 wget -O comic_$i.png $img_url

 # Add 20px of whitespace above the image
 convert comic_$i.png -gravity center -background white -extent $(identify -format '%[fx:W]x%[fx:H+100]' comic_$i.png) comic_$i.png
 # Add title and number above the image
 convert comic_$i.png -gravity North -font Liberation-Sans-Bold -pointsize 20 -fill black -annotate +0+20 "Comic $number: $title" comic_$i.png
done

# Combine the images into one and convert to PDF
# Note: Adjust the resize parameter as needed to fit your desired page size
convert comic_$comic1.png comic_$comic2.png comic_$comic3.png -resize 2480x3508 -append combined_comics_alpha.png
convert combined_comics_alpha.png -background white -alpha remove combined_comics.jpg
img2pdf combined_comics.jpg -o xkcd_comics.pdf

# Move the PDF to the initial directory and clean up
mv xkcd_comics.pdf ../
cd ..
rm -rf xkcd_comics

echo "The PDF document has been created as xkcd_comics.pdf"

