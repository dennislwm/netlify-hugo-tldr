---
author: "Dennis Lee"
title: "Creating a Blog Theme with Bootstrap and Harp"
date: "Mon, 26 Sep 2019 12:00:06 +0800"
description: "This was a personal project to create a GUI **head** that is modular, which can be developed with any Headless CMS backend."
draft: false
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
tags:
- harpjs
- bootstrap
- headlessCMS
---

This was a personal project to create a GUI **head** that is modular, which can be developed with any "Headless" CMS backend.

**Responsive and Fast**

The GUI is developed using Bootstrap 4 and Harp.js, which supports EJS. The navigation menu collapses, when viewed on a mobile device, into a *hamburger* menu.

**Modular**

Partials that contain embeddable code are stored in the *layout* folder, e.g. *_header.ejs*.

**Head**

Blog articles are stored as *markdown* files in the *blog/* folder, while their metadata are stored in *_data.json* within the same folder. Harp generates one *html* per *markdown* file.

The index page dynamically populates all articles' snippets from the *metadata* stored in *blog/_data.json*.

## Step 1: Creating a New Node.js Project 

1. Ensure that *Node.js* has been installed, the next thing to do is create a new project.
1. Create a folder anywhere on your PC for this project, e.g. "*d:\Theme-source\03blogstrapi*" ["root folder"]
1. Open the Command ["CMD"] Prompt in the above folder and type this command to create the "*package.json*" file:

```sh
npm init
```

You can leave the default values for each of these entries as below:

     package name: (03blogstrapi)
     version: (1.0.0)
     description:
     entry point: (index.js)
     test command:
     git repository:
     keywords:
     author: 
     license: (ISC)

These entries will be stored in the "*package.json*" file.

     03blogstrapi/               <-- Root of your project
       |- package.json           <-- Node.js project entries

1. Create the following sub-folders in the root folder:

```sh
mkdir css 
mkdir js
mkdir layout
```

2. Download Bootstrap distribution as a ZIP file. URL: [https://getbootstrap.com/docs/4.3/getting-started/download/](https://getbootstrap.com/docs/4.3/getting-started/download/)
3. Unzip the ZIP file and copy both "*bootstrap.min.css*" and "*bootstrap.min.js*" into their respective folders as shown below.

     03blogstrapi/
       |- package.json
       +- css/                   <-- Holds any CSS or SCSS theme files
          |- bootstrap.min.css   <-- At a minimum, the bootstrap CSS file
       +- js/                    <-- Holds any JS files
          |- bootstrap.min.js    <-- At a minimum, the bootstrap JS file
       +- layout/                <-- (Optional) Holds any user templates, prefix "_"

![][1]

[1]: http://tldr.pro/blog/blog/images/creating-a-blog-theme-with-bootstrap-and-harp/step-1--creating-a-new-nodejs-project-.png

## Step 2: Installing Helper Libraries

(1) Ensure that you're in the root folder of the project, then type in the following command:

```sh
npm install -g harp
```

- Harp: Allows the use of base templates which you can load your body content into them. Any files that has the underscore, e.g. "_header.ejs" will be compiled into another and ignored when the files are copeid into the production directory, i.e. "www".

- Note: We recommend installing packages as global ("-g") packages to ensure that these libraries are not duplicated in every project folder.

- Note: We are using Harp's Embeddable JavaScript ["EJS"], instead of Jade, hence, we won't execute Harp's "init" function to generate the default Harp files.

(2) Create a file called _harp.json in the root folder and insert the following code:

```json
     {
         "_comment": "global settings and variables that will be used across the entire blog",
         "globals": {
             "siteTitle": "Creating a Blog Theme with Bootstrap and Harp.js"
         }
     }
```

(3) Create a file named "_data.json" in the root folder and insert the following code:

```json
     {
         "_comment": "template-specific variables and settings; we'll set up one variable for each page template which will hold the name of the page.",
         "index": {
           "pageTitle": "Home"
         }
     }
```

Your project folder should look like this:

     03blogstrapi/
       |- package.json
       |- _harp.json             <-- Global variables goes here
       |- _data.json             <-- Page variables goes here
       +- css/                  
          |- bootstrap.min.css  
       +- js/                   
          |- bootstrap.min.js   
       +- layout/              

## Step 3: Creating a New Layout.ejs

(1) As previously, we'll be using the Visual Studio ["VS"] editor to create a new file "_layout.ejs" in our project folder.

The "_layout.ejs" file is a global template that wraps around every page in our site.

For example, each page will have a title - "pageTitle | siteTitle" - where variable "pageTitle" is taken from the "_data.json" file, which contains page variables, and variable "siteTitle" is taken from "_harp.json" file, which contains global variables.

(2) Type the following code in the above file:

```html
     <!DOCTYPE html> 
     <html lang="en"> 
       <head> 
         <!-- Required meta tags always come first --> 
         <meta charset="utf-8"> 
         <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"> 
         <meta http-equiv="x-ua-compatible" content="ie=edge"> 
      
         <title><%- pageTitle %> | <%- siteTitle %></title> 
      
         <!-- Bootstrap CSS first, then Mytheme CSS --> 
         <link rel="stylesheet" href="css/bootstrap.min.css">
         <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
       </head> 
       <body> 
      
         <%- partial("layout/_header") %> 
      
         <%- yield %>
     
         <%- partial("layout/_footer") %> 
      
         <!-- jQuery first, then Bootstrap JS. --> 
         <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script> 
         <script src="js/bootstrap.min.js"></script> 
       </body> 
     </html>
```

Note: Glyphicon has been dropped from Bootstrap 4, hence we include the free FontAwesome CSS stylesheet in our file "_layout.ejs", after the line below:

```html
         <link rel="stylesheet" href="css/bootstrap.min.css">
```

Your project folder should look like this:

     03blogstrapi/              
       |- package.json
       |- _harp.json             
       |- _data.json
       |- _layout.ejs            <-- Layout for each page in the root folder
       +- css/                  
          |- bootstrap.min.css
       +- js/                    
          |- bootstrap.min.js
       +- layout/               

## Step 4: Creating Other Partial EJS files

(1) In the sub-folder "layout", create a new file "_header.ejs" and insert the following code:

```html
     <nav class="navbar navbar-expand-md navbar-light bg-faded">
       <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarTogglerDemo03" aria-controls="navbarTogglerDemo03" aria-expanded="false" aria-label="Toggle navigation">
         <span class="navbar-toggler-icon"></span>
       </button>
       <a class="navbar-brand" href="#"><h2>dennislwm/bootstrapi</h2></a>
       <div class="collapse navbar-collapse" id="navbarTogglerDemo03">
         <div class="input-group  pull-xs-right">
           <input type="text" class="form-control" placeholder="Search this blog">
           <div class="input-group-append">
             <button class="btn btn-secondary" type="button">
               <i class="fa fa-search"></i>
             </button>
           </div>
         </div>
         <div class="navbar-nav float-left text-left pr-3">
           <a class="nav-item nav-link" href="index.html">Home <span class="sr-only">(current)</span></a>
           <a class="nav-item nav-link" href="about.html">About</a>
           <a class="nav-item nav-link" href="contact.html">Contact</a>
         </div>
       </div>
     </nav>
```

Note: In the first line of the header file, the keyword "navbar-expand-md"  will ensure that the navigation menu is listed horizontally, instead of vertically by default.

(2) Optionally, you can insert the keyword "active" after the first "nav-item" in the list to highlight the first link as a default.

(3) In the sub-folder "layout", create a new file "_footer.ejs" and insert the following code:

```html
     <!-- 
     I'm using the .container class to wrap the entire footer, which will set a max width of 1140 px for the layout. The navbar wasn't placed into a container so it will stretch to the full width of the page. The .container class will also set a left and right padding of .9375rem to the block. It's important to note that Bootstrap 4 uses REMs for the main unit of measure. EMs has been deprecated with the upgrade from version 3. If you're interested in learning more about REMs, you should read this blog post: [http://snook.ca/archives/html_and_css/font-size-with-rem](http://snook.ca/archives/html_and_css/font-size-with-rem) .
     It's also important to note that the column classes have NOT changed from Bootstrap 3 to 4. This is actually a good thing if you are porting over a project, as it will make the migration process much easier. I've set the width of the footer to be the full width of the container by using the .col-lg-12 class.
     -->
     <!-- footer //--> 
     <div class="container"> 
         <div class="row"> 
            <div class="col-lg-12"> 
               &copy; Copyright 2019 Dennis Lee
            </div> 
         </div> 
      </div> 
```

Your project folder should look like this:

     03blogstrapi/              
       |- package.json
       |- _harp.json             
       |- _data.json
       |- _layout.ejs 
       +- css/                  
          |- bootstrap.min.css
       +- js/                    
          |- bootstrap.min.js
       +- layout/
          |- _header.ejs         <-- Header layout, i.e. called by partial() function
          |- _footer.ejs         <-- Footer layout, i.e. called by partial() function

## Step 5: Creating a New Index.ejs

(1) In the root folder, create a new file "index.ejs" and insert the following code.

```html
     <div class="container"> 
         <!-- page body //--> 
         <!-- One card per Blog snippet, which is read from the blog/_data.json file -->
         <% for(var varBlog in public.blog._data) { %>
             <div class="row m-t-3"> 
                 <div class="col-md-9"> 
                     <div class="card "> 
                         <div class="card-block"> 
                             <a href="blog/<%= varBlog %>" class="btn btn-primary"><h4 class="card-title"><%= public.blog._data[varBlog].pageTitle %></h4></a>
                             <p><small>Posted by <a href="#"><%= public.blog._data[varBlog].author %></a> on <%= public.blog._data[varBlog].date %> in <a href="#">Category</a></small></p> 
                             <p class="card-text"><%= public.blog._data[varBlog].snippet %></p> 
                         </div> 
                     </div> 
                 </div> 
             </div> 
         <% }; %>
         <!-- End of One card per Blog snippet -->
     </div> 
```

Note: Since this file isn't prepended with an underscore, harp will produce a file "index.html".

(2) The index.file reads metadata from the "blog/_data.json" file, which contains all the information except the content of our articles.

We use Harp variable "public.blog._data", where "public" is the root folder, "blog" is the subfolder, and "_data" is the json file. 

We iterate through all the articles using a for loop and assigning each article to our custom variable "varBlog".

We can then access each article's metadata, e.g. "public.blog._data[varBlog].pageTitle", where "pageTitle" is our article's custom metadata.

(3) Create the following sub-folder in the root folder:

```sh
mkdir blog
```

(4) In the sub-folder "blog", create a new file "_data.json" and copy and paste the following code:

```json
     {
     	"creating-a-blog-theme-with-bootstrap-and-harp": {
     		"pageTitle": "Creating a Blog Theme with Bootstrap and Harp",
     		"date": "Sep 26, 2019",
     		"author": "Dennis Lee",
     		"snippet": "The motivation comes from creating my own job board theme that copies all of the functionality of SimpleJobScript [SJS], written using Bootstrap and PHP, to enable adding new features in the future.        However, in this document we will be focused on creating a Blog Theme to duplicate the functionalities of Nibble Blog that is bundled together with SJS."
     	},
     	"creating-a-custom-url-shortener-api-in-node": {
     		"pageTitle": "Setup Strapi CMS on Docker",
     		"date": "Sep 26, 2019",
     		"author": "Dennis Lee",
     		"snippet": "Traversy Media provides a skeleton code for a Custom URL Shortener API, which is automated and hosted locally. Also, it automatically checks to ensure that there are no duplicate long URLs, when inserting a row in the Mongo database."
     	}
     }
```

For each slug in the above "blog/_data.json" file, we should have a corresponding Markdown file ".md" with the same name. 

For example, the file "creating-a-custom-url-shortener-api-in-node.md" should be also be in the "blog/" folder.

Each slug should also have values for these FOUR (4) metadata:

1. pageTitle: Title of article
1. date: Date of article
1. author: Author of article
1. snippet: Snippet of article that appears in the index.html page.

Your project folder should look like this:

     03blogstrapi/              
       |- package.json
       |- _harp.json             
       |- _data.json
       |- _layout.ejs 
       |- index.ejs              <-- Home page of your blog, Harp will produce a html
       +- css/                  
          |- bootstrap.min.css
       +- js/                    
          |- bootstrap.min.js
       +- layout/
          |- _header.ejs         
          |- _footer.ejs         
       +- blog/
          |- _data.json          <-- Our articles' metadata goes here

## Step 6: Running Our Home Page!

(1) In the root folder, type the following command:

```sh
harp compile
```

If everything worked, a new blank line in the terminal will appear. This is good! Otherwise, the compiler will spit out an error. 

**Important**: There should be a new "www" folder that holds all the compiled HTML, CSS, and Javascript files for your project. When you are ready to deploy your project to a production web server, you would copy these files up with FTP. Everytime you edit your code, you should run the harp compile command.

(2) Harp has a built-in web server that is backed by Node.js. In your root folder, type the following command:

```sh
harp server
```

(3) You can navigate to the following URL to view it: [http://localhost:9000](http://localhost:9000)

Note: You can specify a different port by using --port parameter, e.g. --port 9001, in the harp server command.

![][2]

[2]: http://tldr.pro/blog/blog/images/creating-a-blog-theme-with-bootstrap-and-harp/step-6--running-our-home-page-.png

## Step 7: Extending Your Theme

(1) Before we code our first Flexbox grid, which is included in Bootstrap, we need to add a custom CSS theme to our project. In the "css" folder, create a new file named "mytheme.css". For now, the file can be blank.

(2) Update the file "_layout.ejs" to include the theme file as follows:

```html
     <!-- Bootstrap CSS first, then MyTheme CSS -->
     <link rel="stylesheet" href="css/bootstrap.min.css">
     <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
     <link rel="stylesheet" href="css/mytheme.css">
```

(3) In the sub-folder "css", create a new file "mytheme.css" and insert the following code:

```css
     /* Footer flushed at bottom of page */
     html {
         position: relative;
         min-height: 100%;
     }
     body {
         margin-bottom: 60px; /* Margin bottom by footer height */
     }
     .footer {
         position: absolute;
         bottom: 0;
         height: 60px; /* Set the fixed height of the footer here */
         line-height: 60px; /* Vertically center the text there */
     }
     /* End of Footer */
     /* Cards */
     .card {
         border: none /* Remove border around cards */
     }
     .card-block {
         padding-bottom: 50px /* Padding between cards */
     }
     /* End of Cards */
```

Your project folder should look like this:

     03blogstrapi/              
       |- package.json
       |- _harp.json             
       |- _data.json
       |- _layout.ejs 
       |- index.ejs              
       +- css/                  
          |- bootstrap.min.css
          |- mytheme.css         <-- Our custom CSS theme goes here
       +- js/                    
          |- bootstrap.min.js
       +- layout/
          |- _header.ejs         
          |- _footer.ejs         
       +- blog/
          |- _data.json

## Step 8: Working with Layouts

There are two types of containers you can choose to use: (a) container-fluid; and (b) container.

- container-fluid: a full-width box that will stretch the layout to fit the entire width of the browser window

- container: a fixed width based on the size of your device's viewport: (i) xs (<544px); (ii) sm (>544px); (iii) md (>720px); (iv) lg (>940px); (v) xl (>1140px).

The next step is to insert at least a single row of columns. Each container class can have one or more rows nested inside of it. A row defines a collection of horizontal columns that can be broken up to TWELVE (12) times.

(1) Copy the file "_layout.ejs" from the root folder into the sub-folder "blog" and modify the following code:

```html
     <!-- Change relative path for both CSS and JS files below -->
     <link rel="stylesheet" href="../css/bootstrap.min.css">
     <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
     <link rel="stylesheet" href="../css/mytheme.css">ner">
```

(2) Do the same for the JS files:

```js
         <!-- jQuery first, then Bootstrap JS. --> 
         <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script> 
         <script src="../js/bootstrap.min.js"></script> 
```

This is necessary as the "blog/_layout.ejs" is one level below the root folder, and our references to JS and CSS files are based on the root folder.

The "blog/_layout.ejs" will apply to each file in our sub-folder "blog", which will contain the articles written in Markdown. Harp will produce a ".html" for every ".md" file.

Note the contents of ".md" file are accessed using the Harp variable "<%- yield %>.

(3) Modify the file "blog/_layout.ejs" by replacing the line "<%- yield %>" with:

```html
     <!-- Variable yield outputs the content of each Markdown blog file ".md" wrapped in a Card class -->
     <div class="container"> 
        <div class="row m-t-3"> 
           <div class="col-md-9"> 
               <div class="card "> 
                   <div class="card-block"> 
                       <%- yield %>
                   </div> 
               </div> 
           </div> 
       </div> 
     </div>     
```

Unlike "index.ejs", we cannot modify any of the Markdown files "*.md", hence our HTML code has to be contained within the "blog/_layout.ejs".

Your project folder should look like this:

     03blogstrapi/              
       |- package.json
       |- _harp.json             
       |- _data.json
       |- _layout.ejs 
       |- index.ejs              
       +- css/                  
          |- bootstrap.min.css
          |- mytheme.css         
       +- js/                    
          |- bootstrap.min.js
       +- layout/
          |- _header.ejs         
          |- _footer.ejs         
       +- blog/
          |- _data.json
          |- _layout.ejs         <-- Layout that apply to each page in folder blog/
