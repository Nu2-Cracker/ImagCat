import
  httpClient,
  htmlparser,
  os,
  xmltree,  # To use '$' for XmlNode
  strtabs,  # To access XmlAttributes
  strutils, # To use cmpIgnoreCase
  re,
  asyncdispatch,
  osproc


type
  LinkCheckResult = ref object
    link: string
    state: bool

type 
  DownloadState = ref object
    state: bool


var
  geturlList: seq[string] = @[]
  urlList: seq[string] = @[]
  list:seq[string] = @[]
  i: int = 0
  url: string


proc checkLink(link: string): LinkCheckResult =
  var client = newHttpClient()
  try:
    return LinkCheckResult(link:link, state:client.get(link).code == Http200)
  except:
    return LinkCheckResult(link:link, state:false)

proc checkURIscheme(link: string): string =
  if match(link, re"^(http)"):
    return link
  return "https:" & link


proc getloghtml(url: string): void =
  var client = newHttpClient()
  downloadFile(client, url, "log.html")


proc parsedhtml(url: string): seq[string] =
  var html = loadHtml("log.html")
  for img in html.findAll("img"):
    if img.attrs.hasKey "src":
      var imgURL = checkURIscheme(img.attrs["src"])
      var result = checkLink(imgURL)#画像urlがリンク切れしていないかどうかチェック
      if result.state:
        urlList.add(imgURL)
  return urlList


proc asyncClient(link: string): Future[DownloadState] {.async.} =
  var client = newAsyncHttpClient()
  let future = client.get(link)
  yield future
  let (dir, filename, ext) = splitFile(link)
  if future.failed:
    echo "Error: unhandled exception"
  else:
    discard execCmd("if [ ! -d ./output ]; then mkdir output ; fi")
    waitFor downloadFile(client, link, "output/" & filename & ext)



proc downloadImage(list: seq[string]) {.async.} =
  var futures= newSeq[Future[DownloadState]]()
  for index, link in list:
    futures.add(asyncClient(link))
  let done = await all(futures)
  echo "downloaded!!"


proc haveURLs(): int=
  var inputNumber: string = readLine(stdin)
  if inputNumber == "":
    var defaultNumber: int = 1
    return defaultNumber
  else:
    return inputNumber.parseInt



echo "Do you have two URLs please input 2."
echo "If you have only one urls, you push enter button now."
let num: int = haveURLs()
echo "Please give me one URL!"

while i < num:
  url = readLine(stdin)
  geturlList.add(url)
  inc(i)

for url in geturlList:
  getloghtml(url)
  list= parsedhtml(url)
  waitFor downloadImage(list)


discard execCmd("rm log.html")