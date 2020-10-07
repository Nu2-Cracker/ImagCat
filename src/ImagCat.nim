import httpClient
import htmlparser
import os
import xmltree  # To use '$' for XmlNode
import strtabs  # To access XmlAttributes
import strutils # To use cmpIgnoreCase

proc getImage(url: string): bool =

  var client = newHttpClient()

  downloadFile(client, url, "log.html")

  var html = loadHtml("log.html")

  for img in html.findAll("img"):
    if img.attrs.hasKey "src":
      let (dir, filename, ext) = splitFile(img.attrs["src"])
      if ext == ".jpg" or ext == ".JPG":
        var imgURL = "https:" & img.attrs["src"]
        var filename = filename & ".png"
        downloadFile(client, imgURL, "output/" & filename)


  echo "downloaded!!"


echo "Please give me one URL!"
var url = readLine(stdin)

discard getImage(url)
