---
date: '2018-04-20'
description: 透過結合靜態網頁、DataCamp light、以及 google 試算表，使填寫結果即時回饋成為可能
mermaid: false
tags:
- Web Page
- 中文
title: google 表單即時回饋
---


<style>
pre > code {white-space: pre-wrap;}
</style>

google 表單大幅降低蒐集問卷資料的難度；此外，表單將回應**自動彙整成試算表**更使分析資料變得非常容易。然而，google 表單缺乏一項重要的功能：**即時將結果回饋給填寫者**<!--more-->[^test]。

讓問卷填寫者能馬上知道結果，可以增加其填寫意願，同時也是負責的態度(在回饋不會造成負面影響的前提下)。當然，這在 google 表單本身的限制下無法達成。以下將介紹如何結合 **google 試算表** 以及 **[DataCamp Light](https://github.com/datacamp/datacamp-light)**，讓任何人都能製作出一個在**靜態網頁**上運行的平台，**使填寫者能在此填寫問卷、查詢結果**。

**實際操作**  
繼續閱讀下去前，可先至[回饋功能示範平台](/assets/gsheet_post/demo/)操作看看，比較容易理解下文內容。文章中的說明即是依據此**回饋功能示範平台**。
{: .success}

概觀: 運作邏輯 

這節將設置**問卷回饋平台**的**資料蒐集與運算功能**，包含 1 個 google 表單(`表單`)及 3 個 google 試算表(`表單回應`, `運算分析`, `結果查找`)。

### 連結表單至試算表

這項功能使用過 google 表單的人都知道，可參考 [google 說明](https://support.google.com/docs/answer/2917686?hl=zh-Hant)，以下簡單說明：

從雲端硬碟進入到表單後，即會顯示下圖的頁面(需具編輯權限)。注意需於**中間白色方塊**點選「**回覆**」，畫面才會如下圖(預設畫面是「問題」)。

![](/assets/gsheet_post/linksheet.PNG){: width="85%" height="85%"}
{:.rounded}

接著點選白色方塊右上方的綠色 icon，即會出現 2 個選項：

- 建立新試算表，並命名。 (預設名稱為「無標題表單 (回應)」)
- 選取現有的試算表

選擇建立新的試算表。  
點選建立後，即會在與表單相同的資料夾中建立試算表，我將其命名為**表單回應**(即**概觀**中[右圖](#mermaidChart0)的`表單回應`)。  
此後，每當有人填完問卷，`表單回應`即會自動新增一列(row)資料。

### 試算表間的連結: `IMPORTRANGE`

**千萬不能編輯`表單回應`**，這可能會破壞收集到的問卷資料。google 試算表有一個很實用的函數`IMPORTRANGE`，能夠選取一試算表中特定的範圍，將其連結至另一獨立的試算表中(獨立檔案)。因此，每當原先的試算表更新，透過`IMPORTRANGE`連結的新試算表也會跟著更新。如此，即可在不更動`表單回應`下，對`表單回應`的內容進行運算。

若此文關於`IMPORTRANGE`有描述不清的地方，可參考[這篇](http://isvincent.pixnet.net/blog/post/46090834-excel-google%E8%A9%A6%E7%AE%97%E8%A1%A8%E5%A6%82%E4%BD%95%E9%97%9C%E8%81%AF%E5%88%B0%E5%8F%A6%E4%B8%80%E5%80%8B%E8%A9%A6%E7%AE%97%E8%A1%A8%E7%9A%84%E5%85%A7)寫得相當清楚的文章。
{: .info}

```vbscript
IMPORTRANGE("<URL>", "<工作表名稱>!<儲存格範圍>")
```
- `<URL>`: 所欲匯入資料之試算表的網址，在此為`表單回應`之URL
- `<工作表名稱>`: `表單回應`只有一個工作表，將其名稱填入這裡。
- `<儲存格範圍>`: 儲存格範圍視問卷的題數與筆數而定，其格式為：`A1:F9999`。大寫字母代表欄位，一個欄位即為問卷上的一題；字母後面的數字是列數，一筆資料(一份問卷)佔有一列(row)。

### **`運算分析`**試算表

#### 匯入
在[`運算分析`](https://docs.google.com/spreadsheets/d/1znFpdD_Kt1Jk274l0yD1dGZZyhsh7m1Xji9IYZUigEU/edit#gid=0)中的儲存格`A1`，我輸入了以下公式：

```vbscript
=IMPORTRANGE("https://docs.google.com/spreadsheets/d/1-eOAbpOZ1aeuNUHo3b0olLTrheq-T-pe2BsRXK-P-mM/edit#gid=579070166", "表單回應 1!A1:E9999")
```

以匯入[`表單回應`](https://docs.google.com/spreadsheets/d/1-eOAbpOZ1aeuNUHo3b0olLTrheq-T-pe2BsRXK-P-mM/edit#gid=579070166)的 A 至 E 欄[^num]。

#### 運算公式
我在 G 欄設定公式計算 Q1, Q2, Q3 的分數總合，其中 **Q3 是反向計分**。

#### 時間戳記

由於之後會透過 DataCamp Light 讀取 google 試算表，但其並不支援**英文以外的文字**，因此需**將試算表的格式改為英文**：

選擇試算表 `檔案` > `試算表設定` > `一般`:

- 語言代碼: `美國`
- 時區: `(GMT+08:00) Taipei`[^tz]

更改完試算表語言後，需更改**時間戳記**的格式[^format]：

1. 選擇時間戳記那欄(在此為 A 欄)
2. `格式` > `數值` > `日期時間`

### **`結果查找`**試算表


`運算分析`設置完成之後，需要**選擇希望使用者查詢時，能看到的項目**:

1. **時間戳記**: A 欄
2. **Token**: E 欄
3. **score**: G 欄

因此，需將`結果查找`中的 A、B、C 欄分別對應到`運算分析`中的 A、E、G 欄。在`結果查找`的儲存格`A1`、`B1`、`C1`，分別使用`IMPORTRANGE`：

1. 儲存格`A1`

```vbscript
=IMPORTRANGE("https://docs.google.com/spreadsheets/d/1znFpdD_Kt1Jk274l0yD1dGZZyhsh7m1Xji9IYZUigEU/edit#gid=0", "工作表1!A1:A9999")
```

2. 儲存格`B1`

```vbscript
=IMPORTRANGE("https://docs.google.com/spreadsheets/d/1znFpdD_Kt1Jk274l0yD1dGZZyhsh7m1Xji9IYZUigEU/edit#gid=0", "工作表1!E1:E9999")
```

3. 儲存格`C1`

```vbscript
=IMPORTRANGE("https://docs.google.com/spreadsheets/d/1znFpdD_Kt1Jk274l0yD1dGZZyhsh7m1Xji9IYZUigEU/edit#gid=0", "工作表1!G1:G9999")
```

DataCamp Light 設置

對於完全沒有概念的人，設置靜態網頁可能會是比較困難的部分，因為多數人對此相當陌生。靜態網頁在此的目的是為了讓  DataCamp Light 的程式碼(即一段 HTML)能夠運行，因此若讀者使用的部落格平台允許自由變更網頁的 html 並且能自由匯入 JS[^blog]，則可以忽略此節內容。

### GitHub Pages

架設靜態網頁[^static]並非難事，難的是做出漂亮的靜態網頁。然而，網頁越漂亮，其結構通常也更加複雜。如何(短時間)打造美觀的靜態網頁以及基礎 HTML, CSS 的概念並非此文的目的。對於有這些需求的讀者，我推薦 [Yihui Xie](https://yihui.name/) 的 [blogdown](https://bookdown.org/yihui/blogdown/)。

以下提供一個最精簡的例子，由註冊 GitHub 帳號到架設網頁，過程中僅需使用到瀏覽器(GUI)，不需用到 Git。

#### 註冊與建立 Repo
1. 至 https://github.com/ ，填寫註冊資訊(一個 email 僅能註冊一次)，並記得去信箱認證。**Username** 即為之後網站的網址，以下圖為例，minimalghpage.github.io。

	![](/assets/gsheet_post/github_signup.PNG){: width="48%" height="48%"}

1. 信箱認證後，將自動跳回 GitHub 頁面。之後，基本上不需更動出現之畫面的設定，只要按下一步。最後應會出現下圖，按右上角圖示並選取 **Your Profile**。
	
	![account info](/assets/gsheet_post/gh_main.PNG){: width="80%" height="80%"}

1. 按下網頁中上方的 **Repositories** 後應會出現下圖，接著再按下右上方的綠色按鈕 **New**。
	
	![](/assets/gsheet_post/gh_repo.PNG){: width="80%" height="80%"}

1. 出現下圖後，在 **Repository name** 輸入`<username>.github.io`(`<username>`一定要與當初註冊時填入的 **Username** 一模一樣)，並**勾選**下方 **Initialize this repository with a README**。最後按 **Create repository**。

	![](/assets/gsheet_post/create_repo.PNG){: width="70%" height="70%"}


#### 上傳網頁

1. [下載](https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/liao961120/local_depend/tree/master/minimal_web_DataCampLight) **Minimal Web Page** (下載後需解壓縮。)

2. 至剛剛建立的 Repository (`<username>.github.io`)，點擊 **Upload files** (圖中黃色螢光處)。  

	![](/assets/gsheet_post/gh_upload.PNG){: width="90%" height="90%"}

3. 進入新畫面後，將`index.html`, `search.html`, `.nojekyll`拖曳上傳，並按下畫面最下方 **Commit changes**.

4. 上傳完成後，即可看到下圖。`.nojekyll`不會顯示出來。  
	
	![](/assets/gsheet_post/gh_uploaded.PNG){: width="90%" height="90%"}

5. **完成！**過 1, 2 分鐘後，即可至`<username>.github.io`檢視網頁。
6. 之後若要修改檔案，將修改過後的檔案依相同步驟上傳即可。


### Minimal Web Page

[Minimal Web Page](https://github.com/liao961120/local_depend/tree/master/minimal_web_DataCampLight) 裡面有三個檔案：`index.html`, `search.html`, `.nojekyll`。

- `index.html`: 這是網站的首頁，亦即瀏覽器進入`https://<username>.github.io/`時所讀取的檔案。此檔案內含 HTML 必要結構，並且匯入 [bootstrap](https://getbootstrap.com/docs/4.0/getting-started/introduction/) 的 CSS 和 JS 以快速製作漂亮的 Button 和 Modal。
- `search.html`：這份檔案即為上文 DataCamp light 的[完整程式碼](#完整程式碼)，加上一些 HTML 的必要結構以及重新整理頁面的按鈕(Reload)。若需修改其中的 R Script，需用[文字編輯器](https://zh.wikipedia.org/wiki/%E6%96%87%E6%9C%AC%E7%BC%96%E8%BE%91%E5%99%A8)開啟此檔案修改`<code>...</code>`裡面的內容。
- `.nojekyll`: [Jekyll](https://help.github.com/articles/using-jekyll-as-a-static-site-generator-with-github-pages/) 是 GitHub Pages 預設的靜態網頁產生器，能自動將 Markdown 生成`.html`，對於常寫文章的使用者很方便：不需每次發文都要自己將文章轉為 html 檔。`.nojekyll`在此的作用是告訴 GitHub Pages **不要使用 Jekyll 產生網頁**，因為使用 Jekyll 產生網頁，repository 需符合特定的檔案格式與架構[^jekyll]。

#### R 使用者

會用 Rmarkdown 的人，可直接[下載](https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/liao961120/blog/tree/master/assets/gsheet_post/demo)**回饋功能示範平台**製作網頁(需額外安裝一些 package)，不須使用上述資料夾內的檔案。這能省下許多製作網頁(`index.html`)的時間。

R markdown 是 Markdown 的擴充，其輸出的 HTML 格式已經過簡單的排版，同時也支援 Bootstrap (**Minimal Web Page** 裡的 HTML 也有匯入 Bootstrap)，因此能夠輕易地製作出**美觀**的網頁。Rmarkdown 可輸出許多格式，其中 [html_document](https://rmarkdown.rstudio.com/html_document_format.html) 最為簡單。Rmarkdown 的語法([Cheat Sheet](https://www.rstudio.com/wp-content/uploads/2015/03/rmarkdown-reference.pdf))即為 Markdown 語法加上許多額外的功能(透過 R 實現)。
<div id="privacy"></div>

隱私問題
