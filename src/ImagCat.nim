import httpClient
import htmlparser
import os
import xmltree  # To use '$' for XmlNode
import strtabs  # To access XmlAttributes
import strutils # To use cmpIgnoreCase


type
  LinkCheckResult = ref object
    link: string
    state: bool

proc checkLink(link: string): LinkCheckResult =
  var client = newHttpClient()
  try:
    return LinkCheckResult(link:link, state:client.get(link).code == Http200)
  except:
    return LinkCheckResult(link:link, state:false)


proc getImage(url: string): bool =
  var client = newHttpClient()
  downloadFile(client, url, "log.html")
  var html = loadHtml("log.html")

  for img in html.findAll("img"):
    if img.attrs.hasKey "src":
      let (dir, filename, ext) = splitFile(img.attrs["src"])
      if ext == ".jpg" or ext == ".JPG":
        var imgURL = "https:" & img.attrs["src"]
        var result = checkLink(imgURL)#画像urlがリンク切れしていないかどうかチェック
        if result.state:
          var filename = filename & ".png"
          downloadFile(client, imgURL, "output/" & filename)


  echo "downloaded!!"




echo "Please give me one URL!"
var url = readLine(stdin)

discard getImage(url)
